import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';

// Providers
import 'providers/counter_state.dart';
import 'providers/favorites_state.dart';
import 'providers/theme_state.dart';
import 'providers/cart_state.dart';

// Screens
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/second_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/responsive_demo_screen.dart';
import 'screens/scrollable_views.dart';
import 'screens/user_input_form.dart';
import 'screens/animation_demo_screen.dart';
import 'screens/state_management_demo.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/dev_tools_demo_screen.dart';
import 'screens/firestore_tasks_screen.dart';
import 'screens/auth_gate.dart';
import 'screens/firestore_write_screen.dart';
import 'screens/realtime_tasks_screen.dart';
import 'screens/push_notification_demo_screen.dart';
import 'screens/firestore_security_demo_screen.dart';
import 'screens/maps_screen.dart';
import 'screens/provider_demo_hub.dart';
import 'screens/provider_counter_screen.dart';
import 'screens/provider_counter_display_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/favorites_list_screen.dart';
import 'screens/shopping_cart_screen.dart';
import 'screens/theme_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Push Notifications
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterState()),
        ChangeNotifierProvider(create: (_) => FavoritesState()),
        ChangeNotifierProvider(create: (_) => ThemeState()),
        ChangeNotifierProvider(create: (_) => CartState()),
      ],
      child: const CraftConnectApp(),
    ),
  );
}

class CraftConnectApp extends StatelessWidget {
  const CraftConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeState>(
      builder: (context, themeState, child) {
        return MaterialApp(
          title: 'CraftConnect',
          debugShowCheckedModeBanner: false,

          theme: themeState.themeData,

          // 🔥 AUTH FLOW ENTRY POINT
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              if (snapshot.hasData) {
                return const HomeScreen();
              }

              return AuthScreen();
            },
          ),

          routes: {
            '/home': (context) => const HomeScreen(),
            '/second': (context) => const SecondScreen(),
            '/responsive': (context) => const ResponsiveLayout(),
            '/responsive-demo': (context) => const ResponsiveDemoScreen(),
            '/scrollable': (context) => ScrollableViews(),
            '/user-input': (context) => UserInputForm(),
            '/animations': (context) => const AnimationDemoScreen(),
            '/state-management': (context) => const StateManagementDemo(),
            '/stateless-vs-stateful': (context) => const DemoScreen(),
            '/dev-tools': (context) => const DevToolsDemoScreen(),
            '/firestore-tasks': (context) => const FirestoreTasksScreen(),

            // 🔐 CRUD + AUTH
            '/crud-demo': (context) => const AuthGate(),

            // 🔥 FIREBASE DEMOS
            '/firestore-write': (context) => const FirestoreWriteScreen(),
            '/realtime-tasks': (context) => const RealtimeTasksScreen(),
            '/push-notifications': (context) =>
                const PushNotificationDemoScreen(),
            '/firestore-security': (context) =>
                const FirestoreSecurityDemoScreen(),

            // 🗺️ MAPS
            '/maps': (context) => const MapsScreen(),

            // 🎯 PROVIDER STATE MANAGEMENT
            '/provider-demo': (context) => const ProviderDemoHub(),
            '/provider-counter': (context) => const ProviderCounterScreen(),
            '/provider-counter-display': (context) =>
                const ProviderCounterDisplayScreen(),
            '/favorites': (context) => const FavoritesScreen(),
            '/favorites-list': (context) => const FavoritesListScreen(),
            '/shopping-cart': (context) => const ShoppingCartScreen(),
            '/theme-settings': (context) => const ThemeSettingsScreen(),
          },
        );
      },
    );
  }
}
