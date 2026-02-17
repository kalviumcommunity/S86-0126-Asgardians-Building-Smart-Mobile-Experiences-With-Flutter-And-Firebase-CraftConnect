import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../config/firebase_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      // Create user account
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user model
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          role: role,
          createdAt: DateTime.now(),
        );

        // Save to Firestore with timeout
        try {
          await _firestore
              .collection(FirebaseCollections.users)
              .doc(credential.user!.uid)
              .set(userModel.toMap())
              .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw 'Firestore write timeout - check your internet connection and Firestore rules';
            },
          );
        } catch (firestoreError) {
          // Delete the auth user if Firestore fails
          await credential.user!.delete();
          throw 'Failed to save user data: $firestoreError';
        }

        // Update display name
        await credential.user!.updateDisplayName(name);

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during sign up: $e';
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await getUserData(credential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during sign in';
    }
  }

  // Sign in with phone number (returns verification ID)
  Future<String> signInWithPhone(String phoneNumber) async {
    try {
      String verificationId = '';

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw _handleAuthException(e);
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        timeout: const Duration(seconds: 60),
      );

      return verificationId;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during phone verification';
    }
  }

  // Verify OTP and complete phone sign in
  Future<UserModel?> verifyOTP({
    required String verificationId,
    required String smsCode,
    required String name,
    required UserRole role,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user already exists
        final existingUser = await getUserData(userCredential.user!.uid);

        if (existingUser != null) {
          return existingUser;
        }

        // Create new user
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          name: name,
          email: '',
          phone: userCredential.user!.phoneNumber ?? '',
          role: role,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(FirebaseCollections.users)
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during OTP verification';
    }
  }

  // Simple OTP verification without creating user profile
  Future<UserModel?> verifyOTPSimple({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user already exists
        final existingUser = await getUserData(userCredential.user!.uid);
        return existingUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during OTP verification';
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc =
          await _firestore.collection(FirebaseCollections.users).doc(uid).get();

      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user data';
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      throw 'Failed to update user data';
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      throw 'Failed to update user profile';
    }
  }

  // Update user language
  Future<void> updateLanguage(String uid, String language) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update({'language': language});
    } catch (e) {
      throw 'Failed to update language';
    }
  }

  // Update FCM token
  Future<void> updateFCMToken(String uid, String token) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update({'fcmToken': token});
    } catch (e) {
      throw 'Failed to update FCM token';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Update user profile photo
  Future<String?> updateUserPhoto(String uid, File imageFile) async {
    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Update user document in Firestore
        await _firestore
            .collection(FirebaseCollections.users)
            .doc(uid)
            .update({'profilePicture': downloadUrl});

        return downloadUrl;
      }

      return null;
    } catch (e) {
      throw 'Failed to update profile photo';
    }
  }
}
