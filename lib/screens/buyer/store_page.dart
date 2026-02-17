import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../providers/shop_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';

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

      // Load reviews for all products
      if (mounted) {
        final reviewProvider =
            Provider.of<ReviewProvider>(context, listen: false);
        for (var product in productProvider.products) {
          await reviewProvider.loadReviewsForProduct(product.productId);
        }
      }
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
      body: Consumer3<ShopProvider, ProductProvider, ReviewProvider>(
        builder:
            (context, shopProvider, productProvider, reviewProvider, child) {
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

          // Calculate overall shop rating from all products
          double totalRating = 0;
          int totalReviewCount = 0;
          for (var product in productProvider.products) {
            final reviews =
                reviewProvider.getReviewsForProduct(product.productId);
            totalReviewCount += reviews.length;
            for (var review in reviews) {
              totalRating += review.rating;
            }
          }
          final avgShopRating =
              totalReviewCount > 0 ? totalRating / totalReviewCount : 0.0;

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
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${avgShopRating.toStringAsFixed(1)} ($totalReviewCount reviews)',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
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

              // Reviews Section Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: AppSpacing.xl),
                      Text(
                        'Customer Reviews',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (totalReviewCount > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Text(
                              avgShopRating.toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStarRating(avgShopRating),
                                Text(
                                  'Based on $totalReviewCount reviews',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Reviews List
              if (totalReviewCount == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 60,
                            color: AppTheme.textSecondaryColor
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'No reviews yet',
                            style:
                                TextStyle(color: AppTheme.textSecondaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Collect all reviews from all products
                        final allReviews = <ReviewModel>[];
                        for (var product in productProvider.products) {
                          allReviews.addAll(reviewProvider
                              .getReviewsForProduct(product.productId));
                        }

                        // Sort by date (newest first)
                        allReviews
                            .sort((a, b) => b.createdAt.compareTo(a.createdAt));

                        if (index >= allReviews.length) return null;

                        return _buildReviewCard(allReviews[index]);
                      },
                      childCount: () {
                        final allReviews = <ReviewModel>[];
                        for (var product in productProvider.products) {
                          allReviews.addAll(reviewProvider
                              .getReviewsForProduct(product.productId));
                        }
                        return allReviews.length;
                      }(),
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

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : index < rating
                  ? Icons.star_half
                  : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 16,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (review.isVerifiedPurchase) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.successColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    _buildStarRating(review.rating),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} months ago';
    } else {
      return '${(diff.inDays / 365).floor()} years ago';
    }
  }
}
