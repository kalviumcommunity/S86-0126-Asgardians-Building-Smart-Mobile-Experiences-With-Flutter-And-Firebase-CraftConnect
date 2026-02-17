import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../providers/review_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/review_model.dart';

class ReviewModerationScreen extends StatefulWidget {
  const ReviewModerationScreen({super.key});

  @override
  State<ReviewModerationScreen> createState() => _ReviewModerationScreenState();
}

class _ReviewModerationScreenState extends State<ReviewModerationScreen> {
  String _filterRating = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    await Future.wait([
      reviewProvider.loadAllReviews(),
      productProvider.getAllProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Moderation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer2<ReviewProvider, ProductProvider>(
        builder: (context, reviewProvider, productProvider, child) {
          if (reviewProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          var reviews = reviewProvider.allReviews;

          // Apply rating filter
          if (_filterRating != 'all') {
            final rating = int.parse(_filterRating);
            reviews = reviews.where((r) => r.rating.toInt() == rating).toList();
          }

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            reviews = reviews
                .where((r) =>
                    r.comment
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    r.userName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();
          }

          // Sort by date (newest first)
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return RefreshIndicator(
            onRefresh: _loadData,
            child: Column(
              children: [
                // Filters
                Container(
                  color: AppTheme.backgroundColor,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search reviews...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Rating Filter
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all'),
                            _buildFilterChip('5 Stars', '5'),
                            _buildFilterChip('4 Stars', '4'),
                            _buildFilterChip('3 Stars', '3'),
                            _buildFilterChip('2 Stars', '2'),
                            _buildFilterChip('1 Star', '1'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        'Total Reviews',
                        reviewProvider.allReviews.length.toString(),
                        Icons.rate_review,
                        AppTheme.primaryColor,
                      ),
                      _buildStat(
                        'Filtered',
                        reviews.length.toString(),
                        Icons.filter_list,
                        AppTheme.accentColor,
                      ),
                      _buildStat(
                        'Avg Rating',
                        _calculateAvgRating(reviewProvider.allReviews),
                        Icons.star,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),

                // Review List
                Expanded(
                  child: reviews.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No reviews found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: reviews.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            final product = productProvider.products
                                .where((p) => p.productId == review.productId)
                                .firstOrNull;

                            return _buildReviewCard(
                              review,
                              product?.name ?? 'Unknown Product',
                              product?.imageUrl,
                              productProvider,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterRating == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterRating = value;
          });
        },
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _calculateAvgRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return '0.0';
    final total = reviews.fold(0.0, (sum, r) => sum + r.rating);
    return (total / reviews.length).toStringAsFixed(1);
  }

  Widget _buildReviewCard(
    ReviewModel review,
    String productName,
    String? productImage,
    ProductProvider productProvider,
  ) {
    return Container(
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Info Header
          ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: productImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.network(
                      productImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: AppTheme.backgroundColor,
                          child: const Icon(Icons.image),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.inventory_2),
                  ),
            title: Text(
              productName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getRatingColor(review.rating).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: _getRatingColor(review.rating),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: _getRatingColor(review.rating),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    review.rating.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getRatingColor(review.rating),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Review Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      child: Text(
                        review.userName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (review.isVerifiedPurchase)
                            Row(
                              children: [
                                Icon(Icons.verified,
                                    size: 14, color: Colors.green[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified Purchase',
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
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  review.comment,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => context.go('/product/${review.productId}'),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View Product'),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () => _deleteReview(review),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.orange;
    return Colors.red;
  }

  Future<void> _deleteReview(ReviewModel review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: Text(
          'Are you sure you want to delete this review by ${review.userName}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final reviewProvider =
          Provider.of<ReviewProvider>(context, listen: false);
      final success =
          await reviewProvider.deleteReview(review.id, review.productId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Review deleted successfully'
                  : 'Failed to delete review',
            ),
            backgroundColor:
                success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );

        if (success) {
          await _loadData();
        }
      }
    }
  }
}
