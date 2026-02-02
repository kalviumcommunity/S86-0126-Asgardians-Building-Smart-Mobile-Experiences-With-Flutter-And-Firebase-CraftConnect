import 'package:flutter/material.dart';

class AnimationDemoScreen extends StatefulWidget {
  const AnimationDemoScreen({super.key});

  @override
  State<AnimationDemoScreen> createState() => _AnimationDemoScreenState();
}

class _AnimationDemoScreenState extends State<AnimationDemoScreen> {
  bool isAnimated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animations Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔹 AnimatedContainer
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              width: isAnimated ? 200 : 120,
              height: isAnimated ? 120 : 200,
              decoration: BoxDecoration(
                color: isAnimated ? Colors.teal : Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Animated Box',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 AnimatedOpacity
            AnimatedOpacity(
              opacity: isAnimated ? 1.0 : 0.3,
              duration: const Duration(milliseconds: 600),
              child: const Icon(Icons.favorite, size: 50, color: Colors.red),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  isAnimated = !isAnimated;
                });
              },
              child: const Text('Animate'),
            ),
          ],
        ),
      ),
    );
  }
}


class RotateIconDemo extends StatefulWidget {
  const RotateIconDemo({super.key});

  @override
  State<RotateIconDemo> createState() => _RotateIconDemoState();
}

class _RotateIconDemoState extends State<RotateIconDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: controller,
      child: const Icon(Icons.settings, size: 60, color: Colors.teal),
    );
  }
}
