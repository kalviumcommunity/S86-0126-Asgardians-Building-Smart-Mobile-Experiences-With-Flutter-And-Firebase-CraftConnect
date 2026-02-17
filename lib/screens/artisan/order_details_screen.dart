import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'package:craftconnect/config/app_constants.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.getOrderById(widget.orderId);
  }

  Future<void> _updateStatus(OrderStatus newStatus) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final success =
        await orderProvider.updateOrderStatus(widget.orderId, newStatus);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order status updated!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _callBuyer(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.order_details),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = orderProvider.currentOrder;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getStatusIcon(order.status),
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        order.statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Order #${order.orderId.substring(0, 8)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Buyer Information
                _buildInfoCard(
                  'Buyer Information',
                  [
                    _buildInfoRow(Icons.person, 'Name', order.buyerName),
                    _buildInfoRow(Icons.phone, 'Phone', order.buyerPhone,
                        onTap: () => _callBuyer(order.buyerPhone)),
                    _buildInfoRow(
                        Icons.location_on, 'Address', order.buyerAddress),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Order Details
                _buildInfoCard(
                  'Order Details',
                  [
                    _buildInfoRow(
                        Icons.shopping_cart, 'Quantity', '${order.quantity}'),
                    _buildInfoRow(Icons.currency_rupee, 'Total Amount',
                        '₹${order.totalAmount.toStringAsFixed(0)}'),
                    _buildInfoRow(Icons.payment, 'Payment Status',
                        order.paymentStatusText),
                    if (order.upiId != null)
                      _buildInfoRow(
                          Icons.account_balance, 'UPI ID', order.upiId!),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Action Buttons
                if (order.status == OrderStatus.newOrder) ...[
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(OrderStatus.accepted),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Accept Order'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => _updateStatus(OrderStatus.cancelled),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Reject Order'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: AppTheme.errorColor,
                    ),
                  ),
                ],

                if (order.status == OrderStatus.accepted)
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(OrderStatus.shipped),
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('Mark as Shipped'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                if (order.status == OrderStatus.shipped)
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(OrderStatus.completed),
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark as Completed'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.successColor,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      decoration: AppDecorations.cardDecoration,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondaryColor),
          ],
        ),
      ),
    );
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