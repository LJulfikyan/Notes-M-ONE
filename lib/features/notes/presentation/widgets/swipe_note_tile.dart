import 'package:flutter/material.dart';

import '../../domain/note.dart';
import 'swipe_note_tile_state.dart';

class SwipeNoteTile extends StatefulWidget {
  const SwipeNoteTile({
    super.key,
    required this.note,
    required this.openNoteId,
    required this.onDelete,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final Note note;
  final ValueNotifier<int?> openNoteId;
  final Future<void> Function() onDelete;
  final Future<void> Function() onToggleFavorite;
  final VoidCallback onTap;

  @override
  State<SwipeNoteTile> createState() => SwipeNoteTileState();
}
