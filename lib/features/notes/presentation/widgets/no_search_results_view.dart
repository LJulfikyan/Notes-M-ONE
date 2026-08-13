import 'package:flutter/material.dart';

import 'embedded_raster_svg.dart';

class NoSearchResultsView extends StatelessWidget {
  const NoSearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = (constraints.maxWidth * 320 / 393).clamp(0.0, 320.0);
        final imageHeight = imageWidth * 240 / 370;
        final top = (constraints.maxHeight * 256 / 763).clamp(72.0, 256.0);
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, top, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EmbeddedRasterSvg(
                  assetPath: 'assets/images/search_no_results.svg',
                  width: imageWidth,
                  height: imageHeight,
                ),
                const SizedBox(height: 18),
                const Text(
                  'File not found. Try searching again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
