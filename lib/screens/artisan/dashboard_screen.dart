import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../l10n/app_localizations.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../config/environment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class ArtisanDashboardScreen extends StatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  State<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends State<ArtisanDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await shopProvider.getShopsByOwner(authProvider.currentUser!.uid);

      if (shopProvider.currentShop != null && mounted) {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);

        await productProvider
            .getProductsByShop(shopProvider.currentShop!.shopId);
        await orderProvider.getOrdersByShop(shopProvider.currentShop!.shopId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${l10n.dashboard_welcome}, ${authProvider.currentUser?.name ?? ""}'),
      ),
      body: shopProvider.currentShop == null
          ? _buildNoShopView(context, l10n)
          : _buildDashboardView(context, l10n),
      floatingActionButton: shopProvider.currentShop != null
          ? FloatingActionButton.extended(
              onPressed: () {
                context.go(
                    '/artisan/add-product?shopId=${shopProvider.currentShop!.shopId}');
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.product_add),
            )
          : null,
    );
  }

  Widget _buildNoShopView(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Create Your Shop',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Start selling your amazing products by creating your digital storefront',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () => context.go('/artisan/create-shop'),
              icon: const Icon(Icons.add_business),
              label: Text(l10n.shop_create),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardView(BuildContext context, AppLocalizations l10n) {
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);

    final totalProducts = productProvider.products.length;
    final totalOrders = orderProvider.orders.length;
    final pendingOrders = orderProvider.newOrders.length;
    final revenue = orderProvider.completedOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Info Card
            Container(
              decoration: AppDecorations.gradientDecoration,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (shopProvider.currentShop?.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.network(
                            shopProvider.currentShop!.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.store,
                              color: Colors.white, size: 30),
                        ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shopProvider.currentShop?.shopName ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            InkWell(
                              onTap: () {
                                final slug =
                                    shopProvider.currentShop?.slug ?? '';
                                if (slug.isNotEmpty) {
                                  context.go('/home/shop/$slug');
                                }
                              },
                              child: const Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Visit Shop',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          final shop = shopProvider.currentShop;
                          if (shop != null) {
                            final shopUrl =
                                AppEnvironment.getShopUrl(shop.slug);
                            Share.share(
                              'Check out my shop "${shop.shopName}" on CraftConnect! 🎨✨\n\nVisit here: $shopUrl',
                              subject: 'My CraftConnect Shop',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Statistics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.5,
              children: [
                GestureDetector(
                  onTap: () => context.go(
                      '/artisan/products?shopId=${shopProvider.currentShop!.shopId}'),
                  child: _buildStatCard(
                    l10n.dashboard_totalProducts,
                    totalProducts.toString(),
                    Icons.inventory_2_outlined,
                    AppTheme.primaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/artisan/orders'),
                  child: _buildStatCard(
                    l10n.dashboard_totalOrders,
                    totalOrders.toString(),
                    Icons.shopping_bag_outlined,
                    AppTheme.accentColor,
                  ),
                ),
                _buildStatCard(
                  l10n.dashboard_pendingOrders,
                  pendingOrders.toString(),
                  Icons.pending_actions_outlined,
                  AppTheme.warningColor,
                ),
                _buildStatCard(
                  l10n.dashboard_revenue,
                  '₹${revenue.toStringAsFixed(0)}',
                  Icons.currency_rupee,
                  AppTheme.successColor,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Products',
                    Icons.inventory_2,
                    () => context.go(
                        '/artisan/products?shopId=${shopProvider.currentShop!.shopId}'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Orders',
                    Icons.list_alt,
                    () => context.go('/artisan/orders'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Analytics',
                    Icons.analytics,
                    () => context.go('/artisan/analytics'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Inventory',
                    Icons.warehouse,
                    () => context.go('/artisan/inventory'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Recent Orders
            if (orderProvider.orders.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Orders',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () => context.go('/artisan/orders'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...orderProvider.orders.take(3).map((order) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: AppDecorations.cardDecoration,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(order.status),
                      child: Icon(
                        _getStatusIcon(order.status),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(order.buyerName),
                    subtitle:
                        Text('₹${order.totalAmount} • ${order.statusText}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/artisan/order/${order.orderId}'),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: AppDecorations.cardDecoration,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return AppTheme.warningColor;
      case OrderStatus.accepted:
        return AppTheme.accentColor;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.completed:
        return AppTheme.successColor;
      case OrderStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return Icons.new_releases;
      case OrderStatus.accepted:
        return Icons.check_circle;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}
