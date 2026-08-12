import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HeaderButton extends StatelessWidget {
  const HeaderButton({
    super.key,
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
