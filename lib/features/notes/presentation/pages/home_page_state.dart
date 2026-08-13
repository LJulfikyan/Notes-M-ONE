import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/empty_notes_view.dart';
import '../widgets/header_button.dart';
import '../widgets/note_filter_bar.dart';
import '../widgets/notes_list.dart';
import 'home_page.dart';
import 'note_editor_page.dart';
import 'search_page.dart';

class HomePageState extends State<HomePage> {
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
        toolbarHeight: 120,
        titleSpacing: 23,
        title: const Text('Notes'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.w500,
          height: 1,
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
          const SizedBox(width: 19),
          HeaderButton(
            icon: Icons.info_outline_rounded,
            label: 'Show filters',
            onPressed: () => setState(() => _filtersVisible = !_filtersVisible),
          ),
          const SizedBox(width: 23),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Observer(
          builder: (context) {
            if (widget.store.isLoading && widget.store.notes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (widget.store.notes.isEmpty) return const EmptyNotesView();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.topLeft,
                  child: _filtersVisible
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(23, 8, 23, 12),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 7, bottom: 7),
        child: SizedBox.square(
          dimension: 66,
          child: FloatingActionButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => NoteEditorPage(store: widget.store),
              ),
            ),
            tooltip: 'Create note',
            backgroundColor: AppColors.notePurple,
            foregroundColor: Colors.white,
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, size: 32),
          ),
        ),
      ),
    );
  }
}
