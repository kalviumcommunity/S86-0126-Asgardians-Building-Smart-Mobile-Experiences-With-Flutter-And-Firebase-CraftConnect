import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/app_constants.dart';

/// A reusable loading state widget with circular progress indicator
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (showMessage) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message ?? 'Loading...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A small inline loading indicator
class InlineLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? label;

  const InlineLoadingIndicator({
    super.key,
    this.size = 20,
    this.color,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryColor,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            label!,
            style: TextStyle(
              color: color ?? AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

/// A shimmer loading effect for list items
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: const Alignment(1, 0),
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Product card shimmer loading
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.cardDecoration,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            width: double.infinity,
            height: 150,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          ),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(width: 150, height: 16),
          SizedBox(height: AppSpacing.xs),
          ShimmerLoading(width: 100, height: 14),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(width: 80, height: 18),
        ],
      ),
    );
  }
}

/// Shop card shimmer loading
class ShopCardShimmer extends StatelessWidget {
  const ShopCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.cardDecoration,
      child: const Row(
        children: [
          ShimmerLoading(
            width: 80,
            height: 80,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(width: 120, height: 18),
                SizedBox(height: AppSpacing.xs),
                ShimmerLoading(width: double.infinity, height: 14),
                SizedBox(height: AppSpacing.xs),
                ShimmerLoading(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
