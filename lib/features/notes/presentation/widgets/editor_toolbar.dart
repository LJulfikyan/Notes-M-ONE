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
              _toolbarText('bold', 'B', FontWeight.w700),
              _toolbarText('italic', 'I', FontWeight.w400, italic: true),
              _toolbarText('underline', 'U', FontWeight.w400, underline: true),
              _toolbarButton('link', const Icon(Icons.link_rounded)),
              _toolbarButton(
                'strikethrough',
                const Icon(Icons.format_strikethrough),
              ),
              _toolbarButton(
                'numbered-list',
                const Icon(Icons.format_list_numbered_rounded),
              ),
              _toolbarButton(
                'bulleted-list',
                const Icon(Icons.format_list_bulleted_rounded),
              ),
              _toolbarButton('code', const Icon(Icons.code_rounded)),
              _toolbarText('text', 'T', FontWeight.w400),
              _toolbarText('sigma', 'Σ', FontWeight.w400),
              _toolbarButton('checklist', const Icon(Icons.checklist_rounded)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbarButton(String id, Icon icon) {
    return Semantics(
      button: true,
      label: id,
      child: GestureDetector(
        key: ValueKey('editor-toolbar-$id'),
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: SizedBox(
          width: 34,
          height: 48,
          child: Center(
            child: IconTheme(
              data: const IconThemeData(size: 18, color: Colors.white70),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarText(
    String id,
    String label,
    FontWeight fontWeight, {
    bool italic = false,
    bool underline = false,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        key: ValueKey('editor-toolbar-$id'),
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
