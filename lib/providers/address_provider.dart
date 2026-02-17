import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/firestore_service.dart';

class AddressProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<AddressModel> _addresses = [];
  bool _isLoading = false;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Future<void> loadAddresses(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _addresses = await _firestoreService.getUserAddresses(userId);
    } catch (e) {
      // Error loading addresses - set empty list
      _addresses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    try {
      // If this is the first address or marked as default, unset other defaults
      if (address.isDefault || _addresses.isEmpty) {
        for (var addr in _addresses) {
          if (addr.isDefault) {
            await _firestoreService.updateAddress(
              addr.copyWith(isDefault: false),
            );
          }
        }
      }

      await _firestoreService.addAddress(address);
      await loadAddresses(address.userId);
      return true;
    } catch (e) {
      // Error adding address
      return false;
    }
  }

  Future<bool> updateAddress(AddressModel address) async {
    try {
      // If setting as default, unset other defaults
      if (address.isDefault) {
        for (var addr in _addresses) {
          if (addr.id != address.id && addr.isDefault) {
            await _firestoreService.updateAddress(
              addr.copyWith(isDefault: false),
            );
          }
        }
      }

      await _firestoreService.updateAddress(address);
      await loadAddresses(address.userId);
      return true;
    } catch (e) {
      // Error updating address
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId, String userId) async {
    try {
      await _firestoreService.deleteAddress(addressId);
      await loadAddresses(userId);
      return true;
    } catch (e) {
      // Error deleting address
      return false;
    }
  }

  Future<bool> setDefaultAddress(String addressId, String userId) async {
    try {
      // Unset all defaults first
      for (var addr in _addresses) {
        if (addr.isDefault) {
          await _firestoreService.updateAddress(
            addr.copyWith(isDefault: false),
          );
        }
      }

      // Set new default
      final address = _addresses.firstWhere((addr) => addr.id == addressId);
      await _firestoreService.updateAddress(
        address.copyWith(isDefault: true),
      );

      await loadAddresses(userId);
      return true;
    } catch (e) {
      // Error setting default address
      return false;
    }
  }
}
