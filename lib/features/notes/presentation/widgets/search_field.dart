import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(23));
    return SizedBox(
      key: const ValueKey('search-field-surface'),
      height: 45,
      child: Material(
        color: AppColors.controlSurface,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            const SizedBox(width: 32),
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: true,
                onChanged: onChanged,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.search,
                cursorColor: Colors.white70,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.2,
                  letterSpacing: 0,
                ),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Search by the keyword...',
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            Tooltip(
              message: 'Clear search',
              child: Semantics(
                button: true,
                label: 'Clear search',
                child: SizedBox(
                  width: 60,
                  height: 45,
                  child: InkWell(
                    onTap: onClear,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.white10,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    child: const Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
