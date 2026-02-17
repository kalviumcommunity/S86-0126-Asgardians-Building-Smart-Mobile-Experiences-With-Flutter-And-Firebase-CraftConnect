import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/coupon_provider.dart';
import '../../models/coupon_model.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../widgets/empty_state_widget.dart';

class AdminCouponManagementScreen extends StatefulWidget {
  const AdminCouponManagementScreen({super.key});

  @override
  State<AdminCouponManagementScreen> createState() =>
      _AdminCouponManagementScreenState();
}

class _AdminCouponManagementScreenState
    extends State<AdminCouponManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    await couponProvider.getAllCoupons();
  }

  void _showCreateCouponDialog([CouponModel? existingCoupon]) {
    showDialog(
      context: context,
      builder: (context) => _CouponFormDialog(coupon: existingCoupon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon Management'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCouponDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Create Coupon'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: couponProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : couponProvider.coupons.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.discount,
                  title: 'No Coupons',
                  message: 'Create your first coupon to get started',
                  actionLabel: 'Create Coupon',
                  onAction: () => _showCreateCouponDialog(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: couponProvider.coupons.length,
                  itemBuilder: (context, index) {
                    final coupon = couponProvider.coupons[index];
                    return _buildCouponCard(coupon);
                  },
                ),
    );
  }

  Widget _buildCouponCard(CouponModel coupon) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ExpansionTile(
        title: Text(
          coupon.code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(coupon.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: coupon.isActive
                    ? AppTheme.successColor.withValues(alpha: 0.1)
                    : AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                coupon.isActive ? 'ACTIVE' : 'INACTIVE',
                style: TextStyle(
                  color: coupon.isActive
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Type',
                  coupon.type == CouponType.percentage
                      ? 'Percentage'
                      : coupon.type == CouponType.fixedAmount
                          ? 'Fixed Amount'
                          : 'Free Shipping',
                ),
                _buildInfoRow(
                    'Value',
                    coupon.type == CouponType.percentage
                        ? '${coupon.value}%'
                        : '₹${coupon.value}'),
                _buildInfoRow('Min Order', '₹${coupon.minOrderAmount}'),
                if (coupon.maxDiscountAmount != null)
                  _buildInfoRow('Max Discount', '₹${coupon.maxDiscountAmount}'),
                _buildInfoRow('Usage',
                    '${coupon.usedCount}/${coupon.usageLimit == -1 ? "∞" : coupon.usageLimit}'),
                _buildInfoRow('Valid From', _formatDate(coupon.startDate)),
                _buildInfoRow('Valid Until', _formatDate(coupon.endDate)),
                _buildInfoRow('Status', coupon.isValid ? 'Valid' : 'Expired'),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showCreateCouponDialog(coupon),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteCoupon(coupon),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCoupon(CouponModel coupon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: Text('Are you sure you want to delete "${coupon.code}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<CouponProvider>(context, listen: false);
      await provider.deleteCoupon(coupon.couponId);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CouponFormDialog extends StatefulWidget {
  final CouponModel? coupon;

  const _CouponFormDialog({this.coupon});

  @override
  State<_CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<_CouponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _usageLimitController = TextEditingController();

  CouponType _selectedType = CouponType.percentage;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.coupon != null) {
      _codeController.text = widget.coupon!.code;
      _titleController.text = widget.coupon!.title;
      _descriptionController.text = widget.coupon!.description;
      _valueController.text = widget.coupon!.value.toString();
      _minOrderController.text = widget.coupon!.minOrderAmount.toString();
      _maxDiscountController.text =
          widget.coupon!.maxDiscountAmount?.toString() ?? '';
      _usageLimitController.text = widget.coupon!.usageLimit.toString();
      _selectedType = widget.coupon!.type;
      _startDate = widget.coupon!.startDate;
      _endDate = widget.coupon!.endDate;
      _isActive = widget.coupon!.isActive;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _minOrderController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _saveCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    const uuid = Uuid();

    final coupon = CouponModel(
      couponId: widget.coupon?.couponId ?? uuid.v4(),
      code: _codeController.text.trim().toUpperCase(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      value: double.parse(_valueController.text),
      minOrderAmount: double.parse(_minOrderController.text),
      maxDiscountAmount: _maxDiscountController.text.isEmpty
          ? null
          : double.parse(_maxDiscountController.text),
      startDate: _startDate,
      endDate: _endDate,
      usageLimit: int.parse(_usageLimitController.text),
      isActive: _isActive,
      createdAt: widget.coupon?.createdAt ?? DateTime.now(),
      usedCount: widget.coupon?.usedCount ?? 0,
    );

    if (widget.coupon == null) {
      await couponProvider.createCoupon(coupon);
    } else {
      await couponProvider.updateCoupon(coupon);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            AppBar(
              title:
                  Text(widget.coupon == null ? 'Create Coupon' : 'Edit Coupon'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Coupon Code',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<CouponType>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: CouponType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        labelText: _selectedType == CouponType.percentage
                            ? 'Percentage'
                            : 'Amount',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _minOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Minimum Order Amount',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _maxDiscountController,
                      decoration: const InputDecoration(
                        labelText: 'Max Discount (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _usageLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Usage Limit (-1 for unlimited)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: _saveCoupon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Save Coupon'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
