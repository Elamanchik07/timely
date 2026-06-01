import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shimmer skeleton loading widget for a premium loading experience.
class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const ShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  }) : shape = BoxShape.rectangle;

  const ShimmerWidget.circular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 0,
  }) : shape = BoxShape.circle;

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(widget.borderRadius)
                : null,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                AppTheme.surfaceColor,
                AppTheme.surfaceColor.withOpacity(0.5),
                AppTheme.surfaceColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// News card skeleton for loading state
class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar row
          Row(
            children: [
              const ShimmerWidget.circular(width: 44, height: 44),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerWidget.rectangular(height: 14, width: 120),
                  SizedBox(height: 6),
                  ShimmerWidget.rectangular(height: 10, width: 80),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Text lines
          const ShimmerWidget.rectangular(height: 16, width: double.infinity),
          const SizedBox(height: 8),
          const ShimmerWidget.rectangular(height: 16, width: 250),
          const SizedBox(height: 16),
          // Image placeholder
          const ShimmerWidget.rectangular(height: 200, borderRadius: 16),
          const SizedBox(height: 16),
          // Reactions row
          Row(
            children: const [
              ShimmerWidget.rectangular(height: 28, width: 70, borderRadius: 14),
              SizedBox(width: 12),
              ShimmerWidget.rectangular(height: 28, width: 70, borderRadius: 14),
            ],
          ),
        ],
      ),
    );
  }
}
