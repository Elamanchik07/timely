import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppToast {
  static void success(BuildContext context, String message, {VoidCallback? onRetry}) {
    _show(context, message, Icons.check_circle_rounded, AppTheme.successColor, onRetry: onRetry);
  }

  static void error(BuildContext context, String message, {VoidCallback? onRetry}) {
    _show(context, message, Icons.error_outline_rounded, AppTheme.errorColor, onRetry: onRetry);
  }

  static void info(BuildContext context, String message, {VoidCallback? onRetry}) {
    _show(context, message, Icons.info_outline_rounded, AppTheme.accent, onRetry: onRetry);
  }

  static void _show(BuildContext context, String message, IconData icon, Color color, {VoidCallback? onRetry}) {
    final scaffold = ScaffoldMessenger.maybeOf(context);
    if (scaffold == null) return;

    scaffold.clearSnackBars();
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        elevation: 6,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'ПОВТОРИТЬ',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}
