import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/order_model.dart';
import '../../services/analytics_service.dart';
import '../../services/firestore_service.dart';
import 'package:craftconnect/config/app_constants.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String name;
  final String phone;
  final String address;
  final String upiId;
  final String productId;
  final String shopId;
  final String artisanId;
  final int quantity;
  final bool hasGiftWrapping;
  final String? giftMessage;
  final double giftWrappingCharge;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.name,
    required this.phone,
    required this.address,
    required this.upiId,
    required this.productId,
    required this.shopId,
    required this.artisanId,
    required this.quantity,
    this.hasGiftWrapping = false,
    this.giftMessage,
    this.giftWrappingCharge = 0.0,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _paymentSuccess = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (!mounted) return;

    // Get product details for analytics
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    await productProvider.getProductById(widget.productId);
    final product = productProvider.currentProduct;

    if (!mounted) return;

    // Create order
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final buyerId = authProvider.currentUser?.uid ?? '';

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final newOrderId = await orderProvider.createOrder(
      productId: widget.productId,
      shopId: widget.shopId,
      artisanId: widget.artisanId,
      buyerId: buyerId,
      buyerName: widget.name,
      buyerPhone: widget.phone,
      buyerAddress: widget.address,
      quantity: widget.quantity,
      totalAmount: widget.amount,
      upiId: widget.upiId,
      hasGiftWrapping: widget.hasGiftWrapping,
      giftMessage: widget.giftMessage,
      giftWrappingCharge: widget.giftWrappingCharge,
    );

    if (newOrderId != null && mounted) {
      // Update payment status
      await orderProvider.updatePaymentStatus(
          newOrderId, PaymentStatus.success);

      // Track purchase in analytics
      if (product != null) {
        await AnalyticsService().logPurchase(
          orderId: newOrderId,
          totalAmount: widget.amount,
          items: [
            {
              'productId': product.productId,
              'productName': product.name,
              'category': product.category,
              'price': product.getPriceForQuantity(widget.quantity),
              'quantity': widget.quantity,
            }
          ],
        );

        // Increment purchase count in Firestore for trending algorithm
        await FirestoreService()
            .incrementProductPurchaseCount(product.productId);
      }

      setState(() {
        _isProcessing = false;
        _paymentSuccess = true;
      });
      _animationController.forward();

      // Navigate to order tracking after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/orders/track-order/$newOrderId');
        }
      });
    } else if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed. Please try again.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: _paymentSuccess ? _buildSuccessView() : _buildPaymentView(),
    );
  }

  Widget _buildPaymentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // UPI Logo
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Payment Details Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppDecorations.cardDecoration,
            child: Column(
              children: [
                Text(
                  'Payment Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(height: AppSpacing.lg),
                _buildDetailRow('UPI ID', widget.upiId),
                _buildDetailRow(
                    'Amount', '₹${widget.amount.toStringAsFixed(0)}'),
                _buildDetailRow('Name', widget.name),
                _buildDetailRow('Phone', widget.phone),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Amount Display
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '₹${widget.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Info Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.accentColor,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'This is a mock payment. In production, this would connect to a real UPI gateway.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Pay Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: AppTheme.successColor,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Pay Now',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '₹${widget.amount.toStringAsFixed(0)} paid',
              style: const TextStyle(
                fontSize: 20,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Your order has been placed successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Redirecting to order tracking...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
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
}
