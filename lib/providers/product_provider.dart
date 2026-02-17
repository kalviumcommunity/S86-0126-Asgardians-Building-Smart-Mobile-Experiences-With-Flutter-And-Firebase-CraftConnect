import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<ProductModel> _products = [];
  ProductModel? _currentProduct;
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination
  DocumentSnapshot? _lastDocument;
  bool _hasMoreProducts = true;
  bool _isLoadingMore = false;

  // Getters
  List<ProductModel> get products => _products;
  ProductModel? get currentProduct => _currentProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreProducts => _hasMoreProducts;
  bool get isLoadingMore => _isLoadingMore;

  // Add product
  Future<bool> addProduct({
    required String shopId,
    required String artisanId,
    required String name,
    required String description,
    required double price,
    required int stock,
    File? imageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      final productId = const Uuid().v4();

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadProductImage(
          imageFile,
          productId,
        );
      }

      // Create product model
      final product = ProductModel(
        productId: productId,
        shopId: shopId,
        artisanId: artisanId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        stock: stock,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.addProduct(product);

      _products.insert(0, product);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get products by shop
  Future<void> getProductsByShop(String shopId) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      _products = await _firestoreService.getProductsByShop(shopId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      final product = await _firestoreService.getProductById(productId);
      _currentProduct = product;
      _isLoading = false;
      notifyListeners();
      return product;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update product
  Future<bool> updateProduct({
    required ProductModel product,
    File? newImageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Upload new image if provided
      String? imageUrl = product.imageUrl;
      if (newImageFile != null) {
        // Delete old image if exists
        if (product.imageUrl != null) {
          await _storageService.deleteImage(product.imageUrl!);
        }
        // Upload new image
        imageUrl = await _storageService.uploadProductImage(
          newImageFile,
          product.productId,
        );
      }

      // Update product with new data
      final updatedProduct = product.copyWith(
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateProduct(updatedProduct);

      // Update in local list
      final index = _products.indexWhere(
        (p) => p.productId == product.productId,
      );
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Find product
      final product = _products.firstWhere(
        (p) => p.productId == productId,
        orElse: () => throw 'Product not found',
      );

      // Delete image if exists
      if (product.imageUrl != null) {
        await _storageService.deleteImage(product.imageUrl!);
      }

      // Delete from Firestore
      await _firestoreService.deleteProduct(productId);

      // Remove from local list
      _products.removeWhere((p) => p.productId == productId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update stock
  Future<bool> updateStock(String productId, int newStock) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateProductStock(productId, newStock);

      // Update in local list
      final index = _products.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(stock: newStock);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get all products (admin)
  Future<void> getAllProducts() async {
    _isLoading = true;
    _errorMessage = null;
    _lastDocument = null;
    _hasMoreProducts = true;
    notifyListeners();

    try {
      _products = await _firestoreService.getAllProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load products with pagination (initial load)
  Future<void> loadProducts({
    String? category,
    String? sortBy,
    int limit = 20,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _lastDocument = null;
    _hasMoreProducts = true;
    _products = [];
    notifyListeners();

    try {
      final result = await _firestoreService.getProductsPaginated(
        limit: limit,
        category: category,
        sortBy: sortBy,
      );

      _products = result;
      _hasMoreProducts = result.length >= limit;

      // Store last document for next page
      if (result.isNotEmpty && _hasMoreProducts) {
        // We need to get the last DocumentSnapshot, but we only have ProductModel
        // So we'll need to fetch it again to get the snapshot
        final query =
            await _getProductsQuery(category: category, sortBy: sortBy)
                .limit(limit)
                .get();
        if (query.docs.isNotEmpty) {
          _lastDocument = query.docs.last;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more products (next page)
  Future<void> loadMoreProducts({
    String? category,
    String? sortBy,
    int limit = 20,
  }) async {
    if (_isLoadingMore || !_hasMoreProducts) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final query = _getProductsQuery(category: category, sortBy: sortBy);

      Query finalQuery = query;
      if (_lastDocument != null) {
        finalQuery = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await finalQuery.limit(limit).get();

      final newProducts = querySnapshot.docs
          .map((doc) => ProductModel.fromDocument(doc))
          .toList();

      _products.addAll(newProducts);
      _hasMoreProducts = newProducts.length >= limit;

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }

      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Helper method to build query
  Query _getProductsQuery({String? category, String? sortBy}) {
    final firestore = FirebaseFirestore.instance;
    Query query = firestore.collection('products');

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    switch (sortBy) {
      case 'price_low':
        query = query.orderBy('price', descending: false);
        break;
      case 'price_high':
        query = query.orderBy('price', descending: true);
        break;
      case 'rating':
        query = query.orderBy('averageRating', descending: true);
        break;
      default:
        query = query.orderBy('createdAt', descending: true);
    }

    return query;
  }

  // Stream products by shop
  Stream<List<ProductModel>> streamProductsByShop(String shopId) {
    return _firestoreService.streamProductsByShop(shopId);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear data
  void clear() {
    _products = [];
    _currentProduct = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Get products by category
  Future<void> getProductsByCategory(String categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _firestoreService.getProductsByCategory(categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
