import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

// Screens
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CraftConnectApp());
}

class CraftConnectApp extends StatelessWidget {
  const CraftConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CraftConnect',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      // 🔥 AUTH FLOW ENTRY POINT
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return AuthScreen();
        },
      ),

      // ✅ EXISTING ROUTES (UNCHANGED)
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
      },
    );
  }
}
