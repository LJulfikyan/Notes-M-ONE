import 'package:flutter/material.dart';

import 'contained_icon_button.dart';

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
    return Center(
      child: ContainedIconButton(
        icon: icon,
        tooltip: label,
        onPressed: onPressed,
        size: 47,
        iconSize: 21,
      ),
    );
  }
}
