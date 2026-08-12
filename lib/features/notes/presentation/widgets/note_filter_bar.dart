import 'package:flutter/material.dart';

import '../../domain/note_filter.dart';
import 'note_filter_chip.dart';

class NoteFilterBar extends StatelessWidget {
  const NoteFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NoteFilter selected;
  final ValueChanged<NoteFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          NoteFilterChip(
            label: 'All',
            width: 50,
            selected: selected == NoteFilter.all,
            onTap: () => onSelected(NoteFilter.all),
          ),
          const SizedBox(width: 9),
          NoteFilterChip(
            label: 'Favorites',
            width: 94,
            selected: selected == NoteFilter.favorites,
            onTap: () => onSelected(NoteFilter.favorites),
          ),
          const SizedBox(width: 8),
          NoteFilterChip(
            label: 'Recent',
            width: 78,
            selected: selected == NoteFilter.recent,
            onTap: () => onSelected(NoteFilter.recent),
          ),
        ],
      ),
    );
  }
}
