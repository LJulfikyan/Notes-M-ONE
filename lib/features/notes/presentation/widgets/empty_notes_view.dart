import 'package:flutter/material.dart';

class EmptyNotesView extends StatelessWidget {
  const EmptyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = (constraints.maxWidth * 0.72).clamp(180.0, 280.0);
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/empty_notes.png',
                  width: imageSize,
                  height: imageSize,
                ),
                const SizedBox(height: 4),
                Text(
                  'Create your first note !',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
