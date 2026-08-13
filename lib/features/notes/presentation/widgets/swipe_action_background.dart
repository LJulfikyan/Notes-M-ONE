import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SwipeActionBackground extends StatelessWidget {
  const SwipeActionBackground({
    super.key,
    required this.offset,
    required this.favoriteActionWidth,
    required this.onAction,
  });

  final double offset;
  final double favoriteActionWidth;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    if (offset == 0) return const SizedBox.expand();

    final isFavorite = offset > 0;
    final action = Semantics(
      button: true,
      label: isFavorite ? 'Toggle favorite' : 'Delete note',
      child: GestureDetector(
        key: ValueKey('swipe-${isFavorite ? 'favorite' : 'delete'}-action'),
        behavior: HitTestBehavior.opaque,
        onTap: onAction,
        child: ColoredBox(
          key: ValueKey(
            'swipe-${isFavorite ? 'favorite' : 'delete'}-background',
          ),
          color: isFavorite ? AppColors.favoriteAction : AppColors.deleteAction,
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                color: isFavorite ? AppColors.background : Colors.white,
                size: 28,
              ),
              child: isFavorite
                  ? const Icon(Icons.star_border_rounded)
                  : const Icon(Icons.delete_outline),
            ),
          ),
        ),
      ),
    );

    if (!isFavorite) return action;
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: favoriteActionWidth,
        height: double.infinity,
        child: action,
      ),
    );
  }
}
