import 'package:flutter/material.dart';

import '../../domain/note.dart';
import '../widgets/contained_icon_button.dart';
import 'note_editor_page.dart';
import 'note_reader_page.dart';

class NoteReaderPageState extends State<NoteReaderPage> {
  late Note _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: SizedBox(
                height: 47,
                child: Row(
                  children: [
                    ContainedIconButton(
                      key: const ValueKey('reader-back-control'),
                      tooltip: 'Back',
                      icon: Icons.chevron_left_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                      size: 47,
                      iconSize: 25,
                    ),
                    const Spacer(),
                    ContainedIconButton(
                      key: const ValueKey('reader-edit-control'),
                      tooltip: 'Edit note',
                      icon: Icons.edit_rounded,
                      onPressed: _edit,
                      size: 47,
                      iconSize: 21,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                key: const ValueKey('reader-scroll-view'),
                padding: const EdgeInsets.fromLTRB(23, 0, 23, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _note.title,
                      key: const ValueKey('reader-title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _note.body,
                      key: const ValueKey('reader-body'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(store: widget.store, note: _note),
      ),
    );
    if (!mounted) return;
    for (final note in widget.store.notes) {
      if (note.id == _note.id) {
        setState(() => _note = note);
        break;
      }
    }
  }
}
