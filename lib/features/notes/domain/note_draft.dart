import 'note_color.dart';

class NoteDraft {
  const NoteDraft({
    required this.id,
    this.noteId,
    required this.title,
    required this.body,
    required this.color,
    required this.isFavorite,
    required this.updatedAt,
  });

  final String id;
  final int? noteId;
  final String title;
  final String body;
  final NoteColor color;
  final bool isFavorite;
  final DateTime updatedAt;
}
