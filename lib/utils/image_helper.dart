import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Result of image validation
class ImageValidationResult {
  final bool isValid;
  final String? errorMessage;
  final File? file;
  final double? fileSizeInMB;

  ImageValidationResult({
    required this.isValid,
    this.errorMessage,
    this.file,
    this.fileSizeInMB,
  });
}

/// Helper class for image picking and validation
class ImageHelper {
  static const double _maxFileSizeInMB = 5.0;
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  /// Pick and validate an image from gallery
  static Future<ImageValidationResult> pickImage({
    ImageSource source = ImageSource.gallery,
    double maxSizeInMB = _maxFileSizeInMB,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920, // Resize to max 1920px width
        maxHeight: 1920, // Resize to max 1920px height
        imageQuality: 85, // Compress to 85% quality
      );

      if (image == null) {
        return ImageValidationResult(
          isValid: false,
          errorMessage: 'No image selected',
        );
      }

      // Validate the picked image
      return await validateImage(File(image.path), maxSizeInMB: maxSizeInMB);
    } catch (e) {
      return ImageValidationResult(
        isValid: false,
        errorMessage: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  /// Pick multiple images from gallery
  static Future<List<ImageValidationResult>> pickMultipleImages({
    int maxImages = 5,
    double maxSizeInMB = _maxFileSizeInMB,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isEmpty) {
        return [
          ImageValidationResult(
            isValid: false,
            errorMessage: 'No images selected',
          )
        ];
      }

      // Limit number of images
      final limitedImages = images.take(maxImages).toList();

      // Validate all images
      final List<ImageValidationResult> results = [];
      for (final image in limitedImages) {
        final result = await validateImage(
          File(image.path),
          maxSizeInMB: maxSizeInMB,
        );
        results.add(result);
      }

      return results;
    } catch (e) {
      return [
        ImageValidationResult(
          isValid: false,
          errorMessage: 'Failed to pick images: ${e.toString()}',
        )
      ];
    }
  }

  /// Validate an image file
  static Future<ImageValidationResult> validateImage(
    File imageFile, {
    double maxSizeInMB = _maxFileSizeInMB,
  }) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        return ImageValidationResult(
          isValid: false,
          errorMessage: 'Image file does not exist',
        );
      }

      // Check file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(extension)) {
        return ImageValidationResult(
          isValid: false,
          errorMessage:
              'Invalid file type. Allowed: ${_allowedExtensions.join(", ")}',
        );
      }

      // Check file size
      final fileSizeInBytes = await imageFile.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > maxSizeInMB) {
        return ImageValidationResult(
          isValid: false,
          errorMessage:
              'Image size (${fileSizeInMB.toStringAsFixed(2)}MB) exceeds limit of ${maxSizeInMB}MB',
          fileSizeInMB: fileSizeInMB,
        );
      }

      // All validations passed
      return ImageValidationResult(
        isValid: true,
        file: imageFile,
        fileSizeInMB: fileSizeInMB,
      );
    } catch (e) {
      return ImageValidationResult(
        isValid: false,
        errorMessage: 'Failed to validate image: ${e.toString()}',
      );
    }
  }

  /// Show a snackbar with image validation error
  static void showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show a snackbar with success message
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Format file size for display
  static String formatFileSize(double sizeInMB) {
    if (sizeInMB < 1) {
      final sizeInKB = sizeInMB * 1024;
      return '${sizeInKB.toStringAsFixed(0)} KB';
    }
    return '${sizeInMB.toStringAsFixed(2)} MB';
  }
}
