import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/contained_icon_button.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/editor_toolbar.dart';

void main() {
  testWidgets('graphical controls retain the Material icon font with Nunito', (
    tester,
  ) async {
    const graphicalIcons = <IconData>[
      Icons.search_rounded,
      Icons.info_outline_rounded,
      Icons.add_rounded,
      Icons.delete_outline,
      Icons.star_border_rounded,
      Icons.chevron_left_rounded,
      Icons.visibility_outlined,
      Icons.save_outlined,
      Icons.edit_rounded,
      Icons.close_rounded,
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Column(
            children: [
              Wrap(
                children: [
                  for (final icon in graphicalIcons)
                    ContainedIconButton(
                      icon: Icon(icon),
                      tooltip: 'Graphical control',
                      onPressed: _doNothing,
                    ),
                ],
              ),
              const EditorToolbar(),
            ],
          ),
        ),
      ),
    );

    expect(
      Theme.of(
        tester.element(find.byType(Scaffold)),
      ).textTheme.bodyMedium?.fontFamily,
      'Nunito',
    );
    expect(find.text('?'), findsNothing);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('I'), findsOneWidget);
    expect(find.text('U'), findsOneWidget);

    final renderedIcons = tester.widgetList<Icon>(find.byType(Icon)).toList();
    expect(renderedIcons.map((icon) => icon.icon), containsAll(graphicalIcons));
    expect(
      renderedIcons.map((icon) => icon.icon),
      containsAll(const <IconData>[
        Icons.link_rounded,
        Icons.format_align_left_rounded,
        Icons.format_list_bulleted_rounded,
        Icons.format_list_numbered_rounded,
        Icons.code_rounded,
        Icons.title_rounded,
        Icons.functions_rounded,
      ]),
    );
    for (final icon in renderedIcons) {
      expect(icon.icon?.fontFamily, 'MaterialIcons');
      expect(icon.icon?.fontFamily, isNot('Nunito'));
    }
  });
}

void _doNothing() {}
