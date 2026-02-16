import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_state.dart';

/// Favorites management screen
/// Demonstrates list-based state management
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  final List<String> availableItems = const [
    '🎨 Pottery',
    '🪵 Woodworking',
    '🧶 Knitting',
    '📸 Photography',
    '🎭 Theater',
    '🎸 Music',
    '✍️ Writing',
    '🍳 Cooking',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          Consumer<FavoritesState>(
            builder: (context, favorites, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    '${favorites.count} favorites',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: availableItems.length,
              itemBuilder: (context, index) {
                final item = availableItems[index];
                return Consumer<FavoritesState>(
                  builder: (context, favorites, child) {
                    final isFavorite = favorites.isFavorite(item);
                    return ListTile(
                      title: Text(item),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          favorites.toggleFavorite(item);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/favorites-list');
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('View Favorites List'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    context.read<FavoritesState>().clearAll();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
