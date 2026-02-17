import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recently_viewed_provider.dart';
import '../../models/review_model.dart';
import '../../models/product_variant_model.dart';
import '../../widgets/bulk_pricing_widget.dart';
import '../../widgets/zoomable_image_viewer.dart';
import '../../services/analytics_service.dart';
import '../../services/firestore_service.dart';
import 'package:craftconnect/config/app_constants.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  const ProductPage({super.key, required this.productId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _quantity = 1;
  ProductVariantModel? _selectedVariant;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
      _loadReviews();
    });
  }

  Future<void> _loadProduct() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final recentlyViewedProvider =
        Provider.of<RecentlyViewedProvider>(context, listen: false);
    final product = await productProvider.getProductById(widget.productId);

    if (product != null && mounted) {
      // Add to recently viewed
      await recentlyViewedProvider.addProduct(product);

      // Track product view in analytics and Firestore
      await AnalyticsService().logProductView(
        productId: product.productId,
        productName: product.name,
        category: product.category,
        price: product.price,
      );

      // Increment view count in Firestore for trending algorithm
      await FirestoreService().incrementProductViewCount(product.productId);

      if (!mounted) return;

      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      await shopProvider
          .getShopBySlug(product.shopId); // Using shopId as fallback
    }
  }

  Future<void> _loadReviews() async {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    await reviewProvider.loadReviewsForProduct(widget.productId);
  }

  void _buyNow() {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final product = productProvider.currentProduct;

    if (product != null) {
      context.go(
        '/cart/checkout?productId=${product.productId}&shopId=${product.shopId}&artisanId=${product.artisanId}&quantity=$_quantity',
      );
    }
  }

  void _addToCart() {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final product = productProvider.currentProduct;

    if (product != null) {
      for (int i = 0; i < _quantity; i++) {
        cartProvider.addItem(
          productId: product.productId,
          productName: product.name,
          imageUrl: product.imageUrl ?? '',
          price: product.price,
          artisanId: product.artisanId,
          shopId: product.shopId,
        );
      }

      // Track add to cart in analytics
      AnalyticsService().logAddToCart(
        productId: product.productId,
        productName: product.name,
        price: product.price,
        quantity: _quantity,
        category: product.category,
      );

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('$_quantity ${product.name} added to cart'),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () {
              // Navigate to cart tab (index 2)
              StatefulNavigationShell.of(context).goBranch(2);
            },
          ),
        ),
      );
    }
  }

  void _shareProduct() {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final product = productProvider.currentProduct;

    if (product != null) {
      final shareText = '''
Check out this amazing product from CraftConnect!

${product.name}
₹${product.price.toStringAsFixed(0)}

${product.description}

Available at CraftConnect - Supporting local artisans.
''';

      Share.share(
        shareText,
        subject: 'Check out ${product.name} on CraftConnect',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = productProvider.currentProduct;
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          return CustomScrollView(
            slivers: [
              // Product Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                actions: [
                  IconButton(
                    onPressed: _shareProduct,
                    icon: const Icon(Icons.share),
                    tooltip: 'Share Product',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: product.imageUrl != null
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ZoomableImageViewer(
                                  imageUrl: product.imageUrl!,
                                  heroTag: 'product_${product.productId}',
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'product_${product.productId}',
                            child: Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.backgroundColor,
                          child: const Icon(
                            Icons.image,
                            size: 100,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                ),
              ),

              // Product Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Price
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _selectedVariant != null
                            ? '₹${_selectedVariant!.getFinalPrice(product.price).toStringAsFixed(0)}'
                            : '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),

                      // Product Variants
                      if (product.hasVariants &&
                          product.variants.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildVariantSelection(product),
                      ],

                      const SizedBox(height: AppSpacing.md),

                      // Stock Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStockStatus(product).inStock
                              ? AppTheme.successColor.withValues(alpha: 0.1)
                              : AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: _getStockStatus(product).inStock
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                        child: Text(
                          _getStockStatus(product).message,
                          style: TextStyle(
                            color: _getStockStatus(product).inStock
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Divider(height: AppSpacing.xl),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Artisan/Seller Section
                      Consumer<ShopProvider>(
                        builder: (context, shopProvider, _) {
                          final shop = shopProvider.currentShop;
                          if (shop != null) {
                            return Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sold by',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      // Artisan profile picture
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.1),
                                          image: shop.imageUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      shop.imageUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: shop.imageUrl == null
                                            ? const Icon(
                                                Icons.store,
                                                color: AppTheme.primaryColor,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              shop.shopName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            if (shop.isApproved)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.verified,
                                                    size: 16,
                                                    color: Colors.green[700],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Verified Artisan',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          context.push(
                                              '/artisan/${product.shopId}');
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: const Text('View Profile'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Quantity Selector
                      if (product.inStock) ...[
                        Text(
                          'Quantity',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              iconSize: 32,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: AppTheme.primaryColor),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _quantity < product.stock
                                  ? () => setState(() => _quantity++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              iconSize: 32,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Bulk Pricing Info
                        if (product.hasBulkPricing) ...[
                          BulkPricingWidget(
                            product: product,
                            currentQuantity: _quantity,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Total Price
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (product.hasBulkPricing &&
                                      product.getBulkPricingForQuantity(
                                              _quantity) !=
                                          null)
                                    Text(
                                      '\u20b9${(product.price * _quantity).toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  Text(
                                    '\u20b9${product.getTotalPriceForQuantity(_quantity).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.lg),

                      // Reviews Section
                      Consumer2<ReviewProvider, AuthProvider>(
                        builder: (context, reviewProvider, authProvider, _) {
                          final reviews = reviewProvider
                              .getReviewsForProduct(product.productId);
                          final avgRating = reviewProvider
                              .getAverageRating(product.productId);
                          final reviewCount = reviews.length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ratings & Reviews',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (reviewCount > 0)
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.orange, size: 20),
                                            Text(
                                              ' ${avgRating.toStringAsFixed(1)} ($reviewCount reviews)',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _showAddReviewDialog(
                                      context,
                                      reviewProvider,
                                      authProvider,
                                      product.productId,
                                    ),
                                    icon:
                                        const Icon(Icons.rate_review, size: 18),
                                    label: const Text('Write Review'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (reviews.isEmpty)
                                Center(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.lg),
                                    child: Text(
                                      'No reviews yet. Be the first to review!',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                )
                              else
                                ...reviews.take(3).map((review) =>
                                    _buildReviewCard(review, authProvider)),
                              if (reviews.length > 3)
                                TextButton(
                                  onPressed: () {
                                    // Show all reviews dialog
                                  },
                                  child: const Text('View all reviews'),
                                ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer2<ProductProvider, CartProvider>(
        builder: (context, productProvider, cartProvider, child) {
          final product = productProvider.currentProduct;
          if (product == null || !product.inStock) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Share Button
                  IconButton(
                    onPressed: _shareProduct,
                    icon: const Icon(Icons.share),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.all(12),
                    ),
                    tooltip: 'Share Product',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Add to Cart Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Add to Cart'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Buy Now Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _buyNow,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review, AuthProvider authProvider) {
    final isOwnReview = authProvider.currentUser?.uid == review.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      child: Text(review.userName[0].toUpperCase()),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: Colors.orange,
                              );
                            }),
                            const SizedBox(width: AppSpacing.xs),
                            if (review.isVerifiedPurchase)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Verified',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (isOwnReview)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Review'),
                          content: const Text(
                              'Are you sure you want to delete your review?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        final reviewProvider =
                            Provider.of<ReviewProvider>(context, listen: false);
                        await reviewProvider.deleteReview(
                            review.id, review.productId);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(review.comment),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog(
    BuildContext context,
    ReviewProvider reviewProvider,
    AuthProvider authProvider,
    String productId,
  ) {
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to write a review')),
      );
      return;
    }

    double rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Write a Review'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rating'),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = (index + 1).toDouble();
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Your Review',
                      border: OutlineInputBorder(),
                      hintText: 'Share your experience with this product',
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (commentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please write a review')),
                    );
                    return;
                  }

                  final success = await reviewProvider.addReview(
                    productId: productId,
                    userId: authProvider.currentUser!.uid,
                    userName: authProvider.currentUser!.name,
                    rating: rating,
                    comment: commentController.text.trim(),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Review added successfully'
                              : 'Failed to add review',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVariantSelection(product) {
    if (!product.hasVariants || product.variants.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group variants by attributes (e.g., by color, size, etc.)
    Map<String, Set<String>> attributeOptions = {};
    for (var variant in product.variants) {
      variant.attributes.forEach((key, value) {
        if (!attributeOptions.containsKey(key)) {
          attributeOptions[key] = <String>{};
        }
        attributeOptions[key]!.add(value);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attributeOptions.entries.map((entry) {
        final attributeName = entry.key;
        final options = entry.value.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attributeName.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: options.map((option) {
                final isSelected =
                    _selectedVariant?.attributes[attributeName] == option;
                final availableVariants = product.variants
                    .where(
                      (v) =>
                          v.attributes[attributeName] == option &&
                          v.isAvailable &&
                          v.stock > 0,
                    )
                    .toList();
                final isAvailable = availableVariants.isNotEmpty;

                return GestureDetector(
                  onTap: isAvailable
                      ? () =>
                          _selectVariantOption(product, attributeName, option)
                      : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : isAvailable
                              ? Colors.transparent
                              : Colors.grey[200],
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : isAvailable
                                ? Colors.grey[400]!
                                : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isAvailable
                                ? AppTheme.textPrimaryColor
                                : Colors.grey[500],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      }).toList(),
    );
  }

  void _selectVariantOption(product, String attributeName, String option) {
    setState(() {
      // Find a variant that matches the selected option and current selections
      Map<String, String> newAttributes = {};
      if (_selectedVariant != null) {
        newAttributes = Map.from(_selectedVariant!.attributes);
      }
      newAttributes[attributeName] = option;

      // Find matching variant
      _selectedVariant = product.variants.firstWhere(
        (v) {
          return v.attributes.entries.every(
                (entry) => newAttributes[entry.key] == entry.value,
              ) ||
              (v.attributes[attributeName] == option);
        },
        orElse: () {
          // If no exact match, find any variant with this attribute
          return product.variants.firstWhere(
            (v) => v.attributes[attributeName] == option,
            orElse: () => product.variants.first,
          );
        },
      );
    });
  }

  ({bool inStock, String message}) _getStockStatus(product) {
    if (_selectedVariant != null) {
      return (
        inStock: _selectedVariant!.inStock,
        message: _selectedVariant!.inStock
            ? 'In Stock (${_selectedVariant!.stock})'
            : 'Out of Stock'
      );
    }

    if (product.hasVariants) {
      final availableVariants =
          product.variants.where((v) => v.inStock).toList();
      if (availableVariants.isEmpty) {
        return (inStock: false, message: 'Out of Stock');
      }
      final totalStock = availableVariants.fold(0, (sum, v) => sum + v.stock);
      return (inStock: true, message: 'In Stock ($totalStock)');
    }

    return (
      inStock: product.inStock,
      message: product.inStock ? 'In Stock (${product.stock})' : 'Out of Stock'
    );
  }
}
