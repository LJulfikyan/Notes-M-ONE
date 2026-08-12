import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/note_filter.dart';

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
      spacing: 8,
      runSpacing: 8,
      children: NoteFilter.values
          .map(
            (filter) => _FilterChip(
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.favoriteAction : AppColors.controlSurface,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected ? AppColors.background : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
