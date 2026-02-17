import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/shop_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    await Future.wait([
      shopProvider.getAllShops(),
      productProvider.getAllProducts(),
      orderProvider.getAllOrders(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final totalRevenue = orderProvider.completedOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Platform Overview',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    'Artisans',
                    shopProvider.shops.length.toString(),
                    Icons.storefront,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    'Products',
                    productProvider.products.length.toString(),
                    Icons.inventory_2,
                    AppTheme.accentColor,
                  ),
                  _buildStatCard(
                    'Orders',
                    orderProvider.orders.length.toString(),
                    Icons.shopping_cart,
                    AppTheme.warningColor,
                  ),
                  _buildStatCard(
                    'Revenue',
                    '₹${totalRevenue.toStringAsFixed(0)}',
                    Icons.payments,
                    AppTheme.successColor,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                'Management',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildMenuTile(
                context,
                'Artisan Management',
                'Approve, monitor and manage artisans',
                Icons.people_alt,
                () => context.go('/admin/artisans'),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildMenuTile(
                context,
                'User Management',
                'Manage users, suspend/activate accounts',
                Icons.admin_panel_settings,
                () => context.go('/admin/users'),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildMenuTile(
                context,
                'Return Requests',
                'Review and manage product returns',
                Icons.keyboard_return,
                () => context.go('/admin/returns'),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildMenuTile(
                context,
                'Coupon Management',
                'Create, edit and manage discount coupons',
                Icons.local_offer,
                () => context.go('/admin/coupons'),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildMenuTile(
                context,
                'Review Moderation',
                'Monitor and moderate product reviews',
                Icons.rate_review,
                () => context.go('/admin/reviews'),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildMenuTile(
                context,
                'Order Analytics',
                'Detailed platform sales and performance',
                Icons.analytics,
                () => context.go('/admin/analytics'),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildMenuTile(
                context,
                'System Logs',
                'Monitor system activities and errors',
                Icons.terminal,
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logs module coming soon!')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
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
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: AppDecorations.cardDecoration,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
