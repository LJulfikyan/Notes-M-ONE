import 'package:flutter/material.dart';

import '../stores/notes_store.dart';
import 'home_page_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.store});

  final NotesStore store;

  @override
  State<HomePage> createState() => HomePageState();
}
