import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/info_card.dart'; // ✅ ADDED

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ ADDED: Reusable InfoCard widgets
            const InfoCard(
              title: 'Products',
              subtitle: 'View all products',
              icon: Icons.shopping_bag,
            ),

            const InfoCard(
              title: 'Profile',
              subtitle: 'Manage your account',
              icon: Icons.person,
            ),

            const SizedBox(height: 30),
            CustomButton(
              text: 'Go to Second Screen',
              onPressed: () {
                Navigator.pushNamed(context, '/second');
              },
            ),
          ],
        ),
      ),
    );
  }
}
