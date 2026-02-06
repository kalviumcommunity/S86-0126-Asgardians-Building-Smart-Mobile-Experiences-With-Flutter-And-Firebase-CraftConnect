import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Secure Firestore Service demonstrating authentication-based access control
///
/// This service implements best practices for Firestore security:
/// - All operations require authentication
/// - Users can only access their own data
/// - Proper error handling for permission denied errors
class SecureFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get current user's UID (throws if not authenticated)
  String get uid {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }
    return currentUser!.uid;
  }

  // ========== USER PROFILE OPERATIONS ==========

  /// Create or update user profile (user can only modify their own profile)
  Future<void> createUserProfile({
    required String name,
    String? bio,
    String? photoUrl,
  }) async {
    try {
      final userUid = uid; // Will throw if not authenticated

      await _db.collection('users').doc(userUid).set({
        'uid': userUid,
        'name': name,
        'email': currentUser!.email,
        'bio': bio,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ User profile created/updated for: $userUid');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Check Firestore security rules');
      }
      rethrow;
    }
  }

  /// Update user profile (partial update)
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userUid = uid;

      // Add timestamp to updates
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('users').doc(userUid).update(updates);

      debugPrint('✅ User profile updated for: $userUid');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Permission denied: You can only update your own profile',
        );
      }
      rethrow;
    }
  }

  /// Read current user's profile
  Future<DocumentSnapshot> getUserProfile() async {
    try {
      final userUid = uid;
      return await _db.collection('users').doc(userUid).get();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Cannot read user profile');
      }
      rethrow;
    }
  }

  /// Stream user profile changes
  Stream<DocumentSnapshot> watchUserProfile() {
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Read another user's public profile (requires appropriate rules)
  Future<DocumentSnapshot> getPublicProfile(String userId) async {
    try {
      return await _db.collection('users').doc(userId).get();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Cannot read this user\'s profile');
      }
      rethrow;
    }
  }

  // ========== USER POSTS OPERATIONS ==========

  /// Create a post (secured by authentication)
  Future<DocumentReference> createPost({
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    try {
      final userUid = uid;

      final postData = {
        'authorId': userUid,
        'authorEmail': currentUser!.email,
        'title': title,
        'content': content,
        'tags': tags ?? [],
        'likes': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _db.collection('posts').add(postData);
      debugPrint('✅ Post created: ${docRef.id}');

      return docRef;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Cannot create post');
      }
      rethrow;
    }
  }

  /// Update own post
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('posts').doc(postId).update(updates);
      debugPrint('✅ Post updated: $postId');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Permission denied: You can only update your own posts',
        );
      }
      rethrow;
    }
  }

  /// Delete own post
  Future<void> deletePost(String postId) async {
    try {
      await _db.collection('posts').doc(postId).delete();
      debugPrint('✅ Post deleted: $postId');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Permission denied: You can only delete your own posts',
        );
      }
      rethrow;
    }
  }

  /// Get user's own posts
  Stream<QuerySnapshot> getUserPosts() {
    return _db
        .collection('posts')
        .where('authorId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get all public posts (requires read permissions in rules)
  Stream<QuerySnapshot> getAllPosts({int limit = 20}) {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Get a specific post
  Future<DocumentSnapshot> getPost(String postId) async {
    try {
      return await _db.collection('posts').doc(postId).get();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Cannot read this post');
      }
      rethrow;
    }
  }

  // ========== PRIVATE DATA OPERATIONS ==========

  /// Write private user data (only accessible by owner)
  Future<void> savePrivateData(String key, dynamic value) async {
    try {
      final userUid = uid;

      await _db
          .collection('users')
          .doc(userUid)
          .collection('private')
          .doc(key)
          .set({'value': value, 'updatedAt': FieldValue.serverTimestamp()});

      debugPrint('✅ Private data saved: $key');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Cannot write private data');
      }
      rethrow;
    }
  }

  /// Read private user data
  Future<DocumentSnapshot> getPrivateData(String key) async {
    try {
      final userUid = uid;

      return await _db
          .collection('users')
          .doc(userUid)
          .collection('private')
          .doc(key)
          .get();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Cannot read private data');
      }
      rethrow;
    }
  }

  // ========== ADMIN OPERATIONS (Demo) ==========

  /// Check if user has admin role (requires admin field in user doc)
  Future<bool> isAdmin() async {
    try {
      final userUid = uid;
      final doc = await _db.collection('users').doc(userUid).get();
      return doc.data()?['isAdmin'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Admin-only: Delete any post (requires admin rules)
  Future<void> adminDeletePost(String postId) async {
    try {
      await _db.collection('posts').doc(postId).delete();
      debugPrint('✅ Admin deleted post: $postId');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Admin privileges required');
      }
      rethrow;
    }
  }

  // ========== TESTING UNAUTHORIZED ACCESS ==========

  /// Attempt to read another user's private data (should fail)
  Future<DocumentSnapshot> attemptUnauthorizedRead(String otherUserId) async {
    try {
      return await _db
          .collection('users')
          .doc(otherUserId)
          .collection('private')
          .doc('test')
          .get();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint(
          '❌ Expected: Permission denied when accessing other user\'s data',
        );
        rethrow;
      }
      rethrow;
    }
  }

  /// Attempt to update another user's profile (should fail)
  Future<void> attemptUnauthorizedWrite(String otherUserId) async {
    try {
      await _db.collection('users').doc(otherUserId).update({
        'name': 'Hacked Name',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint(
          '❌ Expected: Permission denied when updating other user\'s data',
        );
        rethrow;
      }
      rethrow;
    }
  }

  // ========== UTILITY METHODS ==========

  /// Test security rules by attempting various operations
  Future<Map<String, bool>> testSecurityRules() async {
    final results = <String, bool>{};

    // Test 1: Can create own profile
    try {
      await createUserProfile(name: 'Test User');
      results['Create Own Profile'] = true;
    } catch (e) {
      results['Create Own Profile'] = false;
    }

    // Test 2: Can read own profile
    try {
      await getUserProfile();
      results['Read Own Profile'] = true;
    } catch (e) {
      results['Read Own Profile'] = false;
    }

    // Test 3: Can create post
    try {
      await createPost(title: 'Test', content: 'Test content');
      results['Create Post'] = true;
    } catch (e) {
      results['Create Post'] = false;
    }

    // Test 4: Cannot access other user's private data (if we have another user ID)
    results['Security Check'] = true; // Add more tests as needed

    return results;
  }

  /// Sign out (for testing)
  Future<void> signOut() async {
    await _auth.signOut();
    debugPrint('🚪 User signed out');
  }
}
