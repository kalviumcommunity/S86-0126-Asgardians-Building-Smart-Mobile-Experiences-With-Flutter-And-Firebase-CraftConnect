import 'package:flutter/services.dart';

/// Comprehensive form validation utilities
class FormValidators {
  // Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // Email validation
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Password validation with customizable requirements
  static String? password(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (requireNumbers && !value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (requireSpecialChars &&
        !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Phone number validation
  static String? phoneNumber(String? value, {String? countryCode}) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digits
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (countryCode == '+1' || countryCode == null) {
      // US phone number validation
      if (cleaned.length != 10) {
        return 'Enter a valid 10-digit phone number';
      }
    } else if (countryCode == '+91') {
      // Indian phone number validation
      if (cleaned.length != 10) {
        return 'Enter a valid 10-digit mobile number';
      }
    } else {
      // Generic validation
      if (cleaned.length < 10 || cleaned.length > 15) {
        return 'Enter a valid phone number';
      }
    }

    return null;
  }

  // Name validation
  static String? name(String? value, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  // Age validation
  static String? age(String? value, {int minAge = 13, int maxAge = 120}) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Enter a valid age';
    }

    if (age < minAge || age > maxAge) {
      return 'Age must be between $minAge and $maxAge';
    }

    return null;
  }

  // URL validation
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Enter a valid URL (must start with http:// or https://)';
      }
    } catch (e) {
      return 'Enter a valid URL';
    }

    return null;
  }

  // Credit card number validation (basic Luhn algorithm)
  static String? creditCard(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Credit card number is required';
    }

    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Enter a valid credit card number';
    }

    // Luhn algorithm
    int sum = 0;
    bool isEven = false;

    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit = digit ~/ 10 + digit % 10;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    if (sum % 10 != 0) {
      return 'Enter a valid credit card number';
    }

    return null;
  }

  // CVV validation
  static String? cvv(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV is required';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'Enter a valid CVV (3-4 digits)';
    }

    return null;
  }

  // Combined validator - allows multiple validations
  static String? combine(
    List<String? Function(String?)> validators,
    String? value,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }

  // Custom length validation
  static String? length(
    String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null) value = '';

    if (minLength != null && value.length < minLength) {
      return '${fieldName ?? 'Field'} must be at least $minLength characters';
    }

    if (maxLength != null && value.length > maxLength) {
      return '${fieldName ?? 'Field'} must not exceed $maxLength characters';
    }

    return null;
  }

  // Numeric validation
  static String? numeric(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Enter a valid number';
    }

    if (min != null && number < min) {
      return 'Value must be at least $min';
    }

    if (max != null && number > max) {
      return 'Value must not exceed $max';
    }

    return null;
  }
}

/// Input formatters for common field types
class FormFormatters {
  // Phone number formatter
  static TextInputFormatter phoneNumber() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      if (text.length <= 3) {
        return newValue.copyWith(text: text);
      } else if (text.length <= 6) {
        return newValue.copyWith(
          text: '(${text.substring(0, 3)}) ${text.substring(3)}',
          selection: TextSelection.collapsed(offset: text.length + 2),
        );
      } else if (text.length <= 10) {
        return newValue.copyWith(
          text:
              '(${text.substring(0, 3)}) ${text.substring(3, 6)}-${text.substring(6)}',
          selection: TextSelection.collapsed(offset: text.length + 4),
        );
      }

      String formatted =
          '(${text.substring(0, 3)}) ${text.substring(3, 6)}-${text.substring(6, 10)}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  // Credit card formatter
  static TextInputFormatter creditCard() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      if (text.length <= 4) {
        return newValue.copyWith(text: text);
      }

      String formatted = '';
      for (int i = 0; i < text.length; i += 4) {
        int endIndex = i + 4;
        if (endIndex > text.length) endIndex = text.length;
        formatted += text.substring(i, endIndex);
        if (endIndex != text.length && endIndex != text.length) {
          formatted += ' ';
        }
      }

      if (formatted.length > 19) {
        formatted = formatted.substring(0, 19);
      }

      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  // Expiry date formatter (MM/YY)
  static TextInputFormatter expiryDate() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      if (text.length >= 2) {
        String month = text.substring(0, 2);
        String year = text.length > 2 ? text.substring(2) : '';

        // Validate month
        int monthInt = int.tryParse(month) ?? 0;
        if (monthInt > 12) {
          month = '12';
        } else if (monthInt == 0) {
          month = '01';
        }

        if (year.length > 2) {
          year = year.substring(0, 2);
        }

        text = month + year;
        String formatted = month + (year.isNotEmpty ? '/$year' : '');

        return newValue.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }

      return newValue.copyWith(text: text);
    });
  }

  // Currency formatter
  static TextInputFormatter currency() {
    return FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));
  }

  // Uppercase formatter
  static TextInputFormatter upperCase() {
    return TextInputFormatter.withFunction(
      (oldValue, newValue) => newValue.copyWith(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      ),
    );
  }
}
