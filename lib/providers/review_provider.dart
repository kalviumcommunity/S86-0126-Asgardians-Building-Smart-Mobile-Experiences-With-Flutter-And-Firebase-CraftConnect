import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';

class ReviewProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, List<ReviewModel>> _reviewsByProduct = {};
  List<ReviewModel> _allReviews = [];
  bool _isLoading = false;

  List<ReviewModel> getReviewsForProduct(String productId) {
    return _reviewsByProduct[productId] ?? [];
  }

  List<ReviewModel> get allReviews => _allReviews;

  double getAverageRating(String productId) {
    final reviews = getReviewsForProduct(productId);
    if (reviews.isEmpty) return 0.0;

    final sum = reviews.fold(0.0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  int getReviewCount(String productId) {
    return getReviewsForProduct(productId).length;
  }

  bool get isLoading => _isLoading;

  Future<void> loadReviewsForProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final reviews = await _firestoreService.getProductReviews(productId);
      _reviewsByProduct[productId] = reviews;
    } catch (e) {
      // Error loading reviews - set empty list
      _reviewsByProduct[productId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    bool isVerifiedPurchase = false,
  }) async {
    try {
      final review = ReviewModel(
        id: const Uuid().v4(),
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        isVerifiedPurchase: isVerifiedPurchase,
      );

      await _firestoreService.addReview(review);

      // Reload reviews for this product
      await loadReviewsForProduct(productId);
      return true;
    } catch (e) {
      // Error adding review
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId, String productId) async {
    try {
      await _firestoreService.deleteReview(reviewId);
      await loadReviewsForProduct(productId);
      return true;
    } catch (e) {
      // Error deleting review
      return false;
    }
  }

  Future<void> loadAllReviews() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allReviews = await _firestoreService.getAllReviews();
    } catch (e) {
      _allReviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
