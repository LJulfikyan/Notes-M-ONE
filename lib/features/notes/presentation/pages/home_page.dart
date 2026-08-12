import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../core/theme/app_colors.dart';
import '../stores/notes_store.dart';
import '../widgets/empty_notes_view.dart';
import '../widgets/note_card.dart';
import '../widgets/note_filter_bar.dart';

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
          _HeaderButton(
            icon: Icons.search_rounded,
            label: 'Search notes',
            onPressed: () {},
          ),
          const SizedBox(width: 6),
          _HeaderButton(
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
                Expanded(
                  child: _NotesList(
                    store: widget.store,
                    isFilterVisible: _filtersVisible,
                  ),
                ),
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

class _NotesList extends StatelessWidget {
  const _NotesList({required this.store, required this.isFilterVisible});

  final NotesStore store;
  final bool isFilterVisible;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final notes = store.filteredNotes;
        if (notes.isEmpty) {
          return const SizedBox.expand();
        }
        return ListView.separated(
          key: ValueKey('notes-list-$isFilterVisible'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: notes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              NoteCard(note: notes[index], onTap: () {}),
        );
      },
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.controlSurface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Semantics(
          button: true,
          label: label,
          child: SizedBox(width: 30, height: 30, child: Icon(icon, size: 18)),
        ),
      ),
    );
  }
}
