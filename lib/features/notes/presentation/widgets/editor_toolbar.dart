import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      height: 56,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toolbarButton(Icons.format_bold),
          _toolbarButton(Icons.format_italic),
          _toolbarButton(Icons.format_underlined),
          _toolbarButton(Icons.link),
          _toolbarButton(Icons.format_list_bulleted),
        ],
      ),
    );
  }

  Widget _toolbarButton(IconData icon) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      color: Colors.white70,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 40),
    );
  }
}
