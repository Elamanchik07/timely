import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimelyButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const TimelyButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Height 56px as per minimal standard
    const height = 56.0;
    final borderRadius = BorderRadius.circular(AppTheme.borderRadius);

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(height),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          side: BorderSide(color: Theme.of(context).primaryColor),
          foregroundColor: Theme.of(context).primaryColor,
        ),
        child: _buildContent(),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(height),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        elevation: 2,
        shadowColor: Theme.of(context).shadowColor,
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      );
    }
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }
}
