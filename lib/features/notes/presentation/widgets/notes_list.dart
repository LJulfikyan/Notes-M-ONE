import 'package:flutter/material.dart';

import '../stores/notes_store.dart';
import 'notes_list_state.dart';

class NotesList extends StatefulWidget {
  const NotesList({super.key, required this.store});

  final NotesStore store;

  @override
  State<NotesList> createState() => NotesListState();
}
