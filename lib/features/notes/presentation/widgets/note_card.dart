import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/note.dart';
import '../../domain/note_color.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  final Note note;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _colorFor(note.color),
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                if (note.isFavorite) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.star_border_rounded,
                    key: ValueKey('note-card-favorite-${note.id}'),
                    color: const Color(0xFF252525),
                    size: 24,
                  ),
                ],
              ],
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
