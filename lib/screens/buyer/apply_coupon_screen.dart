import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coupon_provider.dart';
import '../../models/coupon_model.dart';
import '../../config/theme.dart';
import '../../widgets/empty_state_widget.dart';
import 'package:craftconnect/config/app_constants.dart';

class ApplyCouponScreen extends StatefulWidget {
  final double orderAmount;
  final String? category;
  final List<String> productIds;

  const ApplyCouponScreen({
    super.key,
    required this.orderAmount,
    this.category,
    this.productIds = const [],
  });

  @override
  State<ApplyCouponScreen> createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  final _couponCodeController = TextEditingController();
  CouponModel? _selectedCoupon;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    await couponProvider.getAllCoupons();
  }

  @override
  void dispose() {
    _couponCodeController.dispose();
    super.dispose();
  }

  Future<void> _applyCouponCode() async {
    if (_couponCodeController.text.trim().isEmpty) return;

    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final code = _couponCodeController.text.trim().toUpperCase();

    final success = await couponProvider.applyCoupon(
      couponCode: code,
      orderAmount: widget.orderAmount,
    );

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(couponProvider.error ?? 'Invalid coupon code'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Successfully applied
    if (mounted) {
      setState(() {
        _selectedCoupon = couponProvider.appliedCoupon;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coupon applied successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);

    final applicableCoupons = couponProvider.coupons
        .where((c) => c.isApplicableFor(
              orderAmount: widget.orderAmount,
              category: widget.category,
              productIds: widget.productIds,
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Coupon'),
      ),
      body: Column(
        children: [
          // Coupon code input
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponCodeController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      prefixIcon: const Icon(Icons.local_offer),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _applyCouponCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Available coupons
          Expanded(
            child: applicableCoupons.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.discount,
                    title: 'No Coupons Available',
                    message: 'No coupons available for this order',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: applicableCoupons.length,
                    itemBuilder: (context, index) {
                      final coupon = applicableCoupons[index];
                      final isSelected =
                          _selectedCoupon?.couponId == coupon.couponId;

                      return _buildCouponCard(coupon, isSelected);
                    },
                  ),
          ),

          // Apply button
          if (_selectedCoupon != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Discount',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '- ₹${_selectedCoupon!.calculateDiscount(widget.orderAmount).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(_selectedCoupon);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Apply Coupon',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(CouponModel coupon, bool isSelected) {
    final discount = coupon.calculateDiscount(widget.orderAmount);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: () => setState(() => _selectedCoupon = coupon),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Coupon icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Coupon details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            coupon.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coupon.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Save ₹${discount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                        const Spacer(),
                        if (coupon.minOrderAmount > 0)
                          Text(
                            'Min ₹${coupon.minOrderAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}