import 'package:flutter/services.dart';

/// Utility class for input validation
class Validators {
  // Email validation with proper regex
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Phone number validation (Indian format)
  static String? validatePhone(String? value, {String countryCode = '+91'}) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-numeric characters
    final numericOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Check length (10 digits for Indian numbers)
    if (numericOnly.length != 10) {
      return 'Phone number must be 10 digits';
    }

    // Check if starts with valid digits (6-9 for Indian numbers)
    if (!numericOnly.startsWith(RegExp(r'[6-9]'))) {
      return 'Phone number must start with 6, 7, 8, or 9';
    }

    return null;
  }

  // Password validation with strength requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // Password strength calculator (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength > 4 ? 4 : strength;
  }

  // Price validation
  static String? validatePrice(String? value,
      {double min = 1, double max = 999999}) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid number';
    }

    if (price < min) {
      return 'Price must be at least ₹$min';
    }

    if (price > max) {
      return 'Price cannot exceed ₹${max.toStringAsFixed(0)}';
    }

    // Check decimal places
    final parts = value.split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return 'Price can have maximum 2 decimal places';
    }

    return null;
  }

  // Stock/Quantity validation
  static String? validateQuantity(String? value,
      {int min = 0, int max = 10000}) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid number';
    }

    if (quantity < min) {
      return 'Quantity must be at least $min';
    }

    if (quantity > max) {
      return 'Quantity cannot exceed $max';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value, {int minLength = 2}) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < minLength) {
      return 'Name must be at least $minLength characters';
    }

    // Check for invalid characters (numbers, special chars)
    if (value.contains(RegExp(r'[0-9]'))) {
      return 'Name cannot contain numbers';
    }

    return null;
  }

  // Required field validation
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}

/// Phone number text input formatter
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Only allow numbers
    final numericText = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 10 digits
    final limitedText =
        numericText.length > 10 ? numericText.substring(0, 10) : numericText;

    // Format as: 98765 43210
    if (limitedText.length > 5) {
      final formatted =
          '${limitedText.substring(0, 5)} ${limitedText.substring(5)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return TextEditingValue(
      text: limitedText,
      selection: TextSelection.collapsed(offset: limitedText.length),
    );
  }
}
