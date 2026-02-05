import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../services/sample_data_service.dart';

class FirestoreQueriesScreen extends StatefulWidget {
  const FirestoreQueriesScreen({super.key});

  @override
  State<FirestoreQueriesScreen> createState() => _FirestoreQueriesScreenState();
}

class _FirestoreQueriesScreenState extends State<FirestoreQueriesScreen> {
  String selectedQuery = 'All Products';
  double minPrice = 0;
  double maxPrice = 1000;
  String selectedCategory = 'All';
  bool showInStockOnly = false;
  String sortBy = 'name';
  bool descending = false;
  int limitCount = 10;
  bool _isLoading = false;

  final SampleDataService _sampleDataService = SampleDataService();

  final List<String> queryTypes = [
    'All Products',
    'Price Filter',
    'Category Filter',
    'In Stock Only',
    'High Rated (>4.0)',
    'Sorted by Price',
    'Sorted by Rating',
    'Limited Results',
    'Complex Query',
  ];

  final List<String> categories = [
    'All',
    'Ceramics',
    'Textiles',
    'Jewelry',
    'Woodwork',
    'Paintings',
  ];

  final List<String> sortOptions = ['name', 'price', 'rating', 'createdAt'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Queries Demo'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildQueryControls(),
          Expanded(child: _buildQueryResults()),
        ],
      ),
    );
  }

  Widget _buildQueryControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        border: Border(bottom: BorderSide(color: Colors.teal.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Query Type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedQuery,
            isExpanded: true,
            items: queryTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedQuery = value ?? 'All Products';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildSampleDataControls(),
          const SizedBox(height: 16),
          _buildAdditionalControls(),
        ],
      ),
    );
  }

  Widget _buildAdditionalControls() {
    switch (selectedQuery) {
      case 'Price Filter':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price Range: \$${minPrice.toInt()} - \$${maxPrice.toInt()}'),
            RangeSlider(
              values: RangeValues(minPrice, maxPrice),
              min: 0,
              max: 1000,
              divisions: 20,
              labels: RangeLabels(
                '\$${minPrice.toInt()}',
                '\$${maxPrice.toInt()}',
              ),
              onChanged: (values) {
                setState(() {
                  minPrice = values.start;
                  maxPrice = values.end;
                });
              },
            ),
          ],
        );
      case 'Category Filter':
        return DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          items: categories.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value ?? 'All';
            });
          },
        );
      case 'Sorted by Price':
      case 'Sorted by Rating':
        return Row(
          children: [
            Text('Sort Order: '),
            Switch(
              value: descending,
              onChanged: (value) {
                setState(() {
                  descending = value;
                });
              },
            ),
            Text(descending ? 'Descending' : 'Ascending'),
          ],
        );
      case 'Limited Results':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Limit: $limitCount results'),
            Slider(
              value: limitCount.toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              label: '$limitCount',
              onChanged: (value) {
                setState(() {
                  limitCount = value.toInt();
                });
              },
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildQueryResults() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _getQueryStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Query Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade500),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Retry
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No Products Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or add data to Firestore',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Text(
                'Found ${docs.length} products • Query: $selectedQuery',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  return _buildProductCard(data);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getQueryStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      'products',
    );

    switch (selectedQuery) {
      case 'All Products':
        return query.snapshots();

      case 'Price Filter':
        return query
            .where('price', isGreaterThanOrEqualTo: minPrice)
            .where('price', isLessThanOrEqualTo: maxPrice)
            .snapshots();

      case 'Category Filter':
        if (selectedCategory == 'All') {
          return query.snapshots();
        }
        return query.where('category', isEqualTo: selectedCategory).snapshots();

      case 'In Stock Only':
        return query.where('inStock', isEqualTo: true).snapshots();

      case 'High Rated (>4.0)':
        return query.where('rating', isGreaterThan: 4.0).snapshots();

      case 'Sorted by Price':
        return query.orderBy('price', descending: descending).snapshots();

      case 'Sorted by Rating':
        return query.orderBy('rating', descending: descending).snapshots();

      case 'Limited Results':
        return query.limit(limitCount).snapshots();

      case 'Complex Query':
        return query
            .where('inStock', isEqualTo: true)
            .where('rating', isGreaterThan: 3.5)
            .orderBy('rating', descending: true)
            .limit(5)
            .snapshots();

      default:
        return query.snapshots();
    }
  }

  Widget _buildProductCard(Map<String, dynamic> data) {
    final product = Product.fromJson(data);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.image, color: Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: ${product.category}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Stock Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: product.inStock
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.inStock ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: product.inStock
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleDataControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sample Data Management',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _populateSampleData,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_box),
                  label: const Text('Add Sample Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _clearAllData,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Add sample products to test queries or clear all data',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
          ),
        ],
      ),
    );
  }

  Future<void> _populateSampleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasData = await _sampleDataService.hasSampleData();
      if (hasData) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sample data already exists!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        await _sampleDataService.populateSampleProducts();
        await _sampleDataService.populateSampleTasks();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sample data added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all products and tasks from Firestore. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _sampleDataService.clearAllProducts();

      // Also clear tasks
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .get();
      for (final doc in tasksSnapshot.docs) {
        await doc.reference.delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
