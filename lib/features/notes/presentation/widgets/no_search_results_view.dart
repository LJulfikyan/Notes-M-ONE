import 'package:flutter/material.dart';

import 'embedded_raster_svg.dart';

class NoSearchResultsView extends StatelessWidget {
  const NoSearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmbeddedRasterSvg(
              assetPath: 'assets/images/search_no_results.svg',
            ),
            const SizedBox(height: 10),
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
  }
}
