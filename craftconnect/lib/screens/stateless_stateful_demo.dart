import 'package:flutter/material.dart';

/// ----------------------------
/// Stateless Widget
/// ----------------------------
class HeaderText extends StatelessWidget {
  const HeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Interactive Counter App',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// ----------------------------
/// Stateful Widget
/// ----------------------------
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;

  void increment() {
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Count: $count',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: increment,
          child: const Text('Increase'),
        ),
      ],
    );
  }
}

/// ----------------------------
/// Main Screen (Uses both)
/// ----------------------------
class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateless vs Stateful Widgets'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            HeaderText(),      // Stateless widget
            SizedBox(height: 20),
            CounterWidget(),   // Stateful widget
          ],
        ),
      ),
    );
  }
}
