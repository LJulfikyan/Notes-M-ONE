import 'package:flutter/material.dart';

import '../../domain/note.dart';
import '../stores/notes_store.dart';
import '../widgets/contained_icon_button.dart';
import 'note_editor_page.dart';

class NoteReaderPage extends StatelessWidget {
  const NoteReaderPage({super.key, required this.store, required this.note});

  final NotesStore store;
  final Note note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ContainedIconButton(
          tooltip: 'Back',
          icon: Icons.chevron_left_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          ContainedIconButton(
            tooltip: 'Edit note',
            icon: Icons.edit_rounded,
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => NoteEditorPage(store: store, note: note),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Text(note.body, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
