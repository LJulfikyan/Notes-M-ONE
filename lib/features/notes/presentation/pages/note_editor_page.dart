import 'package:flutter/material.dart';

import '../../domain/note.dart';
import '../stores/notes_store.dart';
import 'note_editor_page_state.dart';

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, required this.store, this.note});

  final NotesStore store;
  final Note? note;

  @override
  State<NoteEditorPage> createState() => NoteEditorPageState();
}
