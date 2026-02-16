import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_state.dart';

/// Shopping cart screen
/// Demonstrates complex state with calculations
class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({super.key});

  final List<Map<String, dynamic>> products = const [
    {'id': '1', 'name': 'Handmade Pottery Vase', 'price': 45.99},
    {'id': '2', 'name': 'Wooden Cutting Board', 'price': 29.99},
    {'id': '3', 'name': 'Knitted Scarf', 'price': 35.50},
    {'id': '4', 'name': 'Custom Photo Frame', 'price': 22.00},
    {'id': '5', 'name': 'Artisan Candle Set', 'price': 18.99},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Consumer<CartState>(
            builder: (context, cart, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Badge(
                    label: Text('${cart.totalQuantity}'),
                    child: const Icon(Icons.shopping_cart),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Product List
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(product['name']),
                    subtitle: Text('\$${product['price'].toStringAsFixed(2)}'),
                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        context.read<CartState>().addItem(
                              product['id'],
                              product['name'],
                              product['price'],
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product['name']} added to cart'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('Add'),
                    ),
                  ),
                );
              },
            ),
          ),

          // Cart Summary
          Consumer<CartState>(
            builder: (context, cart, child) {
              if (cart.items.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    'Cart is empty',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  children: [
                    ...cart.items.values.map((item) {
                      return ListTile(
                        dense: true,
                        title: Text(item.name),
                        subtitle: Text('\$${item.price.toStringAsFixed(2)} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                cart.decreaseQuantity(item.id);
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                cart.addItem(item.id, item.name, item.price);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                cart.removeItem(item.id);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${cart.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                cart.clearCart();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Clear Cart'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Checkout'),
                                    content: Text(
                                      'Total: \$${cart.totalPrice.toStringAsFixed(2)}\n'
                                      'Items: ${cart.totalQuantity}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          cart.clearCart();
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Order placed successfully!'),
                                            ),
                                          );
                                        },
                                        child: const Text('Confirm'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('Checkout'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
