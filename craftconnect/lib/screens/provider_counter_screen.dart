import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_state.dart';

/// Counter screen demonstrating Provider state management
class ProviderCounterScreen extends StatelessWidget {
  const ProviderCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Counter Value:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            
            // Using Consumer for selective rebuilds
            Consumer<CounterState>(
              builder: (context, counter, child) {
                return Text(
                  '${counter.count}',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'decrement',
                  onPressed: () {
                    context.read<CounterState>().decrement();
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: 'reset',
                  onPressed: () {
                    context.read<CounterState>().reset();
                  },
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: 'increment',
                  onPressed: () {
                    context.read<CounterState>().increment();
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/provider-counter-display');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View Counter on Another Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
