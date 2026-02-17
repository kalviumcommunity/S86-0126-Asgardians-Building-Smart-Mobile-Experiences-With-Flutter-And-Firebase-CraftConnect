import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../providers/product_provider.dart';
import '../../providers/search_history_provider.dart';
import '../../models/product_model.dart';
import '../../models/product_filters.dart';
import '../../utils/debouncer.dart';
import '../../widgets/product_filters_sheet.dart';
import '../../widgets/product_card.dart';
import '../../services/analytics_service.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  bool _showSearchHistory = true;
  final _searchDebouncer = SearchDebouncer();
  ProductFilters _filters = ProductFilters();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchQuery = widget.initialQuery;
    _showSearchHistory = widget.initialQuery.isEmpty;
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    // Add to search history
    final searchHistoryProvider = context.read<SearchHistoryProvider>();
    await searchHistoryProvider.addSearch(query.trim());

    setState(() {
      _searchQuery = query;
      _showSearchHistory = false;
    });

    if (!mounted) return;

    // Track search in analytics (result count will be calculated later)
    final productProvider = context.read<ProductProvider>();
    final searchResults = _getSearchResults(productProvider.products);

    await AnalyticsService().logSearch(
      searchTerm: query.trim(),
      resultCount: searchResults.length,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadProducts(sortBy: _filters.sortBy);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadMoreProducts(sortBy: _filters.sortBy);
  }

  List<ProductModel> _getSearchResults(List<ProductModel> products) {
    var results = products;

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query);
      }).toList();
    }

    // Apply filters
    results = results.where((product) {
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
          results.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          results.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          results.sort((a, b) => b.averageRating.compareTo(a.averageRating));
          break;
        case 'newest':
          results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
    }

    return results;
  }

  Widget _buildRecentSearches() {
    return Consumer<SearchHistoryProvider>(
      builder: (context, searchHistoryProvider, child) {
        final recentSearches = searchHistoryProvider.recentSearches;

        if (recentSearches.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No recent searches',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Start searching to see your history here',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      searchHistoryProvider.clearAllSearches();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recentSearches.length,
                itemBuilder: (context, index) {
                  final search = recentSearches[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(search),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        searchHistoryProvider.removeSearch(search);
                      },
                    ),
                    onTap: () {
                      _searchController.text = search;
                      _performSearch(search);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (value) {
            // Update UI immediately for responsiveness
            setState(() {
              _showSearchHistory = value.isEmpty;
            });
            // Debounce the actual search
            _searchDebouncer(() {
              setState(() {
                _searchQuery = value;
              });
            });
          },
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _showSearchHistory = true;
                });
              },
            ),
          Badge(
            label: _filters.hasActiveFilters
                ? Text('${_filters.activeFilterCount}')
                : null,
            isLabelVisible: _filters.hasActiveFilters,
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFiltersSheet,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: _showSearchHistory
          ? _buildRecentSearches()
          : Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final searchResults =
                    _getSearchResults(productProvider.products);

                if (_searchQuery.isEmpty) {
                  return _buildRecentSearches();
                }

                if (searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: AppTheme.textSecondaryColor
                              .withAlpha(77), // 0.3 * 255
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No results found for "$_searchQuery"',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        '${searchResults.length} results found',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await _loadProducts();
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
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
                                    final product = searchResults[index];
                                    return _buildProductCard(product);
                                  },
                                  childCount: searchResults.length,
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
                                searchResults.isNotEmpty)
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
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Future<void> _showFiltersSheet() async {
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

  Widget _buildProductCard(ProductModel product) {
    return ProductGridCard(product: product);
  }
}
