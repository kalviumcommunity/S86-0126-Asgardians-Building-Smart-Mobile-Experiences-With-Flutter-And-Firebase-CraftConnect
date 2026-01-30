import 'package:flutter/material.dart';

class AssetDemoScreen extends StatelessWidget {
  const AssetDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assets Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Local Image
            Image.asset(
              'assets/images/logo.png',
              width: 120,
            ),

            const SizedBox(height: 20),

            const Text(
              'CraftConnect',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Built-in Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star, color: Colors.amber, size: 32),
                SizedBox(width: 10),
                Icon(Icons.favorite, color: Colors.red, size: 32),
                SizedBox(width: 10),
                Icon(Icons.shopping_cart, color: Colors.blue, size: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
