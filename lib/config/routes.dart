import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../screens/common/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/artisan/dashboard_screen.dart';
import '../screens/artisan/create_shop_screen.dart';
import '../screens/artisan/add_product_screen.dart';
import '../screens/artisan/products_list_screen.dart';
import '../screens/artisan/orders_screen.dart';
import '../screens/artisan/order_details_screen.dart';
import '../screens/artisan/settings_screen.dart';
import '../screens/buyer/main_navigation.dart';
import '../screens/buyer/home_screen.dart';
import '../screens/buyer/orders_list_screen.dart';
import '../screens/buyer/cart_screen.dart';
import '../screens/buyer/account_screen.dart';
import '../screens/buyer/store_page.dart';
import '../screens/buyer/product_page.dart';
import '../screens/buyer/category_products_screen.dart';
import '../screens/buyer/search_screen.dart';
import '../screens/buyer/checkout_screen.dart';
import '../screens/buyer/cart_checkout_screen.dart';
import '../screens/buyer/payment_screen.dart';
import '../screens/buyer/order_tracking_screen.dart';
import '../screens/buyer/order_confirmation_screen.dart';
import '../screens/buyer/edit_profile_screen.dart';
import '../screens/buyer/help_support_screen.dart';
import '../screens/buyer/address_management_screen.dart';
import '../screens/buyer/payment_methods_screen.dart';
import '../screens/buyer/wishlist_screen.dart';
import '../screens/buyer/notifications_screen.dart';
import '../screens/buyer/all_products_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/artisan_management.dart';
import '../screens/admin/analytics_screen.dart';
import '../screens/admin/return_management_screen.dart';
import '../screens/admin/coupon_management_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/admin/review_moderation_screen.dart';
import '../screens/buyer/chat_list_screen.dart';
import '../screens/buyer/chat_room_screen.dart';
import '../screens/buyer/return_request_screen.dart';
import '../screens/buyer/apply_coupon_screen.dart';
import '../screens/buyer/product_compare_screen.dart';
import '../screens/buyer/recently_viewed_screen.dart';
import '../screens/buyer/artisan_profile_screen.dart';
import '../screens/buyer/following_screen.dart';
import '../screens/artisan/shop_analytics_screen.dart';
import '../screens/artisan/inventory_management_screen.dart';
import '../screens/legal/privacy_policy_screen.dart';
import '../screens/legal/terms_conditions_screen.dart';
import '../screens/legal/return_policy_screen.dart';
import '../screens/legal/gdpr_data_deletion_screen.dart';
import '../screens/common/developer_tools_screen.dart';
import '../models/product_model.dart';
import '../models/conversation_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash & Auth
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return OtpVerificationScreen(
            phoneNumber: extra?['phoneNumber'] ?? '',
            verificationId: extra?['verificationId'] ?? '',
          );
        },
      ),

      // Artisan Routes
      GoRoute(
        path: '/artisan/dashboard',
        builder: (context, state) => const ArtisanDashboardScreen(),
      ),
      GoRoute(
        path: '/artisan/create-shop',
        builder: (context, state) => const CreateShopScreen(),
      ),
      GoRoute(
        path: '/artisan/add-product',
        builder: (context, state) {
          final shopId = state.uri.queryParameters['shopId'] ?? '';
          final product = state.extra as ProductModel?;
          return AddProductScreen(shopId: shopId, product: product);
        },
      ),
      GoRoute(
        path: '/artisan/products',
        builder: (context, state) {
          final shopId = state.uri.queryParameters['shopId'] ?? '';
          return ProductsListScreen(shopId: shopId);
        },
      ),
      GoRoute(
        path: '/artisan/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/artisan/order/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return OrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/artisan/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/artisan/analytics',
        builder: (context, state) => const ShopAnalyticsScreen(),
      ),
      GoRoute(
        path: '/artisan/inventory',
        builder: (context, state) => const InventoryManagementScreen(),
      ),

      // Buyer Routes (Public)
      // Buyer Routes (Main Navigation with persistent tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigation(navigationShell: navigationShell);
        },
        branches: [
          // Branch Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'product/:productId',
                    builder: (context, state) {
                      final productId = state.pathParameters['productId'] ?? '';
                      return ProductPage(productId: productId);
                    },
                  ),
                  GoRoute(
                    path: 'shop/:slug',
                    builder: (context, state) {
                      final slug = state.pathParameters['slug'] ?? '';
                      return StorePage(shopSlug: slug);
                    },
                  ),
                  GoRoute(
                    path: 'category/:categoryName',
                    builder: (context, state) {
                      final category =
                          state.pathParameters['categoryName'] ?? '';
                      return CategoryProductsScreen(category: category);
                    },
                  ),
                  GoRoute(
                    path: 'search',
                    builder: (context, state) {
                      final query = state.uri.queryParameters['q'] ?? '';
                      return SearchScreen(initialQuery: query);
                    },
                  ),
                  GoRoute(
                    path: 'all-products',
                    builder: (context, state) {
                      final categoryId = state.uri.queryParameters['category'];
                      final title = state.uri.queryParameters['title'];
                      return AllProductsScreen(
                        categoryId: categoryId,
                        title: title,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'compare-products',
                    builder: (context, state) {
                      final productIds =
                          state.uri.queryParameters['productIds']?.split(',');
                      return ProductCompareScreen(
                          initialProductIds: productIds);
                    },
                  ),
                  GoRoute(
                    path: 'artisan/:shopId',
                    builder: (context, state) {
                      final shopId = state.pathParameters['shopId'] ?? '';
                      return ArtisanProfileScreen(shopId: shopId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersListScreen(),
                routes: [
                  GoRoute(
                    path: 'track-order/:orderId',
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId'] ?? '';
                      return OrderTrackingScreen(orderId: orderId);
                    },
                  ),
                  GoRoute(
                    path: 'order-confirmation',
                    builder: (context, state) =>
                        const OrderConfirmationScreen(),
                  ),
                  GoRoute(
                    path: 'return-request/:orderId',
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId'] ?? '';
                      return ReturnRequestScreen(orderId: orderId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
                routes: [
                  GoRoute(
                    path: 'checkout',
                    builder: (context, state) {
                      final productId =
                          state.uri.queryParameters['productId'] ?? '';
                      final shopId = state.uri.queryParameters['shopId'] ?? '';
                      final artisanId =
                          state.uri.queryParameters['artisanId'] ?? '';
                      final quantity = int.parse(
                        state.uri.queryParameters['quantity'] ?? '1',
                      );
                      return CheckoutScreen(
                        productId: productId,
                        shopId: shopId,
                        artisanId: artisanId,
                        quantity: quantity,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'cart-checkout',
                    builder: (context, state) => const CartCheckoutScreen(),
                  ),
                  GoRoute(
                    path: 'payment',
                    builder: (context, state) {
                      final orderId =
                          state.uri.queryParameters['orderId'] ?? '';
                      final amount = double.parse(
                        state.uri.queryParameters['amount'] ?? '0',
                      );
                      final name = state.uri.queryParameters['name'] ?? '';
                      final phone = state.uri.queryParameters['phone'] ?? '';
                      final address =
                          state.uri.queryParameters['address'] ?? '';
                      final upiId = state.uri.queryParameters['upiId'] ?? '';
                      final productId =
                          state.uri.queryParameters['productId'] ?? '';
                      final shopId = state.uri.queryParameters['shopId'] ?? '';
                      final artisanId =
                          state.uri.queryParameters['artisanId'] ?? '';
                      final quantity = int.parse(
                        state.uri.queryParameters['quantity'] ?? '1',
                      );
                      final hasGiftWrapping =
                          state.uri.queryParameters['hasGiftWrapping'] ==
                              'true';
                      final giftMessage =
                          state.uri.queryParameters['giftMessage'];
                      final giftWrappingCharge = double.parse(
                        state.uri.queryParameters['giftWrappingCharge'] ??
                            '0.0',
                      );
                      return PaymentScreen(
                        orderId: orderId,
                        amount: amount,
                        name: name,
                        phone: phone,
                        address: address,
                        upiId: upiId,
                        productId: productId,
                        shopId: shopId,
                        artisanId: artisanId,
                        quantity: quantity,
                        hasGiftWrapping: hasGiftWrapping,
                        giftMessage: giftMessage,
                        giftWrappingCharge: giftWrappingCharge,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'apply-coupon',
                    builder: (context, state) {
                      final orderAmount = double.tryParse(
                            state.uri.queryParameters['orderAmount'] ?? '0',
                          ) ??
                          0;
                      return ApplyCouponScreen(orderAmount: orderAmount);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch Account
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountScreen(),
                routes: [
                  GoRoute(
                    path: 'edit-profile',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'help-support',
                    builder: (context, state) => const HelpSupportScreen(),
                  ),
                  GoRoute(
                    path: 'addresses',
                    builder: (context, state) =>
                        const AddressManagementScreen(),
                  ),
                  GoRoute(
                    path: 'payment-methods',
                    builder: (context, state) => const PaymentMethodsScreen(),
                  ),
                  GoRoute(
                    path: 'wishlist',
                    builder: (context, state) => const WishlistScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'recently-viewed',
                    builder: (context, state) => const RecentlyViewedScreen(),
                  ),
                  GoRoute(
                    path: 'following',
                    builder: (context, state) => const FollowingScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch Chat
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatListScreen(),
                routes: [
                  GoRoute(
                    path: 'room/:conversationId',
                    builder: (context, state) {
                      final conversationId =
                          state.pathParameters['conversationId'] ?? '';
                      final conversation = state.extra as ConversationModel?;
                      return ChatRoomScreen(
                        conversationId: conversationId,
                        conversation: conversation,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/artisans',
        builder: (context, state) => const ArtisanManagement(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin/returns',
        builder: (context, state) => const AdminReturnManagementScreen(),
      ),
      GoRoute(
        path: '/admin/coupons',
        builder: (context, state) => const AdminCouponManagementScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/reviews',
        builder: (context, state) => const ReviewModerationScreen(),
      ),

      // Legal/Policy Routes
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms-conditions',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/return-policy',
        builder: (context, state) => const ReturnPolicyScreen(),
      ),
      GoRoute(
        path: '/gdpr-data-deletion',
        builder: (context, state) => const GDPRDataDeletionScreen(),
      ),

      // Developer Tools (Development only)
      GoRoute(
        path: '/dev-tools',
        builder: (context, state) => const DeveloperToolsScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Route Names (for easy reference)
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';

  // Artisan
  static const String artisanDashboard = '/artisan/dashboard';
  static const String createShop = '/artisan/create-shop';
  static const String addProduct = '/artisan/add-product';
  static const String productsList = '/artisan/products';
  static const String orders = '/artisan/orders';
  static const String settings = '/artisan/settings';

  // Buyer
  static String shop(String slug) => '/shop/$slug';
  static String product(String productId) => '/product/$productId';
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static String trackOrder(String orderId) => '/orders/track-order/$orderId';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String artisanManagement = '/admin/artisans';
  static const String analytics = '/admin/analytics';
}
