import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NotesInfoDialog extends StatelessWidget {
  const NotesInfoDialog({super.key});

  static const barrierColor = Color(0x80696969);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        key: const ValueKey('notes-info-dialog'),
        constraints: const BoxConstraints(maxWidth: 313),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Notes',
                key: ValueKey('notes-info-title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Notes are stored locally on this device.\n\n'
                'Swipe right to reveal Favorite.\n'
                'Swipe left to reveal Delete.\n\n'
                'Use All, Favorites, and Recent to filter notes.',
                key: ValueKey('notes-info-body'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 26),
              Semantics(
                button: true,
                label: 'Got it',
                child: SizedBox(
                  key: const ValueKey('notes-info-close-action'),
                  width: 105,
                  height: 37,
                  child: Material(
                    color: const Color(0xFF30BF71),
                    borderRadius: BorderRadius.circular(5),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(5),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.white12,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: const Center(
                        child: Text(
                          'Got it',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
