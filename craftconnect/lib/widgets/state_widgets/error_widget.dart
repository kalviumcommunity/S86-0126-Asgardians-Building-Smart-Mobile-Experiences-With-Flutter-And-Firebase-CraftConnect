import 'package:flutter/material.dart';

/// A comprehensive error widget that handles different types of errors
/// with user-friendly messages and retry functionality
class ErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final String? technicalDetails;
  final IconData? icon;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final ErrorType errorType;
  final bool showTechnicalDetails;

  const ErrorWidget({
    super.key,
    this.title,
    this.message,
    this.technicalDetails,
    this.icon,
    this.retryLabel = "Try Again",
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.errorType = ErrorType.general,
    this.showTechnicalDetails = false,
  });

  /// Network error widget
  const ErrorWidget.network({
    super.key,
    this.title = "Connection Error",
    this.message = "Please check your internet connection and try again.",
    this.technicalDetails,
    this.icon = Icons.wifi_off,
    this.retryLabel = "Retry",
    this.onRetry,
    this.secondaryActionLabel = "Check Settings",
    this.onSecondaryAction,
    this.errorType = ErrorType.network,
    this.showTechnicalDetails = false,
  });

  /// Server error widget
  const ErrorWidget.server({
    super.key,
    this.title = "Server Error",
    this.message = "Something went wrong on our end. Please try again later.",
    this.technicalDetails,
    this.icon = Icons.server_error,
    this.retryLabel = "Retry",
    this.onRetry,
    this.secondaryActionLabel = "Report Issue",
    this.onSecondaryAction,
    this.errorType = ErrorType.server,
    this.showTechnicalDetails = false,
  });

  /// Firebase error widget
  const ErrorWidget.firebase({
    super.key,
    this.title = "Data Error",
    this.message = "Unable to load data. Please try again.",
    this.technicalDetails,
    this.icon = Icons.cloud_off,
    this.retryLabel = "Retry",
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.errorType = ErrorType.firebase,
    this.showTechnicalDetails = false,
  });

  /// Permission error widget
  const ErrorWidget.permission({
    super.key,
    this.title = "Permission Required",
    this.message =
        "This feature requires additional permissions to work properly.",
    this.technicalDetails,
    this.icon = Icons.security,
    this.retryLabel = "Grant Permission",
    this.onRetry,
    this.secondaryActionLabel = "Go to Settings",
    this.onSecondaryAction,
    this.errorType = ErrorType.permission,
    this.showTechnicalDetails = false,
  });

  /// Timeout error widget
  const ErrorWidget.timeout({
    super.key,
    this.title = "Request Timeout",
    this.message = "The request took too long to complete. Please try again.",
    this.technicalDetails,
    this.icon = Icons.access_time,
    this.retryLabel = "Retry",
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.errorType = ErrorType.timeout,
    this.showTechnicalDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get colors based on error type
    Color iconColor;
    Color titleColor;
    Color messageColor;

    switch (errorType) {
      case ErrorType.general:
        iconColor = colorScheme.error;
        titleColor = colorScheme.onSurface;
        messageColor = colorScheme.onSurface.withOpacity(0.7);
        break;
      case ErrorType.network:
        iconColor = Colors.orange;
        titleColor = colorScheme.onSurface;
        messageColor = colorScheme.onSurface.withOpacity(0.7);
        break;
      case ErrorType.server:
        iconColor = colorScheme.error;
        titleColor = colorScheme.onSurface;
        messageColor = colorScheme.onSurface.withOpacity(0.7);
        break;
      case ErrorType.firebase:
        iconColor = Colors.blue;
        titleColor = colorScheme.onSurface;
        messageColor = colorScheme.onSurface.withOpacity(0.7);
        break;
      case ErrorType.permission:
        iconColor = Colors.amber;
        titleColor = colorScheme.onSurface;
        messageColor = colorScheme.onSurface.withOpacity(0.7);
        break;
      case ErrorType.timeout:
        iconColor = Colors.deepOrange;
        titleColor = colorScheme.onSurface;
        messageColor = colorScheme.onSurface.withOpacity(0.7);
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: iconColor,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title ?? "Something went wrong",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message ?? "An unexpected error occurred. Please try again.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: messageColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Technical Details (expandable)
            if (technicalDetails != null && showTechnicalDetails) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text("Technical Details"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(
                      technicalDetails!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: messageColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            if (onRetry != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryLabel!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              if (secondaryActionLabel != null &&
                  onSecondaryAction != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onSecondaryAction,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(secondaryActionLabel!),
                  ),
                ),
              ],
            ],

            // Show technical details toggle
            if (technicalDetails != null && !showTechnicalDetails) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _showTechnicalDetails(context);
                },
                child: const Text("Show Technical Details"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTechnicalDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Technical Details"),
        content: SingleChildScrollView(
          child: SelectableText(
            technicalDetails!,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

/// Error types for different styling and handling
enum ErrorType { general, network, server, firebase, permission, timeout }

/// A compact error widget for inline use
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final Color? color;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? theme.colorScheme.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? theme.colorScheme.error).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: color ?? theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color ?? theme.colorScheme.error,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              iconSize: 20,
              color: color ?? theme.colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated error widget with bounce animation
class AnimatedErrorWidget extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const AnimatedErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  State<AnimatedErrorWidget> createState() => _AnimatedErrorWidgetState();
}

class _AnimatedErrorWidgetState extends State<AnimatedErrorWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ErrorWidget(
          title: widget.title,
          message: widget.message,
          onRetry: widget.onRetry,
        ),
      ),
    );
  }
}

/// Utility class for converting common exceptions to user-friendly errors
class ErrorHandler {
  static ErrorWidget fromException(
    Exception exception, {
    VoidCallback? onRetry,
  }) {
    final errorString = exception.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return ErrorWidget.network(onRetry: onRetry);
    }

    if (errorString.contains('timeout')) {
      return ErrorWidget.timeout(onRetry: onRetry);
    }

    if (errorString.contains('firebase') || errorString.contains('firestore')) {
      return ErrorWidget.firebase(
        onRetry: onRetry,
        technicalDetails: exception.toString(),
      );
    }

    if (errorString.contains('permission')) {
      return ErrorWidget.permission(onRetry: onRetry);
    }

    // Default error
    return ErrorWidget(
      title: "Something went wrong",
      message: "An unexpected error occurred. Please try again.",
      technicalDetails: exception.toString(),
      onRetry: onRetry,
    );
  }

  static String getUserFriendlyMessage(Exception exception) {
    final errorString = exception.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('socket')) {
      return "Please check your internet connection and try again.";
    }

    if (errorString.contains('timeout')) {
      return "The request took too long. Please try again.";
    }

    if (errorString.contains('firebase')) {
      return "Unable to connect to our services. Please try again.";
    }

    if (errorString.contains('permission')) {
      return "Permission required to access this feature.";
    }

    return "Something went wrong. Please try again.";
  }
}
