import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';

class CookieConsentBanner extends StatefulWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const CookieConsentBanner({
    super.key,
    this.onAccept,
    this.onDecline,
  });

  @override
  State<CookieConsentBanner> createState() => _CookieConsentBannerState();

  static const String _cookieConsentKey = 'cookie_consent_given';
  static const String _cookieDeclineKey = 'cookie_consent_declined';

  static Future<bool> hasUserAcceptedCookies() async {
    if (!kIsWeb) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_cookieConsentKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> resetCookieConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cookieConsentKey);
      await prefs.remove(_cookieDeclineKey);
    } catch (e) {
      debugPrint('Error resetting cookie consent: $e');
    }
  }
}

class _CookieConsentBannerState extends State<CookieConsentBanner>
    with SingleTickerProviderStateMixin {
  bool _shouldShow = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _checkConsentStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkConsentStatus() async {
    // Only show on web platform
    if (!kIsWeb) {
      setState(() {
        _shouldShow = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasAccepted =
          prefs.getBool(CookieConsentBanner._cookieConsentKey) ?? false;
      final hasDeclined =
          prefs.getBool(CookieConsentBanner._cookieDeclineKey) ?? false;

      setState(() {
        _shouldShow = !hasAccepted && !hasDeclined;
        _isLoading = false;
      });

      if (_shouldShow) {
        _animationController.forward();
      }
    } catch (e) {
      setState(() {
        _shouldShow = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(CookieConsentBanner._cookieConsentKey, true);
      await prefs.setBool(CookieConsentBanner._cookieDeclineKey, false);

      widget.onAccept?.call();
      await _hideBanner();
    } catch (e) {
      debugPrint('Error accepting cookies: $e');
    }
  }

  Future<void> _declineCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(CookieConsentBanner._cookieConsentKey, false);
      await prefs.setBool(CookieConsentBanner._cookieDeclineKey, true);

      widget.onDecline?.call();
      await _hideBanner();
    } catch (e) {
      debugPrint('Error declining cookies: $e');
    }
  }

  Future<void> _hideBanner() async {
    await _animationController.reverse();
    if (mounted) {
      setState(() {
        _shouldShow = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_shouldShow) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        color: Colors.black.withValues(alpha: 0.9),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.cookie,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cookie Notice',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We use cookies to improve your experience, analyze site usage, and personalize content. By continuing to use our site, you accept our use of cookies.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Show cookie policy
                                _showCookiePolicy(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.secondaryColor,
                              ),
                              child: const Text('Learn More'),
                            ),
                            ElevatedButton(
                              onPressed: _acceptCookies,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Accept All'),
                            ),
                            TextButton(
                              onPressed: _declineCookies,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                              ),
                              child: const Text('Decline'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _declineCookies,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCookiePolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cookie Policy'),
        content: const SingleChildScrollView(
          child: Text(
            '''CraftConnect uses cookies to enhance your browsing experience:

Essential Cookies:
• Authentication and login sessions
• Shopping cart functionality
• Security and fraud prevention

Analytics Cookies:
• Understanding how you use our site
• Improving our services
• Measuring performance

Personalization Cookies:
• Remembering your preferences
• Customizing content recommendations
• Language and theme settings

You can control cookie settings in your browser. Note that disabling certain cookies may limit site functionality.''',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class CookieConsentManager {
  static const String _cookieConsentKey = 'cookie_consent_given';

  static Future<void> configureCookies(bool consent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cookieConsentKey, consent);

      if (!consent) {
        // Clear analytics and non-essential data
        await _clearNonEssentialData();
      }
    } catch (e) {
      debugPrint('Error configuring cookies: $e');
    }
  }

  static Future<void> _clearNonEssentialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear analytics preferences but keep essential app data
      await prefs.remove('analytics_enabled');
      await prefs.remove('personalization_data');
    } catch (e) {
      debugPrint('Error clearing non-essential data: $e');
    }
  }

  static Future<bool> isAnalyticsEnabled() async {
    if (!kIsWeb) return true;
    return await CookieConsentBanner.hasUserAcceptedCookies();
  }
}
