import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_state.dart';

/// Display screen showing the same counter state
/// Demonstrates multi-screen state sharing
class ProviderCounterDisplayScreen extends StatelessWidget {
  const ProviderCounterDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.visibility,
              size: 80,
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            const Text(
              'Same Counter State',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            
            // Using context.watch for automatic rebuilds
            Text(
              '${context.watch<CounterState>().count}',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'This screen displays the same counter state. '
                'Go back and change the counter to see it update here automatically!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
