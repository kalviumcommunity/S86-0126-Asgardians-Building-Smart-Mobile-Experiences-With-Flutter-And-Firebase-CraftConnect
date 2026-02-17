import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/app_constants.dart';
import '../models/product_filters.dart';

class ProductFiltersSheet extends StatefulWidget {
  final ProductFilters initialFilters;

  const ProductFiltersSheet({
    super.key,
    required this.initialFilters,
  });

  @override
  State<ProductFiltersSheet> createState() => _ProductFiltersSheetState();
}

class _ProductFiltersSheetState extends State<ProductFiltersSheet> {
  late ProductFilters _filters;
  late RangeValues _priceRange;

  final List<String> _availableCategories = [
    'Jewelry',
    'Home Decor',
    'Clothing',
    'Accessories',
    'Art',
    'Pottery',
    'Textiles',
    'Woodwork',
    'Other',
  ];

  final Map<String, String> _sortOptions = {
    'price_low': 'Price: Low to High',
    'price_high': 'Price: High to Low',
    'rating': 'Highest Rated',
    'newest': 'Newest First',
  };

  @override
  void initState() {
    super.initState();
    _filters = ProductFilters(
      minPrice: widget.initialFilters.minPrice,
      maxPrice: widget.initialFilters.maxPrice,
      minRating: widget.initialFilters.minRating,
      categories: List.from(widget.initialFilters.categories),
      inStockOnly: widget.initialFilters.inStockOnly,
      sortBy: widget.initialFilters.sortBy,
    );
    _priceRange = RangeValues(_filters.minPrice, _filters.maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filters.reset();
                      _priceRange = const RangeValues(0, 100000);
                    });
                  },
                  child: const Text('Reset All'),
                ),
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _filters),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By
                  _buildSectionTitle('Sort By'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: _sortOptions.entries.map((entry) {
                      final isSelected = _filters.sortBy == entry.key;
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _filters.sortBy = selected ? entry.key : null;
                          });
                        },
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Price Range
                  _buildSectionTitle(
                    'Price Range (₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()})',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    activeColor: AppTheme.primaryColor,
                    labels: RangeLabels(
                      '₹${_priceRange.start.toInt()}',
                      '₹${_priceRange.end.toInt()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                        _filters.minPrice = values.start;
                        _filters.maxPrice = values.end;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹0',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '₹1,00,000',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Minimum Rating
                  _buildSectionTitle('Minimum Rating'),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      final isSelected =
                          _filters.minRating == rating.toDouble();
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$rating'),
                              const SizedBox(width: 4),
                              const Icon(Icons.star,
                                  size: 16, color: Colors.orange),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _filters.minRating =
                                  selected ? rating.toDouble() : null;
                            });
                          },
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Categories
                  _buildSectionTitle('Categories'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _availableCategories.map((category) {
                      final isSelected = _filters.categories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _filters.categories.add(category);
                            } else {
                              _filters.categories.remove(category);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Availability
                  _buildSectionTitle('Availability'),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    title: const Text('In Stock Only'),
                    value: _filters.inStockOnly ?? false,
                    onChanged: (value) {
                      setState(() {
                        _filters.inStockOnly = value ? true : null;
                      });
                    },
                    activeThumbColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
              top: AppSpacing.md,
            ),
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _filters),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _filters.hasActiveFilters
                          ? 'Apply ${_filters.activeFilterCount} Filter${_filters.activeFilterCount > 1 ? 's' : ''}'
                          : 'Apply Filters',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
