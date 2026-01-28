import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/stateless_stateful_demo.dart'; // ✅ Module 2 screen
import 'screens/dev_tools_demo_screen.dart'; // ✅ Hot Reload & DevTools demo
import 'screens/home_screen.dart';
import 'screens/second_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/scrollable_views.dart'; // ✅ ListView & GridView demo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CraftConnectApp());
}

class CraftConnectApp extends StatelessWidget {
  const CraftConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CraftConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const DevToolsDemoScreen(), // ✅ Hot Reload & DevTools demo
      // Alternative: DemoScreen() for Stateless vs Stateful demo
      routes: {
        '/home': (context) => const HomeScreen(),
        '/second': (context) => const SecondScreen(),
        '/responsive': (context) => const ResponsiveLayout(),
        '/scrollable': (context) => ScrollableViews(),
      },
    );
  }
}
