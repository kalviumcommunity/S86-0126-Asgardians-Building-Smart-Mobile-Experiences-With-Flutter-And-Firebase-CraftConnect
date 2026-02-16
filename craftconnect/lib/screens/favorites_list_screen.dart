import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_state.dart';

/// Screen displaying only favorited items
/// Demonstrates reading shared state from another screen
class FavoritesListScreen extends StatelessWidget {
  const FavoritesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: Consumer<FavoritesState>(
        builder: (context, favorites, child) {
          if (favorites.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No favorites yet!',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Go back and add some items',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.items.length,
            itemBuilder: (context, index) {
              final item = favorites.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      favorites.removeItem(item);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
