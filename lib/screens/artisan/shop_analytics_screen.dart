import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import 'package:craftconnect/config/app_constants.dart';

class ShopAnalyticsScreen extends StatefulWidget {
  const ShopAnalyticsScreen({super.key});

  @override
  State<ShopAnalyticsScreen> createState() => _ShopAnalyticsScreenState();
}

class _ShopAnalyticsScreenState extends State<ShopAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    await shopProvider.getShopsByOwner(authProvider.currentUser!.uid);

    if (shopProvider.shops.isNotEmpty) {
      final shopId = shopProvider.shops.first.shopId;
      await Future.wait([
        productProvider.getProductsByShop(shopId),
        orderProvider.getOrdersByShop(shopId),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final totalRevenue = orderProvider.completedOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );

    final totalOrders = orderProvider.orders.length;
    final totalProducts = productProvider.products.length;
    final lowStockProducts =
        productProvider.products.where((p) => p.stock < 10).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Analytics'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Stats Overview
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Revenue',
                  '₹${totalRevenue.toStringAsFixed(0)}',
                  Icons.currency_rupee,
                  AppTheme.successColor,
                ),
                _buildStatCard(
                  'Total Orders',
                  '$totalOrders',
                  Icons.shopping_bag,
                  AppTheme.primaryColor,
                ),
                _buildStatCard(
                  'Products',
                  '$totalProducts',
                  Icons.inventory_2,
                  AppTheme.accentColor,
                ),
                _buildStatCard(
                  'Low Stock',
                  '$lowStockProducts',
                  Icons.warning,
                  AppTheme.warningColor,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Order Status Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildStatusRow(
                      'New Orders',
                      orderProvider.newOrders.length,
                      totalOrders,
                      AppTheme.warningColor,
                    ),
                    _buildStatusRow(
                      'Accepted',
                      orderProvider.acceptedOrders.length,
                      totalOrders,
                      AppTheme.accentColor,
                    ),
                    _buildStatusRow(
                      'Shipped',
                      orderProvider.shippedOrders.length,
                      totalOrders,
                      Colors.blue,
                    ),
                    _buildStatusRow(
                      'Completed',
                      orderProvider.completedOrders.length,
                      totalOrders,
                      AppTheme.successColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Top Products
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...productProvider.products.take(5).map((product) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(product.name),
                        subtitle: Text('Stock: ${product.stock}'),
                        trailing: Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSpacing.sm),
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
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: total > 0 ? count / total : 0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}