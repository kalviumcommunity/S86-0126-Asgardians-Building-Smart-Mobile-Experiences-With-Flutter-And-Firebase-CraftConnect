import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, String>> _savedMethods = [];

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddPaymentMethodDialog(
        onAdd: (method) {
          setState(() {
            _savedMethods.add(method);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cash on Delivery (Always available)
            _buildPaymentOption(
              icon: Icons.money,
              title: 'Cash on Delivery',
              subtitle: 'Pay when you receive the order',
              isDefault: true,
            ),
            const SizedBox(height: 16),

            // Saved UPI IDs
            if (_savedMethods.isNotEmpty) ...[
              const Text(
                'Saved Payment Methods',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._savedMethods.map((method) {
                return _buildSavedMethod(
                  type: method['type']!,
                  value: method['value']!,
                  onDelete: () {
                    setState(() {
                      _savedMethods.remove(method);
                    });
                  },
                );
              }),
              const SizedBox(height: 16),
            ],

            // Add new payment method button
            OutlinedButton.icon(
              onPressed: _showAddPaymentDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add UPI ID'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 24),

            // Payment info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• All UPI payments are processed securely\n'
                    '• You can save multiple UPI IDs for quick checkout\n'
                    '• Cash on Delivery is available for all orders\n'
                    '• Online payment confirmation is instant',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDefault = false,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: isDefault
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSavedMethod({
    required String type,
    required String value,
    required VoidCallback onDelete,
  }) {
    IconData icon;
    switch (type) {
      case 'UPI':
        icon = Icons.payment;
        break;
      case 'Card':
        icon = Icons.credit_card;
        break;
      default:
        icon = Icons.account_balance_wallet;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(type),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Remove Payment Method'),
                content: Text('Remove $value from saved methods?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddPaymentMethodDialog extends StatefulWidget {
  final Function(Map<String, String>) onAdd;

  const _AddPaymentMethodDialog({required this.onAdd});

  @override
  State<_AddPaymentMethodDialog> createState() =>
      _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<_AddPaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _upiController = TextEditingController();
  String _selectedType = 'UPI';

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  void _saveMethod() {
    if (!_formKey.currentState!.validate()) return;

    widget.onAdd({
      'type': _selectedType,
      'value': _upiController.text.trim(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment method added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Payment Method'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                DropdownMenuItem(
                    value: 'Card', child: Text('Debit/Credit Card')),
                DropdownMenuItem(value: 'Wallet', child: Text('Wallet')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _upiController,
              decoration: InputDecoration(
                labelText: _selectedType == 'UPI'
                    ? 'UPI ID'
                    : _selectedType == 'Card'
                        ? 'Card Number'
                        : 'Wallet ID',
                hintText: _selectedType == 'UPI'
                    ? 'example@upi'
                    : _selectedType == 'Card'
                        ? '1234 5678 9012 3456'
                        : 'wallet@example',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter ${_selectedType == 'UPI' ? 'UPI ID' : _selectedType == 'Card' ? 'card number' : 'wallet ID'}';
                }
                if (_selectedType == 'UPI' && !value.contains('@')) {
                  return 'Invalid UPI ID format';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveMethod,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
