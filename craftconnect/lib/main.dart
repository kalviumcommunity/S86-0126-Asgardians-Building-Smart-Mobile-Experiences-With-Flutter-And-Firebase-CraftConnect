import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/stateless_stateful_demo.dart'; // ✅ Module 2 screen
import 'screens/dev_tools_demo_screen.dart'; // ✅ Hot Reload & DevTools demo

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
    );
  }
}
