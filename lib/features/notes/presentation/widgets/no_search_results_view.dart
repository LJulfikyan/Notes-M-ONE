import 'package:flutter/material.dart';

class NoSearchResultsView extends StatelessWidget {
  const NoSearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = (constraints.maxWidth * 0.78).clamp(180.0, 300.0);
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/search_no_results.png',
                  width: imageSize,
                  height: imageSize,
                ),
                const SizedBox(height: 8),
                Text(
                  'File not found. Try searching again.',
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
