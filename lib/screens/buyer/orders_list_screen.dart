import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/order_model.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  String _filterStatus = 'all';
  String _sortBy = 'newest';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await orderProvider.getOrdersByBuyer(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _showSortBottomSheet,
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = orderProvider.orders;
          final filteredOrders = _filterAndSortOrders(orders);

          if (filteredOrders.isEmpty && orders.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 80,
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'No orders match your filters',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            );
          }

          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadOrders,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 100,
                          color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Start shopping to see your orders here.\nFind something unique today!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondaryColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ElevatedButton(
                        onPressed: () => context.go('/home'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: const Text(
                          'Continue Shopping',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: filteredOrders.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildOrderCard(order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      decoration: AppDecorations.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/orders/track-order/${order.orderId}'),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.orderId.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: _getStatusColor(order.status),
                            ),
                          ),
                          child: Text(
                            order.statusText,
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _confirmDelete(context, order);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Delete History'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  order.buyerName,
                  style: const TextStyle(color: AppTheme.textSecondaryColor),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Quantity: ${order.quantity}',
                  style: const TextStyle(color: AppTheme.textSecondaryColor),
                ),
                const Divider(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              _startChatWithArtisan(context, order),
                          icon: const Icon(
                            Icons.chat_outlined,
                            size: 18,
                          ),
                          label: const Text('Chat with Artisan'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        TextButton.icon(
                          onPressed: () => context
                              .push('/orders/track-order/${order.orderId}'),
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('Track Order'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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

  List<OrderModel> _filterAndSortOrders(List<OrderModel> orders) {
    List<OrderModel> filtered = List.from(orders);

    // Apply status filter
    if (_filterStatus != 'all') {
      OrderStatus status = OrderStatus.values.firstWhere(
        (s) => s.toString().split('.').last == _filterStatus,
        orElse: () => OrderStatus.newOrder,
      );
      filtered = filtered.where((order) => order.status == status).toList();
    }

    // Apply date filter
    if (_filterStartDate != null && _filterEndDate != null) {
      filtered = filtered.where((order) {
        return order.createdAt
                .isAfter(_filterStartDate!.subtract(const Duration(days: 1))) &&
            order.createdAt
                .isBefore(_filterEndDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'total_high':
        filtered.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'total_low':
        filtered.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _filterStatus = 'all';
      _sortBy = 'newest';
      _filterStartDate = null;
      _filterEndDate = null;
    });
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSortTile('Newest First', 'newest'),
              _buildSortTile('Oldest First', 'oldest'),
              _buildSortTile('Amount: High to Low', 'total_high'),
              _buildSortTile('Amount: Low to High', 'total_low'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: _sortBy == value ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Filter Orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Order Status
                    const Text(
                      'Order Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusFilter('All Orders', 'all', setModalState),
                    _buildStatusFilter('New Orders', 'newOrder', setModalState),
                    _buildStatusFilter('Accepted', 'accepted', setModalState),
                    _buildStatusFilter('Shipped', 'shipped', setModalState),
                    _buildStatusFilter('Completed', 'completed', setModalState),
                    _buildStatusFilter('Cancelled', 'cancelled', setModalState),
                    const SizedBox(height: 24),

                    // Date Range
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _filterStartDate ??
                                    DateTime.now()
                                        .subtract(const Duration(days: 30)),
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setModalState(() {
                                  _filterStartDate = date;
                                });
                              }
                            },
                            child: Text(_filterStartDate != null
                                ? '${_filterStartDate!.day}/${_filterStartDate!.month}/${_filterStartDate!.year}'
                                : 'Start Date'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _filterEndDate ?? DateTime.now(),
                                firstDate: _filterStartDate ??
                                    DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setModalState(() {
                                  _filterEndDate = date;
                                });
                              }
                            },
                            child: Text(_filterEndDate != null
                                ? '${_filterEndDate!.day}/${_filterEndDate!.month}/${_filterEndDate!.year}'
                                : 'End Date'),
                          ),
                        ),
                      ],
                    ),
                    if (_filterStartDate != null || _filterEndDate != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              _filterStartDate = null;
                              _filterEndDate = null;
                            });
                          },
                          child: const Text('Clear Dates'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _filterStatus = 'all';
                                _filterStartDate = null;
                                _filterEndDate = null;
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // Apply filters
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusFilter(
      String title, String value, StateSetter setModalState) {
    return InkWell(
      onTap: () {
        setModalState(() {
          _filterStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(
              _filterStatus == value
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _filterStatus == value
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
      ),
    );
  }

  Future<void> _startChatWithArtisan(
      BuildContext context, OrderModel order) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      context.push('/login');
      return;
    }

    final currentUser = authProvider.currentUser!;

    // Show loading dialog with app branding
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon or Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 30,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Initializing chat...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Capture navigator, messenger and router before async operations
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      debugPrint('Starting chat with artisan for order: ${order.orderId}');
      debugPrint('Artisan ID: ${order.artisanId}');
      debugPrint('Shop ID: ${order.shopId}');

      // Get shop details to get shop name and artisan name
      final shop = await shopProvider.getShopById(order.shopId);
      final product = await productProvider.getProductById(order.productId);

      if (!mounted) return;

      // Dismiss loading dialog
      navigator.pop();

      if (shop == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Could not find artisan details')),
        );
        return;
      }

      debugPrint('Shop found: ${shop.shopName}');
      debugPrint('Creating conversation...');

      // Use shop's ownerId as artisan ID if order doesn't have it
      final artisanId =
          order.artisanId.isNotEmpty ? order.artisanId : shop.ownerId;

      if (artisanId.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content:
                Text('Cannot start chat: Shop owner information is missing'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      debugPrint('Using artisan ID: $artisanId');

      final conversation = await chatProvider.getOrCreateConversation(
        currentUserId: currentUser.uid,
        currentUserName:
            currentUser.name.isNotEmpty ? currentUser.name : 'User',
        currentUserProfilePic: currentUser.profilePicture,
        otherUserId: artisanId,
        otherUserName: shop.shopName.isNotEmpty ? shop.shopName : 'Artisan',
        otherUserProfilePic: shop.imageUrl,
        productId: order.productId,
        productName: product?.name ?? 'Product',
        productImage: product?.imageUrl,
        shopId: order.shopId,
        shopName: shop.shopName,
      );

      if (!mounted) return;

      if (conversation != null) {
        router.push('/chat/room/${conversation.conversationId}',
            extra: conversation);
      } else {
        final errorMsg = chatProvider.error ?? 'Unknown error occurred';
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to initialize chat: $errorMsg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in _startChatWithArtisan: $e');
      if (!mounted) return;

      // Try to pop the loading dialog if it's still there
      try {
        navigator.pop();
      } catch (_) {}

      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error starting chat: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, OrderModel order) async {
    // Capture before async operation
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order History?'),
        content: const Text(
            'This will remove the order from your local history. It will still exist in the database for reference.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;

      final success = await orderProvider.deleteOrder(order.orderId);

      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Order removed from history'
              : 'Failed to remove order: ${orderProvider.errorMessage}'),
        ),
      );
    }
  }
}
