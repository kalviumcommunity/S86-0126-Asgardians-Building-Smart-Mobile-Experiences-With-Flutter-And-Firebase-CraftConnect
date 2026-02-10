import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/form_validators.dart';

class PaymentForm extends StatefulWidget {
  final double amount;
  final String currency;
  final Function(Map<String, dynamic>)? onPaymentComplete;

  const PaymentForm({
    super.key,
    required this.amount,
    this.currency = 'USD',
    this.onPaymentComplete,
  });

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _emailController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  // Form state
  String _cardType = '';
  bool _saveCard = false;
  bool _isProcessing = false;
  String? _selectedCountry;
  String? _selectedState;

  // Card type detection
  final Map<String, RegExp> _cardPatterns = {
    'Visa': RegExp(r'^4[0-9]{0,}$'),
    'Mastercard': RegExp(r'^5[1-5][0-9]{0,}$'),
    'American Express': RegExp(r'^3[47][0-9]{0,}$'),
    'Discover': RegExp(r'^6(?:011|5[0-9]{2})[0-9]{0,}$'),
  };

  final Map<String, String> _cardIcons = {
    'Visa': '💳',
    'Mastercard': '💳',
    'American Express': '💳',
    'Discover': '💳',
  };

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_detectCardType);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _emailController.dispose();
    _billingAddressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _detectCardType() {
    String number = _cardNumberController.text.replaceAll(' ', '');
    String detectedType = '';

    for (String type in _cardPatterns.keys) {
      if (_cardPatterns[type]!.hasMatch(number)) {
        detectedType = type;
        break;
      }
    }

    if (detectedType != _cardType) {
      setState(() => _cardType = detectedType);
    }
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    if (value.length != 5) {
      return 'Enter date in MM/YY format';
    }

    List<String> parts = value.split('/');
    if (parts.length != 2) {
      return 'Enter date in MM/YY format';
    }

    int? month = int.tryParse(parts[0]);
    int? year = int.tryParse('20${parts[1]}');

    if (month == null || year == null) {
      return 'Enter a valid date';
    }

    if (month < 1 || month > 12) {
      return 'Enter a valid month (01-12)';
    }

    DateTime now = DateTime.now();
    DateTime cardDate = DateTime(year, month);

    if (cardDate.isBefore(DateTime(now.year, now.month))) {
      return 'Card has expired';
    }

    if (cardDate.isAfter(DateTime(now.year + 20, now.month))) {
      return 'Enter a valid expiry date';
    }

    return null;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill all required fields correctly');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));

      final paymentData = {
        'amount': widget.amount,
        'currency': widget.currency,
        'cardType': _cardType,
        'cardLast4': _cardNumberController.text
            .replaceAll(' ', '')
            .substring(
              _cardNumberController.text.replaceAll(' ', '').length - 4,
            ),
        'cardHolder': _cardHolderController.text,
        'email': _emailController.text,
        'billingAddress': {
          'street': _billingAddressController.text,
          'city': _cityController.text,
          'state': _selectedState,
          'country': _selectedCountry,
          'zip': _zipController.text,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (widget.onPaymentComplete != null) {
        widget.onPaymentComplete!(paymentData);
      }

      _showSuccessSnackBar('Payment processed successfully!');

      // Clear form
      _formKey.currentState!.reset();
      _cardNumberController.clear();
      _cardHolderController.clear();
      _expiryController.clear();
      _cvvController.clear();
      _emailController.clear();
      _billingAddressController.clear();
      _cityController.clear();
      _zipController.clear();

      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackBar('Payment failed: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            _buildOrderSummary(),

            const SizedBox(height: 24),

            // Payment Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Card Information'),
                  const SizedBox(height: 16),

                  // Card Number
                  TextFormField(
                    controller: _cardNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FormFormatters.creditCard()],
                    decoration: InputDecoration(
                      labelText: 'Card Number *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.credit_card),
                      suffixIcon: _cardType.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                _cardIcons[_cardType] ?? '💳',
                                style: const TextStyle(fontSize: 20),
                              ),
                            )
                          : null,
                      suffixText: _cardType.isNotEmpty ? _cardType : null,
                    ),
                    validator: FormValidators.creditCard,
                  ),

                  const SizedBox(height: 16),

                  // Card Holder Name
                  TextFormField(
                    controller: _cardHolderController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Cardholder Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => FormValidators.name(value),
                  ),

                  const SizedBox(height: 16),

                  // Expiry and CVV Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FormFormatters.expiryDate()],
                          decoration: const InputDecoration(
                            labelText: 'MM/YY *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.date_range),
                          ),
                          validator: _validateExpiryDate,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: InputDecoration(
                            labelText: 'CVV *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.help_outline),
                              onPressed: () => _showCvvHelp(),
                            ),
                          ),
                          validator: FormValidators.cvv,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Contact Information
                  _buildSectionHeader('Contact Information'),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                      helperText: 'Receipt will be sent to this email',
                    ),
                    validator: FormValidators.email,
                  ),

                  const SizedBox(height: 24),

                  // Billing Address
                  _buildSectionHeader('Billing Address'),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _billingAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Street Address *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                    validator: (value) =>
                        FormValidators.required(value, fieldName: 'Address'),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'City *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          validator: (value) =>
                              FormValidators.required(value, fieldName: 'City'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _zipController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ZIP *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => FormValidators.required(
                            value,
                            fieldName: 'ZIP code',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedState,
                          decoration: const InputDecoration(
                            labelText: 'State *',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              [
                                    'California',
                                    'New York',
                                    'Texas',
                                    'Florida',
                                    'Illinois',
                                    'Other',
                                  ]
                                  .map(
                                    (state) => DropdownMenuItem(
                                      value: state,
                                      child: Text(state),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedState = value),
                          validator: (value) =>
                              value == null ? 'Please select state' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          decoration: const InputDecoration(
                            labelText: 'Country *',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              [
                                    'United States',
                                    'Canada',
                                    'United Kingdom',
                                    'Australia',
                                  ]
                                  .map(
                                    (country) => DropdownMenuItem(
                                      value: country,
                                      child: Text(country),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCountry = value),
                          validator: (value) =>
                              value == null ? 'Please select country' : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Save Card Option
                  CheckboxListTile(
                    title: const Text('Save card for future purchases'),
                    subtitle: const Text(
                      'Your card information will be securely stored',
                    ),
                    value: _saveCard,
                    onChanged: (value) =>
                        setState(() => _saveCard = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 24),

                  // Security Notice
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your payment information is encrypted and secure. We never store your full card number.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isProcessing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('Processing...'),
                              ],
                            )
                          : Text(
                              'Pay ${widget.currency} ${widget.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Payment Methods Accepted
                  Center(
                    child: Text(
                      'We accept Visa, Mastercard, American Express, and Discover',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Text('${widget.currency} ${widget.amount.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax:'),
              Text(
                '${widget.currency} ${(widget.amount * 0.08).toStringAsFixed(2)}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.currency} ${(widget.amount * 1.08).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  void _showCvvHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CVV Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The CVV is the 3 or 4 digit security code on your card:'),
            SizedBox(height: 12),
            Text('• Visa/Mastercard: 3 digits on the back'),
            Text('• American Express: 4 digits on the front'),
            SizedBox(height: 12),
            Text('This helps verify that you have the physical card.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
