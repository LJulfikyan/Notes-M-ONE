import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const ValueKey('editor-formatting-toolbar'),
      color: AppColors.background,
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _toolbarText('B', FontWeight.w700),
              _toolbarText('I', FontWeight.w400, italic: true),
              _toolbarText('U', FontWeight.w400, underline: true),
              _toolbarButton(Icons.link_rounded),
              _toolbarButton(Icons.format_align_left_rounded),
              _toolbarButton(Icons.format_list_bulleted_rounded),
              _toolbarButton(Icons.format_list_numbered_rounded),
              _toolbarButton(Icons.code_rounded),
              _toolbarButton(Icons.title_rounded),
              _toolbarButton(Icons.functions_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbarButton(IconData icon) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: SizedBox(
          width: 34,
          height: 48,
          child: Center(child: Icon(icon, size: 18, color: Colors.white70)),
        ),
      ),
    );
  }

  Widget _toolbarText(
    String label,
    FontWeight fontWeight, {
    bool italic = false,
    bool underline = false,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: SizedBox(
          width: 34,
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: fontWeight,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                decoration: underline
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
