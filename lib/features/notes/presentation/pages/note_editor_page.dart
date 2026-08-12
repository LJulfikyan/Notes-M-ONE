import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/note.dart';
import '../../domain/note_color.dart';
import '../../domain/note_draft.dart';
import '../stores/notes_store.dart';
import '../widgets/editor_toolbar.dart';

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, required this.store, this.note});

  final NotesStore store;
  final Note? note;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  static const _draftDelay = Duration(milliseconds: 350);

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  Timer? _draftTimer;
  NoteColor? _color;
  bool _initialized = false;
  bool _isSaved = false;

  String get _draftId =>
      widget.note == null ? 'new-note' : 'note-${widget.note!.id}';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _titleController.addListener(_scheduleDraft);
    _bodyController.addListener(_scheduleDraft);
    _restoreDraft();
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    if (!_isSaved) {
      _flushDraft();
    }
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorite = widget.note?.isFavorite ?? false;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: _leave,
        ),
        actions: [
          IconButton(
            tooltip: 'Preview note',
            icon: Icon(
              favorite ? Icons.star_rounded : Icons.visibility_outlined,
            ),
            color: favorite ? AppColors.favoriteAction : Colors.white,
            onPressed: _preview,
          ),
          IconButton(
            tooltip: 'Save note',
            icon: const Icon(Icons.save_outlined),
            onPressed: _save,
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
    _color = color;
    setState(() => _initialized = true);
  }

  void _scheduleDraft() {
    if (!_initialized) {
      return;
    }
    _draftTimer?.cancel();
    _draftTimer = Timer(_draftDelay, _flushDraft);
  }

  Future<void> _flushDraft() async {
    _draftTimer?.cancel();
    if (!_initialized || _color == null) {
      return;
    }
    await widget.store.saveDraft(
      NoteDraft(
        id: _draftId,
        noteId: widget.note?.id,
        title: _titleController.text,
        body: _bodyController.text,
        color: _color!,
        isFavorite: widget.note?.isFavorite ?? false,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _save() async {
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
    _isSaved = true;
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _leave() async {
    await _flushDraft();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _preview() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Note reader'))),
      ),
    );
  }
}
