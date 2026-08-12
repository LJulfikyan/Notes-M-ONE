import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../domain/note.dart';
import '../stores/notes_store.dart';
import '../widgets/no_search_results_view.dart';
import '../widgets/note_card.dart';
import '../widgets/search_field.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.store});

  final NotesStore store;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    widget.store.setSearchQuery('');
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    widget.store.setSearchQuery('');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: SearchField(
                controller: _controller,
                onChanged: widget.store.setSearchQuery,
                onClear: _clearQuery,
              ),
            ),
            Expanded(
              child: Observer(
                builder: (context) {
                  final query = widget.store.searchQuery.trim();
                  if (query.isEmpty) {
                    return const SizedBox.expand();
                  }
                  final results = widget.store.searchResults;
                  if (results.isEmpty) {
                    return const NoSearchResultsView();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => NoteCard(
                      note: results[index],
                      onTap: () => _openReaderPlaceholder(results[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearQuery() {
    _controller.clear();
    widget.store.setSearchQuery('');
  }

  void _openReaderPlaceholder(Note note) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(note.title)),
          body: const Center(child: Text('Note reader')),
        ),
      ),
    );
  }
}
