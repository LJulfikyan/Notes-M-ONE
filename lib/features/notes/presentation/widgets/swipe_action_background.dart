import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SwipeActionBackground extends StatelessWidget {
  const SwipeActionBackground({
    super.key,
    required this.offset,
    required this.actionWidth,
    required this.onAction,
  });

  final double offset;
  final double actionWidth;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    if (offset == 0) return const SizedBox.expand();

    final isFavorite = offset > 0;
    final actionKey = ValueKey(
      'swipe-${isFavorite ? 'favorite' : 'delete'}-action',
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: isFavorite ? 0 : null,
          right: isFavorite ? null : 0,
          top: 0,
          bottom: 0,
          width: actionWidth,
          child: Semantics(
            button: true,
            label: isFavorite ? 'Toggle favorite' : 'Delete note',
            child: GestureDetector(
              key: actionKey,
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: ColoredBox(
                color: isFavorite
                    ? AppColors.favoriteAction
                    : AppColors.deleteAction,
                child: Center(
                  child: Icon(
                    isFavorite
                        ? Icons.star_border_rounded
                        : Icons.delete_outline,
                    color: isFavorite ? AppColors.background : Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
