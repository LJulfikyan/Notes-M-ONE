import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../widgets/no_search_results_view.dart';
import '../widgets/note_card.dart';
import '../widgets/search_field.dart';
import 'note_reader_page.dart';
import 'search_page.dart';

class SearchPageState extends State<SearchPage> {
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
            LayoutBuilder(
              builder: (context, constraints) {
                final leftInset = (constraints.maxWidth * 30 / 393).clamp(
                  20.0,
                  30.0,
                );
                final rightInset = (constraints.maxWidth * 22 / 393).clamp(
                  16.0,
                  22.0,
                );
                return Padding(
                  padding: EdgeInsets.fromLTRB(leftInset, 32, rightInset, 0),
                  child: SearchField(
                    controller: _controller,
                    onChanged: widget.store.setSearchQuery,
                    onClear: _clearQuery,
                  ),
                );
              },
            ),
            Expanded(
              child: Observer(
                builder: (context) {
                  final query = widget.store.searchQuery.trim();
                  if (query.isEmpty) return const SizedBox.expand();
                  final results = widget.store.searchResults;
                  if (results.isEmpty) return const NoSearchResultsView();
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(23, 12, 22, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final note = results[index];
                      return NoteCard(
                        note: note,
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
}
