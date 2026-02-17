import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../providers/shop_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

class StorePage extends StatefulWidget {
  final String shopSlug;
  const StorePage({super.key, required this.shopSlug});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  @override
  void initState() {
    super.initState();
    // Load store after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStore();
    });
  }

  Future<void> _loadStore() async {
    debugPrint('StorePage: Loading store with slug: ${widget.shopSlug}');
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final shop = await shopProvider.getShopBySlug(widget.shopSlug);

    if (shop != null && mounted) {
      debugPrint(
          'StorePage: Shop found: ${shop.shopName}, shopId: ${shop.shopId}');
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      await productProvider.getProductsByShop(shop.shopId);
      debugPrint(
          'StorePage: Products loaded: ${productProvider.products.length}');
    } else {
      debugPrint('StorePage: Shop not found for slug: ${widget.shopSlug}');
    }
  }

  void _shareStore() {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    if (shopProvider.currentShop != null) {
      Share.share(
        'Check out ${shopProvider.currentShop!.shopName} on CraftConnect!\n${shopProvider.currentShop!.storeUrl}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ShopProvider, ProductProvider>(
        builder: (context, shopProvider, productProvider, child) {
          if (shopProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final shop = shopProvider.currentShop;
          if (shop == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 80,
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Shop not found',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Shop Header
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(shop.shopName),
                  background: shop.imageUrl != null
                      ? Image.network(
                          shop.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.store,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _shareStore,
                  ),
                ],
              ),

              // Shop Info
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(shop.contact),
                        ],
                      ),
                      const Divider(height: AppSpacing.xl),
                      Text(
                        'Products',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),

              // Products Grid
              if (productProvider.products.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('No products available'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = productProvider.products[index];
                        return _buildProductCard(product);
                      },
                      childCount: productProvider.products.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => context.go('/home/product/${product.productId}'),
      child: Container(
        decoration: AppDecorations.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.md),
                  ),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.md),
                        ),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        size: 50,
                        color: AppTheme.textSecondaryColor,
                      ),
              ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (product.inStock)
                    const Text(
                      'In Stock',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
                      ),
                    )
                  else
                    const Text(
                      'Out of Stock',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
