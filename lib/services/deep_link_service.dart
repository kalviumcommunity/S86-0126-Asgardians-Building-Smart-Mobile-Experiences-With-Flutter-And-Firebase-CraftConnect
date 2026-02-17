import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription? _sub;
  Uri? _initialLink;
  final StreamController<String> _linkController =
      StreamController<String>.broadcast();
  GoRouter? _router;

  Stream<String> get linkStream => _linkController.stream;

  void setRouter(GoRouter router) {
    _router = router;
  }

  Future<void> initialize() async {
    try {
      // Get initial link if app was opened from a link
      _initialLink = await _appLinks.getInitialLink();
      if (_initialLink != null) {
        _linkController.add(_initialLink.toString());
      }

      // Listen for links while app is running
      _sub = _appLinks.uriLinkStream.listen((Uri uri) {
        _linkController.add(uri.toString());
        _handleDeepLink(uri.toString());
      }, onError: (err) {
        // Deep link error handled silently
      });
    } on PlatformException {
      // Failed to get initial link - handled silently
    }
  }

  void _handleDeepLink(String link) {
    // Parse the link and navigate accordingly
    // Examples:
    // craftconnect://shop/artisan-name
    // craftconnect://product/product-id
    // https://craftconnect.app/shop/artisan-name

    final uri = Uri.parse(link);

    if (uri.pathSegments.isNotEmpty) {
      final firstSegment = uri.pathSegments[0];

      switch (firstSegment) {
        case 'shop':
          if (uri.pathSegments.length > 1) {
            final shopSlug = uri.pathSegments[1];
            _router?.go('/shop/$shopSlug');
          }
          break;
        case 'product':
          if (uri.pathSegments.length > 1) {
            final productId = uri.pathSegments[1];
            _router?.go('/product/$productId');
          }
          break;
        default:
          // Unknown deep link path - navigate to home
          _router?.go('/');
      }
    }
  }

  void dispose() {
    _sub?.cancel();
    _linkController.close();
  }
}
