import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_state.dart';
import '../providers/favorites_state.dart';
import '../providers/cart_state.dart';

/// Main hub for Provider state management demos
class ProviderDemoHub extends StatelessWidget {
  const ProviderDemoHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider State Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              Navigator.pushNamed(context, '/theme-settings');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: Colors.blue,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📚 Provider State Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore different state management patterns using Provider. '
                    'Each demo shows how to share and update state across multiple screens.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Counter Demo
          _DemoCard(
            title: 'Counter State',
            description: 'Basic state management with increment/decrement',
            icon: Icons.add_circle_outline,
            color: Colors.teal,
            stats: Consumer<CounterState>(
              builder: (context, counter, child) {
                return Text('Current: ${counter.count}');
              },
            ),
            onTap: () {
              Navigator.pushNamed(context, '/provider-counter');
            },
          ),

          // Favorites Demo
          _DemoCard(
            title: 'Favorites List',
            description: 'Managing a list of favorite items across screens',
            icon: Icons.favorite,
            color: Colors.red,
            stats: Consumer<FavoritesState>(
              builder: (context, favorites, child) {
                return Text('${favorites.count} favorites');
              },
            ),
            onTap: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),

          // Shopping Cart Demo
          _DemoCard(
            title: 'Shopping Cart',
            description: 'Complex state with calculations and multiple operations',
            icon: Icons.shopping_cart,
            color: Colors.orange,
            stats: Consumer<CartState>(
              builder: (context, cart, child) {
                return Text(
                  '${cart.totalQuantity} items - \$${cart.totalPrice.toStringAsFixed(2)}',
                );
              },
            ),
            onTap: () {
              Navigator.pushNamed(context, '/shopping-cart');
            },
          ),

          // Theme Settings
          _DemoCard(
            title: 'Theme Settings',
            description: 'App-wide theme management',
            icon: Icons.palette,
            color: Colors.purple,
            stats: const Text('Global theme state'),
            onTap: () {
              Navigator.pushNamed(context, '/theme-settings');
            },
          ),

          const SizedBox(height: 20),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Key Concepts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('• ChangeNotifier: Base class for state objects'),
                  Text('• Provider: Makes state available to widgets'),
                  Text('• Consumer: Rebuilds when state changes'),
                  Text('• context.read(): Updates state without rebuilding'),
                  Text('• context.watch(): Listens to state changes'),
                  SizedBox(height: 10),
                  Text(
                    'Navigate through each demo to see Provider in action!',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget stats;
  final VoidCallback onTap;

  const _DemoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DefaultTextStyle(
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                      child: stats,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
