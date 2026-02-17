import 'package:flutter/foundation.dart';

/// Utility class for environment-specific configurations
class AppEnvironment {
  // Production domain
  static const String productionDomain = 'https://craftconnect.app';

  // Check if running in web
  static bool get isWeb => kIsWeb;

  // Check if running locally (development)
  static bool get isLocal {
    if (!kIsWeb) return kDebugMode;

    // For web, check the current URL
    try {
      final url = Uri.base;
      return url.host == 'localhost' ||
          url.host == '127.0.0.1' ||
          url.host.startsWith('192.168.');
    } catch (e) {
      return kDebugMode;
    }
  }

  // Get the base URL based on environment
  static String get baseUrl {
    if (isLocal && kIsWeb) {
      // Return the current local URL
      final uri = Uri.base;
      return '${uri.scheme}://${uri.host}:${uri.port}';
    }
    return productionDomain;
  }

  // Generate shop URL
  static String getShopUrl(String slug) {
    if (isLocal && kIsWeb) {
      final uri = Uri.base;
      return '${uri.scheme}://${uri.host}:${uri.port}/#/shop/$slug';
    }
    return '$productionDomain/shop/$slug';
  }

  // Generate product URL
  static String getProductUrl(String productId) {
    if (isLocal && kIsWeb) {
      final uri = Uri.base;
      return '${uri.scheme}://${uri.host}:${uri.port}/#/product/$productId';
    }
    return '$productionDomain/product/$productId';
  }
}
