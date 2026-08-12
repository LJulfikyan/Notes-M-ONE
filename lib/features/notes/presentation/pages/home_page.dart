import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../core/theme/app_colors.dart';
import '../stores/notes_store.dart';
import '../widgets/empty_notes_view.dart';
import '../widgets/header_button.dart';
import '../widgets/note_filter_bar.dart';
import '../widgets/notes_list.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.store});

  final NotesStore store;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _filtersVisible = false;

  @override
  void initState() {
    super.initState();
    widget.store.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        actions: [
          HeaderButton(
            icon: Icons.search_rounded,
            label: 'Search notes',
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => SearchPage(store: widget.store),
              ),
            ),
          ),
          const SizedBox(width: 6),
          HeaderButton(
            icon: Icons.info_outline_rounded,
            label: 'Show filters',
            onPressed: () => setState(() => _filtersVisible = !_filtersVisible),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Observer(
          builder: (context) {
            if (widget.store.isLoading && widget.store.notes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (widget.store.notes.isEmpty) {
              return const EmptyNotesView();
            }
            return Column(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.topCenter,
                  child: _filtersVisible
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                          child: NoteFilterBar(
                            selected: widget.store.filter,
                            onSelected: widget.store.setFilter,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Expanded(child: NotesList(store: widget.store)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {},
        tooltip: 'Create note',
        backgroundColor: AppColors.notePurple,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
