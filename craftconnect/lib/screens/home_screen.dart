import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/info_card.dart';
import 'animation_demo_screen.dart'; // ✅ ADDED

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
            // ✅ Reusable InfoCard widgets
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

            // ✅ UPDATED: Navigation with animated page transition
            CustomButton(
              text: 'Go to Animation Demo',
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AnimationDemoScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0), // slide from right
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
