import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/note.dart';
import '../../domain/note_color.dart';
import '../../domain/note_draft.dart';
import '../stores/notes_store.dart';
import '../widgets/contained_icon_button.dart';
import '../widgets/editor_confirmation_dialog.dart';
import '../widgets/editor_toolbar.dart';
import 'editor_presentation_mode.dart';

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, required this.store, this.note});

  final NotesStore store;
  final Note? note;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage>
    with WidgetsBindingObserver {
  static const _draftDelay = Duration(milliseconds: 350);

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final FocusNode _titleFocusNode;
  late final FocusNode _bodyFocusNode;
  Timer? _draftTimer;
  Future<void> _draftWrite = Future<void>.value();
  int _draftRevision = 0;
  NoteColor? _color;
  EditorPresentationMode _presentationMode = EditorPresentationMode.edit;
  bool _initialized = false;
  bool _isSaved = false;
  String _originalTitle = '';
  String _originalBody = '';
  String _lastObservedTitle = '';
  String _lastObservedBody = '';

  String get _draftId =>
      widget.note == null ? 'new-note' : 'note-${widget.note!.id}';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _titleFocusNode = FocusNode()..addListener(_onFocusChanged);
    _bodyFocusNode = FocusNode()..addListener(_onFocusChanged);
    _titleController.addListener(_onTitleControllerChanged);
    _bodyController.addListener(_onBodyControllerChanged);
    WidgetsBinding.instance.addObserver(this);
    _restoreDraft();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draftTimer?.cancel();
    if (!_isSaved) unawaited(_flushDraft());
    _titleFocusNode.dispose();
    _bodyFocusNode.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_flushDraft());
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorite = widget.note?.isFavorite ?? false;
    final isPreview = _presentationMode == EditorPresentationMode.preview;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final toolbarVisible =
        keyboardVisible &&
        (_titleFocusNode.hasFocus || _bodyFocusNode.hasFocus);
    return PopScope(
      canPop: !isPreview && (!_isDirty || _isSaved),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(favorite: favorite, isPreview: isPreview),
              const SizedBox(height: 32),
              Expanded(
                child: isPreview ? _buildPreviewContent() : _buildEditContent(),
              ),
              if (!isPreview && toolbarVisible) const EditorToolbar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required bool favorite, required bool isPreview}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            ContainedIconButton(
              key: const ValueKey('editor-back-control'),
              tooltip: 'Back',
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _initialized ? _handleBack : null,
            ),
            const Spacer(),
            if (isPreview)
              ContainedIconButton(
                key: const ValueKey('editor-preview-edit-control'),
                tooltip: 'Edit note',
                icon: const Icon(Icons.edit_rounded),
                onPressed: _showEdit,
              )
            else ...[
              ContainedIconButton(
                key: const ValueKey('editor-state-control'),
                tooltip: favorite ? 'Favorite note' : 'Preview note',
                icon: Icon(
                  favorite
                      ? Icons.star_border_rounded
                      : Icons.visibility_outlined,
                ),
                foregroundColor: favorite
                    ? AppColors.favoriteAction
                    : Colors.white,
                onPressed: _initialized ? _preview : null,
              ),
              const SizedBox(width: 19),
              ContainedIconButton(
                key: const ValueKey('editor-save-control'),
                tooltip: 'Save note',
                icon: const Icon(Icons.save_outlined),
                onPressed: _initialized ? _save : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditContent() {
    return SingleChildScrollView(
      key: const ValueKey('editor-scroll-view'),
      padding: const EdgeInsets.fromLTRB(23, 0, 23, 32),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('editor-title-field'),
            controller: _titleController,
            focusNode: _titleFocusNode,
            autofocus: widget.note == null,
            enabled: _initialized,
            minLines: 1,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            scrollPadding: const EdgeInsets.only(bottom: 72),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontSize: 48,
              height: 1,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
            decoration: const InputDecoration.collapsed(
              hintText: 'Title',
              hintStyle: TextStyle(
                color: Colors.white38,
                fontFamily: 'Nunito',
                fontSize: 48,
                height: 1,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('editor-body-field'),
            controller: _bodyController,
            focusNode: _bodyFocusNode,
            enabled: _initialized,
            minLines: 1,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            scrollPadding: const EdgeInsets.only(bottom: 72),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontSize: 23,
              height: 1,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
            decoration: const InputDecoration.collapsed(
              hintText: 'Type something...',
              hintStyle: TextStyle(
                color: Colors.white38,
                fontFamily: 'Nunito',
                fontSize: 23,
                height: 1,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    return SingleChildScrollView(
      key: const ValueKey('editor-preview-scroll-view'),
      padding: const EdgeInsets.fromLTRB(23, 0, 23, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleController.text,
            key: const ValueKey('editor-preview-title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.25,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            _bodyController.text,
            key: const ValueKey('editor-preview-body'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onTitleControllerChanged() {
    final title = _titleController.text;
    if (title == _lastObservedTitle) return;
    _lastObservedTitle = title;
    _scheduleDraft();
  }

  void _onBodyControllerChanged() {
    final body = _bodyController.text;
    if (body == _lastObservedBody) return;
    _lastObservedBody = body;
    _scheduleDraft();
  }

  Future<void> _restoreDraft() async {
    final draft = await widget.store.getDraft(_draftId);
    final savedNote = widget.note;
    if (!mounted) return;
    final color =
        draft?.color ??
        savedNote?.color ??
        await widget.store.reserveNextColor();
    if (!mounted) return;
    _titleController.text = draft?.title ?? savedNote?.title ?? '';
    _bodyController.text = draft?.body ?? savedNote?.body ?? '';
    _originalTitle = _titleController.text;
    _originalBody = _bodyController.text;
    _lastObservedTitle = _originalTitle;
    _lastObservedBody = _originalBody;
    _color = color;
    setState(() => _initialized = true);
    if (widget.note == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _titleFocusNode.requestFocus();
      });
    }
  }

  void _scheduleDraft() {
    if (!_initialized) return;
    _draftRevision += 1;
    _draftTimer?.cancel();
    if (_isDirty) {
      _draftTimer = Timer(_draftDelay, _queueDraftWrite);
    } else {
      unawaited(_clearDraftAfterPendingWrites(_draftRevision));
    }
    setState(() {});
  }

  Future<void> _flushDraft() async {
    _draftTimer?.cancel();
    _queueDraftWrite();
    await _draftWrite;
  }

  void _queueDraftWrite() {
    if (!_initialized || _color == null || !_isDirty) return;
    final draft = NoteDraft(
      id: _draftId,
      noteId: widget.note?.id,
      title: _titleController.text,
      body: _bodyController.text,
      color: _color!,
      isFavorite: widget.note?.isFavorite ?? false,
      updatedAt: DateTime.now(),
    );
    _draftWrite = _draftWrite
        .catchError((_) {})
        .then((_) => widget.store.saveDraft(draft));
  }

  Future<void> _clearDraftAfterPendingWrites(int revision) async {
    _draftTimer?.cancel();
    await _draftWrite.catchError((_) {});
    if (_isDirty || revision != _draftRevision) return;
    await widget.store.deleteDraft(_draftId);
  }

  bool get _isDirty =>
      _titleController.text != _originalTitle ||
      _bodyController.text != _originalBody;

  Future<void> _save() async {
    if (_isDirty) {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierColor: EditorConfirmationDialog.barrierColor,
        builder: (context) => const EditorConfirmationDialog(
          message: 'Save changes?',
          confirmLabel: 'Save',
          discardResult: false,
          confirmResult: true,
        ),
      );
      if (confirmed != true) {
        if (confirmed == false) await _discard();
        return;
      }
    }
    await _commitSave();
  }

  Future<void> _commitSave() async {
    await _flushDraft();
    final savedNote = widget.note;
    if (savedNote == null) {
      await widget.store.create(
        title: _titleController.text,
        body: _bodyController.text,
        color: _color,
      );
    } else {
      await widget.store.update(
        savedNote.copyWith(
          title: _titleController.text,
          body: _bodyController.text,
        ),
      );
    }
    await widget.store.deleteDraft(_draftId);
    setState(() => _isSaved = true);
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  Future<void> _handleBack() async {
    if (_presentationMode == EditorPresentationMode.preview) {
      _showEdit();
      return;
    }
    if (!_isDirty) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      barrierColor: EditorConfirmationDialog.barrierColor,
      builder: (context) => const EditorConfirmationDialog(
        message: 'Are you sure you want to discard changes?',
        confirmLabel: 'Keep',
        discardResult: true,
        confirmResult: false,
      ),
    );
    if (discard == true) await _discard();
  }

  void _preview() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _presentationMode = EditorPresentationMode.preview);
  }

  void _showEdit() {
    setState(() => _presentationMode = EditorPresentationMode.edit);
  }

  Future<void> _discard() async {
    setState(() => _isSaved = true);
    _draftTimer?.cancel();
    await _draftWrite.catchError((_) {});
    await widget.store.deleteDraft(_draftId);
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }
}
