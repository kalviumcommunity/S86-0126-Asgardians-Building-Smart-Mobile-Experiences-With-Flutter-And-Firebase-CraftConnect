import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/app_constants.dart';

/// A reusable empty state widget with icon and message
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.2),
                    AppTheme.secondaryColor.withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),

            // Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states for common scenarios
class EmptyStates {
  static Widget cart({VoidCallback? onShopNow}) => EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        message: 'Add some beautiful handcrafted items to get started!',
        actionLabel: 'Start Shopping',
        onAction: onShopNow,
      );

  static Widget orders() => const EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No orders yet',
        message:
            'Your order history will appear here once you make your first purchase.',
      );

  static Widget products({VoidCallback? onAddProduct}) => EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'No products yet',
        message: 'Create your first product to start selling!',
        actionLabel: 'Add Product',
        onAction: onAddProduct,
      );

  static Widget shops({VoidCallback? onCreateShop}) => EmptyStateWidget(
        icon: Icons.store_outlined,
        title: 'No shops found',
        message: 'Be the first to create a shop and showcase your crafts!',
        actionLabel: 'Create Shop',
        onAction: onCreateShop,
      );

  static Widget search({String? query}) => EmptyStateWidget(
        icon: Icons.search_off_outlined,
        title: 'No results found',
        message: query != null
            ? 'We couldn\'t find anything matching "$query"'
            : 'Try adjusting your search terms',
      );

  static Widget favorites() => const EmptyStateWidget(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        message: 'Start adding items you love to see them here!',
      );

  static Widget error({
    String? message,
    VoidCallback? onRetry,
  }) =>
      EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Oops! Something went wrong',
        message: message ?? 'Please try again later',
        actionLabel: onRetry != null ? 'Retry' : null,
        onAction: onRetry,
      );

  static Widget noInternet({VoidCallback? onRetry}) => EmptyStateWidget(
        icon: Icons.wifi_off_outlined,
        title: 'No internet connection',
        message: 'Please check your connection and try again',
        actionLabel: 'Retry',
        onAction: onRetry,
      );
}
