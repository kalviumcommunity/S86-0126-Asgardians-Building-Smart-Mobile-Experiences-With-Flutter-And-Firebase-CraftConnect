import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/shop_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'dart:io';

class ShopProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  ShopModel? _currentShop;
  List<ShopModel> _shops = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ShopModel? get currentShop => _currentShop;
  List<ShopModel> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create a new shop
  Future<bool> createShop({
    required String ownerId,
    required String shopName,
    required String description,
    required String contact,
    File? imageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      // Generate unique shop ID and slug
      final shopId = const Uuid().v4();
      final slug = ShopModel.generateSlug(shopName);

      // Check if slug is available
      final isAvailable = await _firestoreService.isSlugAvailable(slug);
      if (!isAvailable) {
        throw 'Shop name already taken. Please choose a different name.';
      }

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadShopImage(imageFile, shopId);
      }

      // Create shop model
      final shop = ShopModel(
        shopId: shopId,
        ownerId: ownerId,
        shopName: shopName,
        slug: slug,
        description: description,
        contact: contact,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.createShop(shop);

      _currentShop = shop;
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

  // Get shop by slug
  Future<ShopModel?> getShopBySlug(String slug) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      final shop = await _firestoreService.getShopBySlug(slug);
      _currentShop = shop;
      _isLoading = false;
      notifyListeners();
      return shop;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Get shops by owner
  Future<void> getShopsByOwner(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      _shops = await _firestoreService.getShopsByOwner(ownerId);
      if (_shops.isNotEmpty) {
        _currentShop = _shops.first;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get shop by ID
  Future<ShopModel?> getShopById(String shopId) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      final shop = await _firestoreService.getShopById(shopId);
      _isLoading = false;
      notifyListeners();
      return shop;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update shop
  Future<bool> updateShop({
    required ShopModel shop,
    File? newImageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Upload new image if provided
      String? imageUrl = shop.imageUrl;
      if (newImageFile != null) {
        // Delete old image if exists
        if (shop.imageUrl != null) {
          await _storageService.deleteImage(shop.imageUrl!);
        }
        // Upload new image
        imageUrl = await _storageService.uploadShopImage(
          newImageFile,
          shop.shopId,
        );
      }

      // Update shop with new data
      final updatedShop = shop.copyWith(
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateShop(updatedShop);

      _currentShop = updatedShop;
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

  // Delete shop
  Future<bool> deleteShop(String shopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete shop image if exists
      if (_currentShop?.imageUrl != null) {
        await _storageService.deleteImage(_currentShop!.imageUrl!);
      }

      // Delete shop from Firestore
      await _firestoreService.deleteShop(shopId);

      _currentShop = null;
      _shops.removeWhere((shop) => shop.shopId == shopId);
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

  // Get all shops (admin)
  Future<void> getAllShops() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _shops = await _firestoreService.getAllShops();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set current shop
  void setCurrentShop(ShopModel shop) {
    _currentShop = shop;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear data
  void clear() {
    _currentShop = null;
    _shops = [];
    _errorMessage = null;
    notifyListeners();
  }
}
