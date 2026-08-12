import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NoteFilterChip extends StatelessWidget {
  const NoteFilterChip({
    super.key,
    required this.label,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(5);
    return SizedBox(
      width: width,
      height: 35,
      child: Material(
        color: selected ? AppColors.favoriteAction : AppColors.controlSurface,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: Colors.transparent,
          highlightColor: Colors.white12,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? AppColors.background : Colors.white70,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
