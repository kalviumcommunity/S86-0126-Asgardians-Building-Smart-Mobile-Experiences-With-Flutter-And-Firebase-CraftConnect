import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../providers/order_provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/order_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
    });
  }

  Future<void> _loadOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.getOrderById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
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

          return RefreshIndicator(
            onRefresh: _loadOrder,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Order Status Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getStatusIcon(order.status),
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          order.statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
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

                  const SizedBox(height: AppSpacing.xl),

                  // Order Timeline
                  _buildTimeline(order.status),

                  const SizedBox(height: AppSpacing.xl),

                  // Order Details
                  Container(
                    decoration: AppDecorations.cardDecoration,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Divider(height: AppSpacing.lg),
                        _buildDetailRow('Quantity', '${order.quantity}'),
                        _buildDetailRow('Total Amount',
                            '₹${order.totalAmount.toStringAsFixed(0)}'),
                        _buildDetailRow(
                            'Payment Status', order.paymentStatusText),
                        _buildDetailRow(
                            'Order Date', _formatDate(order.createdAt)),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Delivery Address
                  Container(
                    decoration: AppDecorations.cardDecoration,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on,
                                color: AppTheme.primaryColor),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                order.buyerAddress,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Help Section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: AppTheme.accentColor,
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Need help with your order?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _showContactShopBottomSheet(context, order),
                                icon: const Icon(Icons.phone),
                                label: const Text('Contact Shop'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            // Return button (only for completed orders)
                            if (order.status == OrderStatus.completed)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => context
                                      .go('/return-request/${order.orderId}'),
                                  icon: const Icon(Icons.keyboard_return),
                                  label: const Text('Return'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.warningColor,
                                  ),
                                ),
                              ),
                            // Cancel button (only for new or accepted orders)
                            if (order.status == OrderStatus.newOrder ||
                                order.status == OrderStatus.accepted)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _cancelOrder(context, order),
                                  icon: const Icon(Icons.cancel_outlined),
                                  label: const Text('Cancel'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(OrderStatus currentStatus) {
    final statuses = [
      OrderStatus.newOrder,
      OrderStatus.accepted,
      OrderStatus.shipped,
      OrderStatus.completed,
    ];

    final currentIndex = statuses.indexOf(currentStatus);

    return Column(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isCompleted = index <= currentIndex;
        final isLast = index == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor
                        : AppTheme.backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.successColor
                          : AppTheme.textSecondaryColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.circle,
                    color: isCompleted
                        ? Colors.white
                        : AppTheme.textSecondaryColor,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? AppTheme.successColor
                        : AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontWeight:
                            isCompleted ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 16,
                        color: isCompleted
                            ? AppTheme.textPrimaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                    if (isCompleted)
                      Text(
                        _getStatusDescription(status),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Order Accepted';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.completed:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'Your order has been placed';
      case OrderStatus.accepted:
        return 'Artisan has accepted your order';
      case OrderStatus.shipped:
        return 'Your order is on the way';
      case OrderStatus.completed:
        return 'Order delivered successfully';
      case OrderStatus.cancelled:
        return 'Order was cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _cancelOrder(BuildContext context, OrderModel order) async {
    // Capture these before any async gaps
    final messenger = ScaffoldMessenger.of(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel Order',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await orderProvider.cancelOrderByBuyer(order.orderId);

      if (!mounted) return;
      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully')),
        );
        // Reload order to get updated status
        await _loadOrder();
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              orderProvider.errorMessage ?? 'Failed to cancel order',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showContactShopBottomSheet(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContactShopBottomSheet(order: order),
    );
  }
}

class ContactShopBottomSheet extends StatefulWidget {
  final OrderModel order;

  const ContactShopBottomSheet({super.key, required this.order});

  @override
  State<ContactShopBottomSheet> createState() => _ContactShopBottomSheetState();
}

class _ContactShopBottomSheetState extends State<ContactShopBottomSheet> {
  bool _isLoading = true;
  String? _shopName;
  String? _shopPhone;
  String? _shopEmail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadShopDetails();
  }

  Future<void> _loadShopDetails() async {
    try {
      final shopProvider = context.read<ShopProvider>();
      final shop = await shopProvider.getShopById(widget.order.shopId);

      if (shop != null && mounted) {
        setState(() {
          _shopName = shop.businessName;
          _shopPhone = shop.contactPhone;
          _shopEmail = shop.contactEmail;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Shop information not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load shop details';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to make phone call')),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Order Inquiry - ${widget.order.orderId}',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open email client')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Contact Shop',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.grey[600], size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Shop info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _shopName ?? 'Unknown Shop',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order: ${widget.order.orderId}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contact options
            if (_shopPhone?.isNotEmpty == true)
              _buildContactOption(
                icon: Icons.phone,
                title: 'Call Shop',
                subtitle: _shopPhone!,
                onTap: () => _makePhoneCall(_shopPhone!),
              ),

            if (_shopEmail?.isNotEmpty == true)
              _buildContactOption(
                icon: Icons.email,
                title: 'Send Email',
                subtitle: _shopEmail!,
                onTap: () => _sendEmail(_shopEmail!),
              ),

            if (_shopPhone?.isEmpty == true && _shopEmail?.isEmpty == true)
              Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.contact_support_outlined,
                          color: Colors.grey[600], size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'No contact information available',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],

          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
