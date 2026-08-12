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
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search by the keyword...',
        hintStyle: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white54),
        prefixIcon: const Icon(Icons.search_rounded, size: 19),
        suffixIcon: IconButton(
          tooltip: 'Clear search',
          onPressed: onClear,
          icon: const Icon(Icons.close_rounded, size: 18),
        ),
        filled: true,
        fillColor: AppColors.controlSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
