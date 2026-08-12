import 'note_color.dart';

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.color,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String body;
  final NoteColor color;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({
    String? title,
    String? body,
    NoteColor? color,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
