import 'package:flutter/material.dart';
import '../theme/colors.dart';

abstract final class Snackbars {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppColors.successColor, Icons.check_circle_rounded);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, AppColors.errorColor, Icons.error_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.infoColor, Icons.info_rounded);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, AppColors.warningColor, Icons.warning_rounded);
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: AppColors.whiteColor)),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
