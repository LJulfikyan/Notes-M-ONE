import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../pages/note_reader_page.dart';
import '../stores/notes_store.dart';
import 'swipe_note_tile.dart';

class NotesList extends StatefulWidget {
  const NotesList({super.key, required this.store});

  final NotesStore store;

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  final _openNoteId = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _openNoteId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final notes = widget.store.filteredNotes;
        if (notes.isEmpty) return const SizedBox.expand();
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(23, 8, 22, 120),
          itemCount: notes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final note = notes[index];
            return SwipeNoteTile(
              key: ValueKey('swipe-note-${note.id}'),
              note: note,
              openNoteId: _openNoteId,
              onDelete: () => widget.store.delete(note.id),
              onToggleFavorite: () => widget.store.toggleFavorite(note),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) =>
                      NoteReaderPage(store: widget.store, note: note),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
