class ProductFilters {
  double minPrice;
  double maxPrice;
  double? minRating;
  List<String> categories;
  bool? inStockOnly;
  String? sortBy; // 'price_low', 'price_high', 'rating', 'newest'

  ProductFilters({
    this.minPrice = 0,
    this.maxPrice = 100000,
    this.minRating,
    this.categories = const [],
    this.inStockOnly,
    this.sortBy,
  });

  ProductFilters copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<String>? categories,
    bool? inStockOnly,
    String? sortBy,
  }) {
    return ProductFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      categories: categories ?? this.categories,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return minPrice > 0 ||
        maxPrice < 100000 ||
        minRating != null ||
        categories.isNotEmpty ||
        inStockOnly != null ||
        sortBy != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (minPrice > 0 || maxPrice < 100000) count++;
    if (minRating != null) count++;
    if (categories.isNotEmpty) count++;
    if (inStockOnly == true) count++;
    if (sortBy != null) count++;
    return count;
  }

  void reset() {
    minPrice = 0;
    maxPrice = 100000;
    minRating = null;
    categories = [];
    inStockOnly = null;
    sortBy = null;
  }

  Map<String, dynamic> toMap() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRating': minRating,
      'categories': categories,
      'inStockOnly': inStockOnly,
      'sortBy': sortBy,
    };
  }

  factory ProductFilters.fromMap(Map<String, dynamic> map) {
    return ProductFilters(
      minPrice: map['minPrice']?.toDouble() ?? 0,
      maxPrice: map['maxPrice']?.toDouble() ?? 100000,
      minRating: map['minRating']?.toDouble(),
      categories: List<String>.from(map['categories'] ?? []),
      inStockOnly: map['inStockOnly'],
      sortBy: map['sortBy'],
    );
  }
}
