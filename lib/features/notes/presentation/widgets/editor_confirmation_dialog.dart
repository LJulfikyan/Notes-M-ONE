import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EditorConfirmationDialog extends StatelessWidget {
  const EditorConfirmationDialog({
    super.key,
    required this.message,
    required this.confirmLabel,
    required this.discardResult,
    required this.confirmResult,
  });

  final String message;
  final String confirmLabel;
  final bool discardResult;
  final bool confirmResult;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        key: const ValueKey('editor-confirmation-dialog'),
        width: double.infinity,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 225),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white54,
                  size: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _action(
                      context: context,
                      label: 'Discard',
                      color: AppColors.deleteAction,
                      foregroundColor: Colors.white,
                      result: discardResult,
                    ),
                    _action(
                      context: context,
                      label: confirmLabel,
                      color: AppColors.noteGreen,
                      foregroundColor: AppColors.background,
                      result: confirmResult,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _action({
    required BuildContext context,
    required String label,
    required Color color,
    required Color foregroundColor,
    required bool result,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        key: ValueKey('dialog-${label.toLowerCase()}-action'),
        width: 105,
        height: 37,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(5),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.pop(context, result),
            splashColor: Colors.transparent,
            highlightColor: Colors.white12,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
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
    );
  }
}
