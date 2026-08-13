import 'package:flutter/material.dart';

import 'embedded_raster_svg.dart';

class EmptyNotesView extends StatelessWidget {
  const EmptyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = (constraints.maxWidth * 320 / 393).clamp(0.0, 320.0);
        final imageHeight = imageWidth * 287 / 350;
        final top = (constraints.maxHeight * 159 / 732).clamp(72.0, 159.0);
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: top, bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  key: const ValueKey('empty-notes-illustration'),
                  width: imageWidth,
                  height: imageHeight,
                  child: const EmbeddedRasterSvg(
                    assetPath: 'assets/images/empty_notes.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 19),
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
