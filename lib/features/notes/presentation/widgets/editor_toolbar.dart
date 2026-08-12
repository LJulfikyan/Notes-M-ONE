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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.format_bold, size: 18),
          ),
          SizedBox(width: 14),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.format_italic, size: 18),
          ),
          SizedBox(width: 14),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.format_underlined, size: 18),
          ),
          SizedBox(width: 14),
          IconButton(onPressed: () {}, icon: const Icon(Icons.link, size: 18)),
          SizedBox(width: 14),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.format_list_bulleted, size: 18),
          ),
        ],
      ),
    );
  }
}
