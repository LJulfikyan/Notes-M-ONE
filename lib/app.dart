import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/notes/presentation/pages/home_page.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes',
      theme: AppTheme.dark,
      home: const HomePage(),
    );
  }
}
