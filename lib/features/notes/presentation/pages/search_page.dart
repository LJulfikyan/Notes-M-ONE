import 'package:flutter/material.dart';

import '../stores/notes_store.dart';
import 'search_page_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.store});

  final NotesStore store;

  @override
  State<SearchPage> createState() => SearchPageState();
}
