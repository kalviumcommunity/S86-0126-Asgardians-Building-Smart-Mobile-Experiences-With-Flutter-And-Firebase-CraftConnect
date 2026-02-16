import 'package:flutter/material.dart';

/// A comprehensive loading widget that provides different loading states
/// for various scenarios like data fetching, operations, etc.
class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool isOverlay;
  final double size;
  final Color? color;
  final LoadingType type;

  const LoadingWidget({
    super.key,
    this.message,
    this.isOverlay = false,
    this.size = 40,
    this.color,
    this.type = LoadingType.circular,
  });

  /// Show loading state for entire screen
  const LoadingWidget.fullScreen({
    super.key,
    this.message = 'Loading...',
    this.isOverlay = false,
    this.size = 50,
    this.color,
    this.type = LoadingType.circular,
  });

  /// Show loading as overlay over existing content
  const LoadingWidget.overlay({
    super.key,
    this.message = 'Please wait...',
    this.isOverlay = true,
    this.size = 40,
    this.color,
    this.type = LoadingType.circular,
  });

  /// Show inline loading for small components
  const LoadingWidget.inline({
    super.key,
    this.message,
    this.isOverlay = false,
    this.size = 24,
    this.color,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget loadingIndicator;

    switch (type) {
      case LoadingType.circular:
        loadingIndicator = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: size > 30 ? 4 : 2,
            color: color ?? theme.colorScheme.primary,
          ),
        );
        break;
      case LoadingType.linear:
        loadingIndicator = SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            color: color ?? theme.colorScheme.primary,
          ),
        );
        break;
      case LoadingType.dots:
        loadingIndicator = _DotLoadingIndicator(
          size: size,
          color: color ?? theme.colorScheme.primary,
        );
        break;
    }

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        loadingIndicator,
        if (message != null) ...[
          SizedBox(height: size > 30 ? 16 : 12),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        color: theme.colorScheme.surface.withOpacity(0.8),
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

/// Different types of loading indicators
enum LoadingType { circular, linear, dots }

/// Animated dots loading indicator
class _DotLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const _DotLoadingIndicator({required this.size, required this.color});

  @override
  State<_DotLoadingIndicator> createState() => _DotLoadingIndicatorState();
}

class _DotLoadingIndicatorState extends State<_DotLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 3,
      height: widget.size / 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animationValue = (_controller.value - (index * 0.2)).clamp(
                0.0,
                1.0,
              );
              final scale = (0.5 + 0.5 * (1 - (animationValue - 0.5).abs() * 2))
                  .clamp(0.5, 1.0);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size / 4,
                  height: widget.size / 4,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.5 + 0.5 * scale),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Shimmer loading effect for list items
class ShimmerLoading extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius,
  });

  /// Shimmer for list items
  const ShimmerLoading.listItem({
    super.key,
    this.height = 60,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  /// Shimmer for cards
  const ShimmerLoading.card({
    super.key,
    this.height = 120,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerHighest,
                theme.colorScheme.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Loading overlay that can be shown over any widget
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) LoadingWidget.overlay(message: loadingText),
      ],
    );
  }
}
