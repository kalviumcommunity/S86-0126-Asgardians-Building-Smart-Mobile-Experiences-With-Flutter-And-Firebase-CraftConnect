import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/address_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/review_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/search_history_provider.dart';
import 'providers/coupon_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/return_provider.dart';
import 'providers/recently_viewed_provider.dart';
import 'providers/follow_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/font_size_provider.dart';
import 'services/notification_service.dart';
import 'services/deep_link_service.dart';
import 'widgets/cookie_consent_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services
  final deepLinkService = DeepLinkService();
  await NotificationService().initialize();
  await deepLinkService.initialize();

  // Set router for deep linking (will be set after router is created)
  deepLinkService.setRouter(AppRouter.router);

  runApp(const CraftConnectApp());
}

class CraftConnectApp extends StatelessWidget {
  const CraftConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SearchHistoryProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ReturnProvider()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
        ChangeNotifierProvider(create: (_) => FollowProvider()),
      ],
      child: Consumer3<AuthProvider, ThemeProvider, FontSizeProvider>(
        builder: (context, authProvider, themeProvider, fontSizeProvider, _) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                MaterialApp.router(
                  title: 'CraftConnect',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme.copyWith(
                    textTheme: AppTheme.lightTheme.textTheme.apply(
                      fontSizeFactor: fontSizeProvider.fontScale,
                    ),
                  ),
                  darkTheme: AppTheme.darkTheme.copyWith(
                    textTheme: AppTheme.darkTheme.textTheme.apply(
                      fontSizeFactor: fontSizeProvider.fontScale,
                    ),
                  ),
                  themeMode: themeProvider.themeMode,

                  // Localization
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'), // English
                    Locale('hi'), // Hindi
                    Locale('te'), // Telugu
                  ],
                  locale: authProvider.currentLocale,

                  // Routing
                  routerConfig: AppRouter.router,
                ),

                // Cookie Consent Banner (Web only)
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CookieConsentBanner(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
