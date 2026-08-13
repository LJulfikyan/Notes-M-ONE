import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/note.dart';
import '../../domain/note_color.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _colorFor(note.color),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 106),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  note.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF252525),
                    fontFamily: 'Nunito',
                    fontSize: 25,
                    height: 1,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _colorFor(NoteColor color) {
    return switch (color) {
      NoteColor.magenta => AppColors.noteMagenta,
      NoteColor.pink => AppColors.notePink,
      NoteColor.green => AppColors.noteGreen,
      NoteColor.yellow => AppColors.noteYellow,
      NoteColor.cyan => AppColors.noteCyan,
      NoteColor.purple => AppColors.notePurple,
    };
  }
}
