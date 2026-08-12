import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ContainedIconButton extends StatelessWidget {
  const ContainedIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor = AppColors.controlSurface,
    this.foregroundColor = Colors.white,
    this.size = 30,
    this.iconSize = 18,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double size;
  final double iconSize;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        enabled: onPressed != null,
        child: SizedBox(
          width: size,
          height: size,
          child: Material(
            color: backgroundColor,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              borderRadius: borderRadius,
              splashColor: Colors.transparent,
              highlightColor: Colors.white12,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: onPressed == null ? Colors.white38 : foregroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
