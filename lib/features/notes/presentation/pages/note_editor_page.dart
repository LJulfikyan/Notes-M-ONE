import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/note.dart';
import '../../domain/note_color.dart';
import '../../domain/note_draft.dart';
import '../stores/notes_store.dart';
import '../widgets/contained_icon_button.dart';
import '../widgets/editor_toolbar.dart';
import 'note_reader_page.dart';

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
  Timer? _draftTimer;
  Future<void> _draftWrite = Future<void>.value();
  int _draftRevision = 0;
  NoteColor? _color;
  bool _initialized = false;
  bool _isSaved = false;
  String _originalTitle = '';
  String _originalBody = '';

  String get _draftId =>
      widget.note == null ? 'new-note' : 'note-${widget.note!.id}';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _titleController.addListener(_scheduleDraft);
    _bodyController.addListener(_scheduleDraft);
    WidgetsBinding.instance.addObserver(this);
    _restoreDraft();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draftTimer?.cancel();
    if (!_isSaved) {
      unawaited(_flushDraft());
    }
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
    return PopScope(
      canPop: !_isDirty || _isSaved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: ContainedIconButton(
            tooltip: 'Back',
            icon: Icons.chevron_left_rounded,
            onPressed: _initialized ? _handleBack : null,
          ),
          actions: [
            ContainedIconButton(
              tooltip: 'Preview note',
              icon: favorite ? Icons.star_rounded : Icons.visibility_outlined,
              foregroundColor: favorite
                  ? AppColors.favoriteAction
                  : Colors.white,
              onPressed: _initialized ? _preview : null,
            ),
            ContainedIconButton(
              tooltip: 'Save note',
              icon: Icons.save_outlined,
              onPressed: _initialized ? _save : null,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        enabled: _initialized,
                        textCapitalization: TextCapitalization.sentences,
                        style: Theme.of(context).textTheme.headlineSmall,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _bodyController,
                          enabled: _initialized,
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          textCapitalization: TextCapitalization.sentences,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: const InputDecoration(
                            hintText: 'Type something...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const EditorToolbar(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restoreDraft() async {
    final draft = await widget.store.getDraft(_draftId);
    final savedNote = widget.note;
    if (!mounted) {
      return;
    }
    final color =
        draft?.color ??
        savedNote?.color ??
        await widget.store.reserveNextColor();
    if (!mounted) {
      return;
    }
    _titleController.text = draft?.title ?? savedNote?.title ?? '';
    _bodyController.text = draft?.body ?? savedNote?.body ?? '';
    _originalTitle = _titleController.text;
    _originalBody = _bodyController.text;
    _color = color;
    setState(() => _initialized = true);
  }

  void _scheduleDraft() {
    if (!_initialized) {
      return;
    }
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
    if (!_initialized || _color == null || !_isDirty) {
      return;
    }
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
    if (_isDirty || revision != _draftRevision) {
      return;
    }
    await widget.store.deleteDraft(_draftId);
  }

  bool get _isDirty =>
      _titleController.text != _originalTitle ||
      _bodyController.text != _originalBody;

  Future<void> _save() async {
    if (_isDirty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => _confirmationDialog(
          context: context,
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
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleBack() async {
    if (!_isDirty) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => _confirmationDialog(
        context: context,
        message: 'Are you sure you want to discard changes?',
        confirmLabel: 'Keep',
        discardResult: true,
        confirmResult: false,
      ),
    );
    if (discard == true) await _discard();
  }

  Widget _confirmationDialog({
    required BuildContext context,
    required String message,
    required String confirmLabel,
    required bool discardResult,
    required bool confirmResult,
  }) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white54),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _dialogAction(
                    context: context,
                    label: 'Discard',
                    color: AppColors.deleteAction,
                    foregroundColor: Colors.white,
                    result: discardResult,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _dialogAction(
                    context: context,
                    label: confirmLabel,
                    color: AppColors.noteGreen,
                    foregroundColor: AppColors.background,
                    result: confirmResult,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogAction({
    required BuildContext context,
    required String label,
    required Color color,
    required Color foregroundColor,
    required bool result,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: TextButton(
        onPressed: () => Navigator.pop(context, result),
        style: TextButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foregroundColor,
          minimumSize: const Size(0, 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.white12,
        ),
        child: Text(label),
      ),
    );
  }

  void _preview() {
    final note = widget.note;
    if (note != null) {
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => NoteReaderPage(store: widget.store, note: note),
        ),
      );
    }
  }

  Future<void> _discard() async {
    setState(() => _isSaved = true);
    _draftTimer?.cancel();
    await _draftWrite.catchError((_) {});
    await widget.store.deleteDraft(_draftId);
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }
}
