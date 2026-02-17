import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';

import '../../widgets/empty_state_widget.dart';
import 'package:craftconnect/config/app_constants.dart';

class ProductCompareScreen extends StatefulWidget {
  final List<String>? initialProductIds;

  const ProductCompareScreen({
    super.key,
    this.initialProductIds,
  });

  @override
  State<ProductCompareScreen> createState() => _ProductCompareScreenState();
}

class _ProductCompareScreenState extends State<ProductCompareScreen> {
  final List<ProductModel?> _compareProducts = [null, null, null];

  @override
  void initState() {
    super.initState();
    if (widget.initialProductIds != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialProducts();
      });
    }
  }

  Future<void> _loadInitialProducts() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    for (int i = 0; i < widget.initialProductIds!.length && i < 3; i++) {
      final product =
          await productProvider.getProductById(widget.initialProductIds![i]);
      if (product != null && mounted) {
        setState(() {
          _compareProducts[i] = product;
        });
      }
    }
  }

  Future<void> _selectProduct(int index) async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    final selectedProduct = await showDialog<ProductModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Product'),
        content: SizedBox(
          width: double.maxFinite,
          child: productProvider.products.isEmpty
              ? const Center(child: Text('No products available'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, i) {
                    final product = productProvider.products[i];

                    // Don't show products already selected
                    if (_compareProducts.contains(product)) {
                      return const SizedBox.shrink();
                    }

                    return ListTile(
                      leading: product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              child: CachedNetworkImage(
                                imageUrl: product.imageUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(Icons.image),
                            ),
                      title: Text(product.name),
                      subtitle: Text('₹${product.price.toStringAsFixed(0)}'),
                      onTap: () => Navigator.of(context).pop(product),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedProduct != null && mounted) {
      setState(() {
        _compareProducts[index] = selectedProduct;
      });
    }
  }

  void _removeProduct(int index) {
    setState(() {
      _compareProducts[index] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasProducts = _compareProducts.any((p) => p != null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Products'),
        actions: [
          if (hasProducts)
            TextButton(
              onPressed: () {
                setState(() {
                  _compareProducts.fillRange(0, _compareProducts.length, null);
                });
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: hasProducts
          ? SingleChildScrollView(
              child: Column(
                children: [
                  // Product Images Row
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: List.generate(
                        3,
                        (index) => Expanded(
                          child: _buildProductCard(index),
                        ),
                      ),
                    ),
                  ),

                  // Comparison Table
                  _buildComparisonTable(),
                ],
              ),
            )
          : EmptyStateWidget(
              icon: Icons.compare_arrows,
              title: 'No Products to Compare',
              message: 'Add products to start comparing',
              actionLabel: 'Add Product',
              onAction: () => _selectProduct(0),
            ),
    );
  }

  Widget _buildProductCard(int index) {
    final product = _compareProducts[index];

    return Container(
      margin: EdgeInsets.only(
        right: index < 2 ? AppSpacing.sm : 0,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: product == null
          ? InkWell(
              onTap: () => _selectProduct(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add Product',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: product.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 48),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Text(
                        product.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => _removeProduct(index),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(28, 28),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.sync, size: 20),
                        onPressed: () => _selectProduct(index),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(28, 28),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildComparisonTable() {
    final attributes = [
      ('Price', (ProductModel p) => '₹${p.price.toStringAsFixed(0)}'),
      ('Category', (ProductModel p) => p.category),
      ('Stock', (ProductModel p) => p.stock.toString()),
      ('Rating', (ProductModel p) => '${p.averageRating.toStringAsFixed(1)} ⭐'),
      ('Reviews', (ProductModel p) => p.reviewCount.toString()),
    ];

    return Column(
      children: attributes.map((attr) {
        final label = attr.$1;
        final getValue = attr.$2;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: List.generate(
                    3,
                    (index) {
                      final product = _compareProducts[index];
                      return Expanded(
                        child: Center(
                          child: Text(
                            product != null ? getValue(product) : '-',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
