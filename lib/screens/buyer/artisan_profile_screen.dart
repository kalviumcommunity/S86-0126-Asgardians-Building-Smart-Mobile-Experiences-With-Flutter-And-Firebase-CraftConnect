import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';

import '../../providers/shop_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/follow_provider.dart';
import '../../widgets/product_card.dart';

class ArtisanProfileScreen extends StatefulWidget {
  final String shopId;

  const ArtisanProfileScreen({super.key, required this.shopId});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen>
    with SingleTickerProviderStateMixin {
  ShopModel? _shop;
  List<ProductModel> _products = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadArtisanProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadArtisanProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      final followProvider =
          Provider.of<FollowProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Load shop details
      final shop = await shopProvider.getShopBySlug(widget.shopId);
      if (shop != null) {
        _shop = shop;

        // Load artisan's products
        await productProvider.loadProducts();
        _products = productProvider.products
            .where((product) => product.shopId == widget.shopId)
            .toList();

        // Load follower count
        await followProvider.loadFollowerCount(widget.shopId);

        // Load user's following status
        if (authProvider.currentUser != null) {
          await followProvider.loadFollowing(authProvider.currentUser!.uid);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
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

  Future<void> _toggleFollow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final followProvider = Provider.of<FollowProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to follow artisans')),
      );
      return;
    }

    if (_shop == null) return;

    final success = await followProvider.toggleFollow(
      authProvider.currentUser!.uid,
      widget.shopId,
    );

    if (success && mounted) {
      final isFollowing = followProvider.isFollowing(widget.shopId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFollowing
              ? 'Following ${_shop!.shopName}'
              : 'Unfollowed ${_shop!.shopName}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Artisan Profile'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_shop == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Artisan Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Artisan not found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover image
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.3),
                            AppTheme.primaryColor,
                          ],
                        ),
                      ),
                    ),
                    // Profile info
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Profile picture
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    image: _shop!.imageUrl != null
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(_shop!.imageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _shop!.imageUrl == null
                                      ? const Icon(
                                          Icons.store,
                                          size: 40,
                                          color: AppTheme.primaryColor,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                // Name and stats
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _shop!.shopName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _shop!.contact,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Consumer<FollowProvider>(
                builder: (context, followProvider, _) {
                  final isFollowing = followProvider.isFollowing(widget.shopId);

                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleFollow,
                          icon: Icon(isFollowing
                              ? Icons.check_circle
                              : Icons.person_add),
                          label: Text(isFollowing ? 'Following' : 'Follow'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: isFollowing
                                ? Colors.grey[300]
                                : AppTheme.primaryColor,
                            foregroundColor:
                                isFollowing ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Open messaging (if available)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Messaging coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Stats
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Consumer<FollowProvider>(
                builder: (context, followProvider, _) {
                  final followerCount =
                      followProvider.getFollowerCount(widget.shopId);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Products', _products.length.toString()),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      _buildStatColumn('Followers', followerCount.toString()),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      _buildStatColumn(
                        'Rating',
                        _calculateAverageRating().toStringAsFixed(1),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Products'),
                ],
              ),
            ),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAboutTab(),
                  _buildProductsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story section
          _buildSectionTitle('Our Story'),
          const SizedBox(height: 12),
          Text(
            _shop!.description.isNotEmpty
                ? _shop!.description
                : 'A talented artisan creating unique handcrafted products. Each piece is made with care and attention to detail, celebrating traditional craftsmanship.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Contact information
          _buildSectionTitle('Contact Information'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Location', _shop!.contact),
          if (_shop!.contactPhone.isNotEmpty)
            _buildInfoRow(Icons.phone, 'Phone', _shop!.contactPhone),
          if (_shop!.contactEmail.isNotEmpty)
            _buildInfoRow(Icons.email, 'Email', _shop!.contactEmail),
          const SizedBox(height: 24),

          // Specialization (categories from products)
          if (_getArtisanCategories().isNotEmpty) ...[
            _buildSectionTitle('Specialization'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getArtisanCategories()
                  .map(
                    (category) => Chip(
                      label: Text(category),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Member since
          _buildSectionTitle('Member Since'),
          const SizedBox(height: 12),
          Text(
            _formatDate(_shop!.createdAt),
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 24),

          // Shop Status
          if (_shop!.isApproved)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verified Artisan',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: _products[index]);
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getArtisanCategories() {
    final categories =
        _products.map((product) => product.category).toSet().toList();
    categories.sort();
    return categories;
  }

  double _calculateAverageRating() {
    if (_products.isEmpty) return 0.0;

    final totalRating = _products.fold<double>(
      0.0,
      (sum, product) => sum + product.averageRating,
    );

    return totalRating / _products.length;
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}
