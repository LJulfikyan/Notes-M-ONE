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
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: NoteFilter.values
          .map(
            (filter) => NoteFilterChip(
              label: switch (filter) {
                NoteFilter.all => 'All',
                NoteFilter.favorites => 'Favorites',
                NoteFilter.recent => 'Recent',
              },
              selected: selected == filter,
              onTap: () => onSelected(filter),
            ),
          )
          .toList(growable: false),
    );
  }
}
