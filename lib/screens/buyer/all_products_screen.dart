import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../models/product_filters.dart';
import '../../widgets/product_filters_sheet.dart';

class AllProductsScreen extends StatefulWidget {
  final String? categoryId;
  final String? title;

  const AllProductsScreen({
    super.key,
    this.categoryId,
    this.title,
  });

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  ProductFilters _filters = ProductFilters();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadProducts() async {
    final productProvider = context.read<ProductProvider>();
    if (widget.categoryId != null) {
      await productProvider.loadProducts(
        category: widget.categoryId,
        sortBy: _filters.sortBy,
      );
    } else {
      await productProvider.loadProducts(
        sortBy: _filters.sortBy,
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    final productProvider = context.read<ProductProvider>();
    if (widget.categoryId != null) {
      await productProvider.loadMoreProducts(
        category: widget.categoryId,
        sortBy: _filters.sortBy,
      );
    } else {
      await productProvider.loadMoreProducts(
        sortBy: _filters.sortBy,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'All Products'),
        actions: [
          Badge(
            label: _filters.hasActiveFilters
                ? Text('${_filters.activeFilterCount}')
                : null,
            isLabelVisible: _filters.hasActiveFilters,
            child: IconButton(
              onPressed: _showAdvancedFilters,
              icon: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter chips
          if (_filters.hasActiveFilters)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_filters.sortBy != null)
                    _buildFilterChip(
                      label: 'Sort: ${_filters.sortBy}',
                      onDeleted: () {
                        setState(() {
                          _filters.sortBy = null;
                        });
                      },
                    ),
                  if (_filters.minPrice > 0 || _filters.maxPrice < 100000)
                    _buildFilterChip(
                      label:
                          'Price: ₹${_filters.minPrice.toInt()} - ₹${_filters.maxPrice.toInt()}',
                      onDeleted: () {
                        setState(() {
                          _filters.minPrice = 0;
                          _filters.maxPrice = 100000;
                        });
                      },
                    ),
                  if (_filters.categories.isNotEmpty)
                    _buildFilterChip(
                      label: '${_filters.categories.length} categories',
                      onDeleted: () {
                        setState(() {
                          _filters.categories = [];
                        });
                      },
                    ),
                  if (_filters.minRating != null)
                    _buildFilterChip(
                      label: '${_filters.minRating}+ stars',
                      onDeleted: () {
                        setState(() {
                          _filters.minRating = null;
                        });
                      },
                    ),
                  if (_filters.inStockOnly == true)
                    _buildFilterChip(
                      label: 'In Stock',
                      onDeleted: () {
                        setState(() {
                          _filters.inStockOnly = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          // Products Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = _getFilteredProducts(productProvider.products);

                if (products.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = products[index];
                              return _buildProductCard(product);
                            },
                            childCount: products.length,
                          ),
                        ),
                      ),
                      // Loading indicator at bottom
                      if (productProvider.isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      // End of list indicator
                      if (!productProvider.hasMoreProducts &&
                          products.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No more products',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onDeleted: onDeleted,
        onSelected: (_) {},
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        deleteIcon: const Icon(Icons.close, size: 16),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.productId}'),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey[100],
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          product.images.first,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.price}',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber[700],
                          size: 16,
                        ),
                        Text(
                          product.averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        if (product.stock > 0)
                          Text(
                            '${product.stock} left',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          )
                        else
                          const Text(
                            'Out of stock',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<ProductModel> _getFilteredProducts(List<ProductModel> products) {
    var filtered = products;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final searchTerm = _searchQuery.toLowerCase();
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(searchTerm) ||
            product.description.toLowerCase().contains(searchTerm);
      }).toList();
    }

    // Apply comprehensive filters
    filtered = filtered.where((product) {
      // Price filter
      if (product.price < _filters.minPrice ||
          product.price > _filters.maxPrice) {
        return false;
      }

      // Rating filter
      if (_filters.minRating != null &&
          product.averageRating < _filters.minRating!) {
        return false;
      }

      // Category filter
      if (_filters.categories.isNotEmpty &&
          !_filters.categories.contains(product.category)) {
        return false;
      }

      // Stock filter
      if (_filters.inStockOnly == true && !product.inStock) {
        return false;
      }

      return true;
    }).toList();

    // Apply sorting
    if (_filters.sortBy != null) {
      switch (_filters.sortBy) {
        case 'price_low':
          filtered.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          filtered.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          filtered.sort((a, b) => b.averageRating.compareTo(a.averageRating));
          break;
        case 'newest':
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
    }

    return filtered;
  }

  Future<void> _showAdvancedFilters() async {
    final filters = await showModalBottomSheet<ProductFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFiltersSheet(initialFilters: _filters),
    );

    if (filters != null) {
      setState(() {
        _filters = filters;
      });
    }
  }
}
