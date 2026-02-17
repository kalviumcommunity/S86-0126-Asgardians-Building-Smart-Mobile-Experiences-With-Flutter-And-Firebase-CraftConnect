import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/firebase_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== IMAGE UPLOAD ====================

  /// Upload shop image
  Future<String> uploadShopImage(File imageFile, String shopId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path =
          '${FirebaseStoragePaths.shopImages}/$shopId/$fileName';

      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload shop image: $e';
    }
  }

  /// Upload product image
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path =
          '${FirebaseStoragePaths.productImages}/$productId/$fileName';

      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload product image: $e';
    }
  }

  /// Upload user profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path =
          '${FirebaseStoragePaths.userProfiles}/$userId/$fileName';

      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload profile image: $e';
    }
  }

  /// Generic image upload with progress
  Future<String> uploadImageWithProgress({
    required File imageFile,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  // ==================== WEB UPLOAD (for Flutter Web) ====================

  /// Upload image from bytes (for web)
  Future<String> uploadImageFromBytes({
    required Uint8List bytes,
    required String path,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image from bytes: $e';
    }
  }

  // ==================== DELETE OPERATIONS ====================

  /// Delete image by URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete image: $e';
    }
  }

  /// Delete all images in a folder
  Future<void> deleteFolder(String folderPath) async {
    try {
      final Reference ref = _storage.ref().child(folderPath);
      final ListResult result = await ref.listAll();

      // Delete all files in the folder
      for (Reference fileRef in result.items) {
        await fileRef.delete();
      }

      // Recursively delete subfolders
      for (Reference folderRef in result.prefixes) {
        await deleteFolder(folderRef.fullPath);
      }
    } catch (e) {
      throw 'Failed to delete folder: $e';
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get download URL from path
  Future<String> getDownloadUrl(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to get download URL: $e';
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } catch (e) {
      throw 'Failed to get file metadata: $e';
    }
  }

  /// List all files in a folder
  Future<List<String>> listFiles(String folderPath) async {
    try {
      final Reference ref = _storage.ref().child(folderPath);
      final ListResult result = await ref.listAll();

      List<String> urls = [];
      for (Reference fileRef in result.items) {
        final String url = await fileRef.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw 'Failed to list files: $e';
    }
  }
}

// Helper class for upload progress
class UploadProgress {
  final double progress;
  final int bytesTransferred;
  final int totalBytes;

  UploadProgress({
    required this.progress,
    required this.bytesTransferred,
    required this.totalBytes,
  });

  bool get isComplete => progress >= 1.0;
  int get percentComplete => (progress * 100).round();
}
