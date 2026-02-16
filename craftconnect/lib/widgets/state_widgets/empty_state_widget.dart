import 'package:flutter/material.dart';

/// A comprehensive empty state widget that provides meaningful
/// messages and actions when there's no content to display
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final EmptyStateType type;
  final Widget? customIcon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.type = EmptyStateType.general,
    this.customIcon,
  });

  /// Empty state for no tasks/items
  const EmptyStateWidget.noTasks({
    super.key,
    this.title = "No tasks yet",
    this.subtitle = "Create your first task to get started!",
    this.icon = Icons.task_outlined,
    this.actionLabel = "Add Task",
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.type = EmptyStateType.noContent,
    this.customIcon,
  });

  /// Empty state for no data/content
  const EmptyStateWidget.noData({
    super.key,
    this.title = "No data available",
    this.subtitle = "There's nothing to show right now.",
    this.icon = Icons.inbox_outlined,
    this.actionLabel = "Refresh",
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.type = EmptyStateType.noContent,
    this.customIcon,
  });

  /// Empty state for search results
  const EmptyStateWidget.noSearchResults({
    super.key,
    this.title = "No results found",
    this.subtitle = "Try adjusting your search or filters.",
    this.icon = Icons.search_off,
    this.actionLabel = "Clear Search",
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.type = EmptyStateType.search,
    this.customIcon,
  });

  /// Empty state for offline content
  const EmptyStateWidget.offline({
    super.key,
    this.title = "You're offline",
    this.subtitle = "Check your internet connection and try again.",
    this.icon = Icons.wifi_off,
    this.actionLabel = "Retry",
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.type = EmptyStateType.offline,
    this.customIcon,
  });

  /// Empty state for permissions
  const EmptyStateWidget.noPermissions({
    super.key,
    this.title = "Permission required",
    this.subtitle = "Enable permissions to access this feature.",
    this.icon = Icons.security,
    this.actionLabel = "Grant Permission",
    this.onAction,
    this.secondaryActionLabel = "Go to Settings",
    this.onSecondaryAction,
    this.type = EmptyStateType.permission,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color iconColor;
    Color titleColor;
    Color subtitleColor;

    switch (type) {
      case EmptyStateType.general:
      case EmptyStateType.noContent:
        iconColor = colorScheme.primary.withOpacity(0.6);
        titleColor = colorScheme.onSurface;
        subtitleColor = colorScheme.onSurface.withOpacity(0.7);
        break;
      case EmptyStateType.search:
        iconColor = colorScheme.outline;
        titleColor = colorScheme.onSurface;
        subtitleColor = colorScheme.onSurface.withOpacity(0.7);
        break;
      case EmptyStateType.offline:
        iconColor = colorScheme.error.withOpacity(0.7);
        titleColor = colorScheme.onSurface;
        subtitleColor = colorScheme.onSurface.withOpacity(0.7);
        break;
      case EmptyStateType.permission:
        iconColor = Colors.orange.withOpacity(0.7);
        titleColor = colorScheme.onSurface;
        subtitleColor = colorScheme.onSurface.withOpacity(0.7);
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          if (customIcon != null)
            customIcon!
          else if (icon != null)
            Icon(icon, size: 80, color: iconColor),

          const SizedBox(height: 24),

          // Title
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: subtitleColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 32),

          // Actions
          if (actionLabel != null && onAction != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(actionLabel!),
              ),
            ),

            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
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
          ] else if (actionLabel != null && onAction != null) ...[
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state types for different styling
enum EmptyStateType { general, noContent, search, offline, permission }

/// An animated empty state widget with subtle animations
class AnimatedEmptyState extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AnimatedEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),

              const SizedBox(height: 24),

              Text(
                widget.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              if (widget.subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.subtitle!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              if (widget.actionLabel != null && widget.onAction != null) ...[
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: widget.onAction,
                  icon: const Icon(Icons.add),
                  label: Text(widget.actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state for lists with illustrations
class IllustratedEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget illustration;

  const IllustratedEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Illustration
          SizedBox(height: 200, child: illustration),

          const SizedBox(height: 32),

          // Title
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
