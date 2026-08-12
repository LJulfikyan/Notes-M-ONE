import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../stores/notes_store.dart';
import '../pages/note_reader_page.dart';
import 'swipe_note_tile.dart';

class NotesList extends StatelessWidget {
  const NotesList({super.key, required this.store});

  final NotesStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final notes = store.filteredNotes;
        if (notes.isEmpty) {
          return const SizedBox.expand();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: notes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final note = notes[index];
            return SwipeNoteTile(
              key: ValueKey('swipe-note-${note.id}'),
              note: note,
              onDelete: () => store.delete(note.id),
              onToggleFavorite: () => store.toggleFavorite(note),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => NoteReaderPage(store: store, note: note),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
