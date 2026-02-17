import 'dart:async';
import 'package:flutter/foundation.dart';

/// A utility class for debouncing function calls
/// Useful for search inputs, API calls, etc.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Execute the action after the delay
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel any pending actions
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose and clean up
  void dispose() {
    _timer?.cancel();
  }
}

/// A debouncer specifically for search functionality
class SearchDebouncer extends Debouncer {
  SearchDebouncer() : super(delay: const Duration(milliseconds: 500));
}

/// A debouncer for form field changes
class FormDebouncer extends Debouncer {
  FormDebouncer() : super(delay: const Duration(milliseconds: 800));
}

/// A debouncer for API calls
class ApiDebouncer extends Debouncer {
  ApiDebouncer() : super(delay: const Duration(milliseconds: 300));
}
