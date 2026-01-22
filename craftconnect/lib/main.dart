import 'package:flutter/material.dart';
import 'screens/responsive_home.dart'; // <-- Import responsive screen

void main() {
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
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isStarted = false;

  void handleButtonPress() {
    setState(() {
      isStarted = !isStarted;
    });

    if (isStarted) {
      // Navigate to ResponsiveHome after pressing "Explore App"
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ResponsiveHome(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CraftConnect'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isStarted
                  ? 'Connecting Artisans to Customers'
                  : 'Welcome to CraftConnect',
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.storefront,
              size: 80,
              color: isStarted ? Colors.green : Colors.teal,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: handleButtonPress,
              child: Text(isStarted ? 'Explore App' : 'Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
