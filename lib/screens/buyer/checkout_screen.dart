import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import '../../services/analytics_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String productId;
  final String shopId;
  final String artisanId;
  final int quantity;

  const CheckoutScreen({
    super.key,
    required this.productId,
    required this.shopId,
    required this.artisanId,
    required this.quantity,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _upiController = TextEditingController();
  final _giftMessageController = TextEditingController();
  bool _hasGiftWrapping = false;
  static const double _giftWrappingCharge = 50.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      _nameController.text = authProvider.currentUser!.name;
      _phoneController.text = authProvider.currentUser!.phone;

      await addressProvider.loadAddresses(authProvider.currentUser!.uid);
      if (addressProvider.defaultAddress != null) {
        final addr = addressProvider.defaultAddress!;
        _addressController.text =
            '${addr.addressLine1}${addr.addressLine2.isNotEmpty ? ', ${addr.addressLine2}' : ''}\n${addr.city}, ${addr.state} - ${addr.pincode}';
      }
    }
  }

  void _showAddressPicker() {
    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Address',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/account/addresses');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New'),
                  ),
                ],
              ),
              const Divider(),
              if (addressProvider.addresses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Text('No saved addresses found'),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: addressProvider.addresses.length,
                    itemBuilder: (context, index) {
                      final addr = addressProvider.addresses[index];
                      return ListTile(
                        leading: Icon(
                          addr.isDefault ? Icons.home : Icons.location_on,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(addr.fullName),
                        subtitle: Text(
                          '${addr.addressLine1}, ${addr.city}, ${addr.state} - ${addr.pincode}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          setState(() {
                            _nameController.text = addr.fullName;
                            _phoneController.text = addr.phoneNumber;
                            _addressController.text =
                                '${addr.addressLine1}${addr.addressLine2.isNotEmpty ? ', ${addr.addressLine2}' : ''}\n${addr.city}, ${addr.state} - ${addr.pincode}';
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _upiController.dispose();
    _giftMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    await productProvider.getProductById(widget.productId);
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final product = productProvider.currentProduct;

    if (product == null) return;

    final baseAmount = product.getTotalPriceForQuantity(widget.quantity);
    final totalAmount =
        baseAmount + (_hasGiftWrapping ? _giftWrappingCharge : 0);

    // Track begin checkout in analytics
    await AnalyticsService().logBeginCheckout(
      totalAmount: totalAmount,
      itemCount: widget.quantity,
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

    if (!mounted) return;

    // Navigate to payment screen
    context.go(
      '/cart/payment?orderId=temp&amount=$totalAmount&'
      'name=${_nameController.text}&'
      'phone=${_phoneController.text}&'
      'address=${_addressController.text}&'
      'upiId=${_upiController.text}&'
      'productId=${widget.productId}&'
      'shopId=${widget.shopId}&'
      'artisanId=${widget.artisanId}&'
      'quantity=${widget.quantity}&'
      'hasGiftWrapping=$_hasGiftWrapping&'
      'giftMessage=${Uri.encodeComponent(_giftMessageController.text)}&'
      'giftWrappingCharge=${_hasGiftWrapping ? _giftWrappingCharge : 0}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final product = productProvider.currentProduct;
          if (product == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final baseAmount = product.getTotalPriceForQuantity(widget.quantity);
          final totalAmount =
              baseAmount + (_hasGiftWrapping ? _giftWrappingCharge : 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: AppDecorations.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Divider(height: AppSpacing.lg),
                        Row(
                          children: [
                            if (product.imageUrl != null)
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                child: Image.network(
                                  product.imageUrl!,
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
                                  color: AppTheme.backgroundColor,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Icon(Icons.image),
                              ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.hasBulkPricing
                                        ? '₹${product.getPriceForQuantity(widget.quantity).toStringAsFixed(0)} × ${widget.quantity}'
                                        : '₹${product.price} × ${widget.quantity}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${baseAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Gift Wrapping Option
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: const Text(
                            'Add Gift Wrapping',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Beautiful gift wrapping with personalized message (+₹${_giftWrappingCharge.toStringAsFixed(0)})',
                            style: const TextStyle(fontSize: 13),
                          ),
                          value: _hasGiftWrapping,
                          onChanged: (value) {
                            setState(() {
                              _hasGiftWrapping = value ?? false;
                            });
                          },
                          secondary: Icon(
                            Icons.card_giftcard,
                            color: _hasGiftWrapping
                                ? AppTheme.primaryColor
                                : Colors.grey,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_hasGiftWrapping) ...[
                          const Divider(),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _giftMessageController,
                            decoration: const InputDecoration(
                              labelText: 'Gift Message (Optional)',
                              hintText: 'Write a special message...',
                              prefixIcon: Icon(Icons.message),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            maxLength: 150,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Buyer Information
                  Text(
                    'Your Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.book_online),
                        onPressed: _showAddressPicker,
                        tooltip: 'Select from address book',
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Payment Information
                  Text(
                    'Payment Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: _upiController,
                    decoration: const InputDecoration(
                      labelText: 'UPI ID',
                      prefixIcon: Icon(Icons.account_balance),
                      hintText: 'yourname@upi',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your UPI ID';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Apply Coupon Button
                  OutlinedButton.icon(
                    onPressed: () => context.go('/cart/apply-coupon'),
                    icon: const Icon(Icons.local_offer),
                    label: const Text('Apply Coupon Code'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Total Amount Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      children: [
                        if (_hasGiftWrapping) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '₹${baseAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Gift Wrapping',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '₹${_giftWrappingCharge.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white54, height: 16),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹${totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Proceed Button
                  ElevatedButton(
                    onPressed: _proceedToPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Proceed to Payment',
                      style: TextStyle(fontSize: 18),
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
}
