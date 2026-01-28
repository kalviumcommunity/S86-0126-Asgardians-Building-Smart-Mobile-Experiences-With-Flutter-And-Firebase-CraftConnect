import 'package:flutter/material.dart';

/// ----------------------------
/// Dev Tools Demonstration Screen
/// This screen demonstrates:
/// 1. Hot Reload
/// 2. Debug Console
/// 3. Flutter DevTools
/// 4. Multi-screen Navigation (Navigator & Routes)
/// ----------------------------

class DevToolsDemoScreen extends StatefulWidget {
  const DevToolsDemoScreen({super.key});

  @override
  State<DevToolsDemoScreen> createState() => _DevToolsDemoScreenState();
}

class _DevToolsDemoScreenState extends State<DevToolsDemoScreen> {
  int clickCount = 0;
  Color backgroundColor = Colors.blue.shade50;
  String displayText = 'Welcome to Hot Reload Demo!';
  double fontSize = 24.0;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 DevToolsDemoScreen initialized');
  }

  void incrementCounter() {
    setState(() {
      clickCount++;
      debugPrint('✅ Counter incremented to: $clickCount');
    });
  }

  void changeColor() {
    setState(() {
      backgroundColor = backgroundColor == Colors.blue.shade50
          ? Colors.green.shade50
          : Colors.blue.shade50;
      debugPrint('🎨 Background color changed');
    });
  }

  void resetAll() {
    setState(() {
      clickCount = 0;
      backgroundColor = Colors.blue.shade50;
      displayText = 'Welcome to Hot Reload Demo!';
      fontSize = 24.0;
      debugPrint('🔄 State reset');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hot Reload & DevTools Demo'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.speed, size: 60, color: Colors.teal),
                      const SizedBox(height: 10),
                      Text(
                        displayText,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Counter Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Click Counter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '$clickCount',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: incrementCounter,
                        child: const Text('Increment Counter'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Actions Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Demo Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: changeColor,
                        child: const Text('Toggle Background Color'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: resetAll,
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 Navigation Section (FINAL)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Navigation Demo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        child: const Text('Go to Home Screen'),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/second');
                        },
                        child: const Text('Go to Second Screen'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
