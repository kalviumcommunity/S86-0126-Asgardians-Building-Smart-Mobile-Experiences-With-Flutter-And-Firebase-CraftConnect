import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  Locale _currentLocale = const Locale('en');

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  Locale get currentLocale => _currentLocale;

  // Check auth status on app start
  Future<void> checkAuthStatus() async {
    // Wait for the first event from authStateChanges to ensure Firebase has initialized its state
    // We use a timeout to avoid hanging if Firebase is not responding
    try {
      final user = await _authService.authStateChanges.first.timeout(
        const Duration(seconds: 2),
      );

      if (user != null) {
        _currentUser = await _authService.getUserData(user.uid);
        if (_currentUser != null) {
          _currentLocale = Locale(_currentUser!.language);
        }
      } else {
        // Fallback for some platforms where authStateChanges.first might be null initially
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          _currentUser = await _authService.getUserData(currentUser.uid);
          if (_currentUser != null) {
            _currentLocale = Locale(_currentUser!.language);
          }
        }
      }
    } catch (_) {
      // Timeout or other error, fallback to immediate check
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        _currentUser = await _authService.getUserData(currentUser.uid);
        if (_currentUser != null) {
          _currentLocale = Locale(_currentUser!.language);
        }
      }
    }
    notifyListeners();
  }

  // Sign up with email
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (_currentUser != null) {
        _currentLocale = Locale(_currentUser!.language);
      }

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with phone (step 1: send OTP)
  Future<String?> signInWithPhone(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final verificationId = await _authService.signInWithPhone(phoneNumber);
      _isLoading = false;
      notifyListeners();
      return verificationId;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Verify OTP (step 2: complete phone sign in)
  Future<bool> verifyOTP(String verificationId, String smsCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.verifyOTPSimple(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      if (_currentUser != null) {
        // Set default language if not set
        if (_currentUser!.language.isEmpty) {
          _currentLocale = const Locale('en');
        } else {
          _currentLocale = Locale(_currentUser!.language);
        }
      }

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Legacy verifyOTP method with user details
  Future<bool> verifyOTPWithDetails({
    required String verificationId,
    required String smsCode,
    required String name,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.verifyOTP(
        verificationId: verificationId,
        smsCode: smsCode,
        name: name,
        role: role,
      );

      if (_currentUser != null) {
        _currentLocale = Locale(_currentUser!.language);
      }

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update language
  Future<void> updateLanguage(String languageCode) async {
    if (_currentUser == null) return;

    try {
      await _authService.updateLanguage(_currentUser!.uid, languageCode);
      _currentLocale = Locale(languageCode);
      _currentUser = _currentUser!.copyWith(language: languageCode);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Change language (alias for updateLanguage for compatibility)
  Future<void> changeLanguage(Locale locale) async {
    await updateLanguage(locale.languageCode);
  }

  // Alias for changeLanguage for different naming conventions
  Future<void> changeLocale(Locale locale) async {
    await changeLanguage(locale);
  }

  // Alias for signOut for different naming conventions
  Future<void> logout() async {
    await signOut();
  }

  // Update FCM token
  Future<void> updateFCMToken(String token) async {
    if (_currentUser == null) return;

    try {
      await _authService.updateFCMToken(_currentUser!.uid, token);
      _currentUser = _currentUser!.copyWith(fcmToken: token);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _currentLocale = const Locale('en');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
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

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw 'No user logged in';
      }

      final updatedUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
      );

      await _authService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;

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

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update profile photo
  Future<bool> updateProfilePhoto(File imageFile) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final photoUrl =
          await _authService.updateUserPhoto(_currentUser!.uid, imageFile);

      if (photoUrl != null) {
        _currentUser = _currentUser!.copyWith(profilePicture: photoUrl);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Failed to upload photo';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
