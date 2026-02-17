import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<OrderProvider>(context, listen: false).getAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Analytics')),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = orderProvider.orders;
          final totalRevenue = orderProvider.completedOrders.fold<double>(
            0,
            (sum, order) => sum + order.totalAmount,
          );

          if (orders.isEmpty) {
            return const Center(child: Text('No order data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRevenueCard(totalRevenue),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Order Status Breakdown',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildStatusSection(orderProvider),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Recent Platform Activity',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ...orders
                    .take(10)
                    .map((order) => _buildRecentOrderTile(context, order)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueCard(double revenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppDecorations.gradientDecoration,
      child: Column(
        children: [
          const Text(
            'Total Platform Revenue',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '₹${revenue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Across all completed orders',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(OrderProvider orderProvider) {
    return Column(
      children: [
        _buildStatusRow(
          'New Orders',
          orderProvider.newOrders.length,
          AppTheme.warningColor,
        ),
        _buildStatusRow(
          'Processing',
          orderProvider.acceptedOrders.length,
          AppTheme.accentColor,
        ),
        _buildStatusRow(
          'In Transit',
          orderProvider.shippedOrders.length,
          Colors.blue,
        ),
        _buildStatusRow(
          'Completed',
          orderProvider.completedOrders.length,
          AppTheme.successColor,
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderTile(BuildContext context, OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: AppDecorations.cardDecoration,
      child: ListTile(
        onTap: () => context.push('/track-order/${order.orderId}'),
        title: Text('Order #${order.orderId.substring(0, 8)}'),
        subtitle: Text('${order.buyerName} • ₹${order.totalAmount}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            order.statusText,
            style: TextStyle(
              color: _getStatusColor(order.status),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
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
}
