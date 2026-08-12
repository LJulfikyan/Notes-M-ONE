import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SwipeActionBackground extends StatelessWidget {
  const SwipeActionBackground({super.key, required this.offset});

  final double offset;

  @override
  Widget build(BuildContext context) {
    final isFavorite = offset >= 0;
    return ColoredBox(
      color: isFavorite ? AppColors.favoriteAction : AppColors.deleteAction,
      child: Align(
        alignment: isFavorite ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Icon(
            isFavorite ? Icons.star_border_rounded : Icons.delete_outline,
            color: isFavorite ? AppColors.background : Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
