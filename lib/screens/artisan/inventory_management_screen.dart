import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../widgets/empty_state_widget.dart';
import 'package:craftconnect/config/app_constants.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  String _filter = 'all'; // all, low, out

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    await shopProvider.getShopsByOwner(authProvider.currentUser!.uid);

    if (shopProvider.shops.isNotEmpty) {
      await productProvider.getProductsByShop(shopProvider.shops.first.shopId);
    }
  }

  Future<void> _updateStock(String productId, int currentStock) async {
    final controller = TextEditingController(text: currentStock.toString());

    final newStock = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Stock Quantity',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.of(context).pop(value);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (newStock != null && mounted) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      await productProvider.updateStock(productId, newStock);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock updated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    var products = productProvider.products;

    // Apply filters
    if (_filter == 'low') {
      products = products.where((p) => p.stock > 0 && p.stock < 10).toList();
    } else if (_filter == 'out') {
      products = products.where((p) => p.stock == 0).toList();
    }

    final lowStockCount = productProvider.products
        .where((p) => p.stock > 0 && p.stock < 10)
        .length;
    final outOfStockCount =
        productProvider.products.where((p) => p.stock == 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                      'All', 'all', productProvider.products.length),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildFilterChip('Low Stock', 'low', lowStockCount),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child:
                      _buildFilterChip('Out of Stock', 'out', outOfStockCount),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.inventory_2,
                        title: 'No Products',
                        message: _filter == 'all'
                            ? 'Add products to manage inventory'
                            : 'No products in this category',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final stockStatus = product.stock == 0
                                ? 'Out of Stock'
                                : product.stock < 10
                                    ? 'Low Stock'
                                    : 'In Stock';
                            final statusColor = product.stock == 0
                                ? AppTheme.errorColor
                                : product.stock < 10
                                    ? AppTheme.warningColor
                                    : AppTheme.successColor;

                            return Card(
                              margin:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: ListTile(
                                leading: product.imageUrl != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.sm),
                                        child: Image.network(
                                          product.imageUrl!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.sm),
                                        ),
                                        child: const Icon(Icons.image),
                                      ),
                                title: Text(product.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Stock: ${product.stock}'),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        stockStatus,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _updateStock(
                                        product.productId,
                                        product.stock,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward),
                                      onPressed: () {
                                        context.push(
                                          '/artisan/add-product?shopId=${product.shopId}',
                                          extra: product,
                                        );
                                      },
                                    ),
                                  ],
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
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filter == value;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}