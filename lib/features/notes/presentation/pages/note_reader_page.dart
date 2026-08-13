import 'package:flutter/material.dart';

import '../../domain/note.dart';
import '../stores/notes_store.dart';
import 'note_reader_page_state.dart';

class NoteReaderPage extends StatefulWidget {
  const NoteReaderPage({super.key, required this.store, required this.note});

  final NotesStore store;
  final Note note;

  @override
  State<NoteReaderPage> createState() => NoteReaderPageState();
}
