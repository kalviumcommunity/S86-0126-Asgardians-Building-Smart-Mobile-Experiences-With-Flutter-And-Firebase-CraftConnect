import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';

// Theme imports
import 'providers/theme_provider.dart';
import 'theme/light_theme.dart';
import 'theme/dark_theme.dart';

// Screens
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/second_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/responsive_demo_screen.dart';
import 'screens/scrollable_views.dart';
import 'screens/user_input_form.dart';
import 'screens/asset_demo_screen.dart';
import 'screens/animation_demo_screen.dart';
import 'screens/state_management_demo.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/dev_tools_demo_screen.dart';
import 'screens/firestore_tasks_screen.dart';
import 'screens/firestore_write_screen.dart';
import 'screens/realtime_tasks_screen.dart';
import 'screens/push_notification_demo_screen.dart';
import 'screens/firestore_security_demo_screen.dart';
import 'screens/maps_screen.dart';
import 'screens/theme_settings_screen.dart';
import 'screens/theme_example_screen.dart';

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

  // Initialize and run app with theme provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider()..initializeTheme(),
      child: const CraftConnectApp(),
    ),
  );
}

class CraftConnectApp extends StatelessWidget {
  const CraftConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return DynamicColorBuilder(
          builder: (context, lightDynamic, darkDynamic) {
            // Determine which themes to use
            ThemeData lightTheme;
            ThemeData darkTheme;

            if (themeProvider.isDynamicColorEnabled &&
                lightDynamic != null &&
                darkDynamic != null) {
              // Use dynamic colors when available and enabled
              lightTheme = ThemeData(
                colorScheme: lightDynamic,
                useMaterial3: true,
              );
              darkTheme = ThemeData(
                colorScheme: darkDynamic,
                useMaterial3: true,
              );
            } else {
              // Fallback to custom themes
              lightTheme = LightTheme.theme;
              darkTheme = DarkTheme.theme;
            }

            return MaterialApp(
              title: 'CraftConnect',
              debugShowCheckedModeBanner: false,

              // Theme configuration
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeProvider.themeMode,

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
                '/firestore-write': (context) => const FirestoreWriteScreen(),
                '/realtime-tasks': (context) => const RealtimeTasksScreen(),
                '/push-notifications': (context) =>
                    const PushNotificationDemoScreen(),
                '/firestore-security': (context) =>
                    const FirestoreSecurityDemoScreen(),
                '/maps': (context) => const MapsScreen(),
                '/theme-settings': (context) => const ThemeSettingsScreen(),
                '/theme-examples': (context) => const ThemeExampleScreen(),
              },
            );
          },
        );
      },
    );
  }
}
