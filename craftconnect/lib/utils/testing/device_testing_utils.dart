import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for gathering device information and testing capabilities
class DeviceTestingUtils {
  static const platform = MethodChannel('device_testing/platform');

  /// Get comprehensive device information
  static DeviceInfo getDeviceInfo(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    return DeviceInfo(
      // Screen information
      screenWidth: mediaQuery.size.width,
      screenHeight: mediaQuery.size.height,
      devicePixelRatio: mediaQuery.devicePixelRatio,
      orientation: mediaQuery.orientation,

      // Platform information
      platform: Platform.operatingSystem,
      isAndroid: Platform.isAndroid,
      isIOS: Platform.isIOS,

      // Theme information
      brightness: theme.brightness,
      isDarkMode: theme.brightness == Brightness.dark,

      // Additional metrics
      statusBarHeight: mediaQuery.padding.top,
      bottomPadding: mediaQuery.padding.bottom,
      safeAreaTop: mediaQuery.viewPadding.top,
      safeAreaBottom: mediaQuery.viewPadding.bottom,

      // Screen size category
      screenSizeCategory: _getScreenSizeCategory(mediaQuery.size.width),
      densityCategory: _getDensityCategory(mediaQuery.devicePixelRatio),
    );
  }

  /// Categorize screen size
  static ScreenSizeCategory _getScreenSizeCategory(double width) {
    if (width < 600) return ScreenSizeCategory.compact;
    if (width < 840) return ScreenSizeCategory.medium;
    return ScreenSizeCategory.expanded;
  }

  /// Categorize screen density
  static DensityCategory _getDensityCategory(double ratio) {
    if (ratio <= 1.0) return DensityCategory.ldpi;
    if (ratio <= 1.5) return DensityCategory.mdpi;
    if (ratio <= 2.0) return DensityCategory.hdpi;
    if (ratio <= 3.0) return DensityCategory.xhdpi;
    if (ratio <= 4.0) return DensityCategory.xxhdpi;
    return DensityCategory.xxxhdpi;
  }

  /// Test device capabilities
  static Future<DeviceCapabilities> testDeviceCapabilities() async {
    try {
      // Test various device capabilities
      final hasCamera = await _testCameraAccess();
      final hasLocation = await _testLocationAccess();
      final hasNotifications = await _testNotificationAccess();
      final hasInternet = await _testInternetConnection();
      final isEmulator = await _checkIfEmulator();

      return DeviceCapabilities(
        hasCamera: hasCamera,
        hasLocation: hasLocation,
        hasNotifications: hasNotifications,
        hasInternet: hasInternet,
        isEmulator: isEmulator,
        canVibrate: Platform.isAndroid || Platform.isIOS,
      );
    } catch (e) {
      return DeviceCapabilities.defaultCapabilities();
    }
  }

  /// Test camera access
  static Future<bool> _testCameraAccess() async {
    try {
      // This is a placeholder - in real implementation you'd use camera plugin
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Test location access
  static Future<bool> _testLocationAccess() async {
    try {
      // This is a placeholder - in real implementation you'd use location plugin
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Test notification access
  static Future<bool> _testNotificationAccess() async {
    try {
      // This is a placeholder - in real implementation you'd use notification plugin
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Test internet connection
  static Future<bool> _testInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if running on emulator
  static Future<bool> _checkIfEmulator() async {
    try {
      if (Platform.isAndroid) {
        // Check for common emulator indicators
        return Platform.environment.containsKey('ANDROID_ROOT');
      } else if (Platform.isIOS) {
        // iOS simulator detection
        return Platform.environment['SIMULATOR_DEVICE_NAME'] != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get performance metrics
  static DevicePerformance getPerformanceMetrics() {
    return DevicePerformance(
      timestamp: DateTime.now(),
      // These would be more sophisticated in a real implementation
      memoryUsage: _getMemoryUsage(),
      cpuUsage: _getCpuUsage(),
      frameRate: 60.0, // Placeholder
    );
  }

  static double _getMemoryUsage() {
    // Placeholder - would use platform-specific memory APIs
    return 0.0;
  }

  static double _getCpuUsage() {
    // Placeholder - would use platform-specific CPU APIs
    return 0.0;
  }

  /// Test network connectivity
  static Future<NetworkTestResult> testNetworkConnectivity() async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      stopwatch.stop();

      return NetworkTestResult(
        isConnected: result.isNotEmpty,
        latency: stopwatch.elapsedMilliseconds,
        error: null,
      );
    } catch (e) {
      stopwatch.stop();
      return NetworkTestResult(
        isConnected: false,
        latency: stopwatch.elapsedMilliseconds,
        error: e.toString(),
      );
    }
  }

  /// Get device orientation details
  static OrientationInfo getOrientationInfo(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return OrientationInfo(
      orientation: mediaQuery.orientation,
      isPortrait: mediaQuery.orientation == Orientation.portrait,
      isLandscape: mediaQuery.orientation == Orientation.landscape,
      aspectRatio: mediaQuery.size.width / mediaQuery.size.height,
    );
  }
}

/// Device information data class
class DeviceInfo {
  final double screenWidth;
  final double screenHeight;
  final double devicePixelRatio;
  final Orientation orientation;
  final String platform;
  final bool isAndroid;
  final bool isIOS;
  final Brightness brightness;
  final bool isDarkMode;
  final double statusBarHeight;
  final double bottomPadding;
  final double safeAreaTop;
  final double safeAreaBottom;
  final ScreenSizeCategory screenSizeCategory;
  final DensityCategory densityCategory;

  DeviceInfo({
    required this.screenWidth,
    required this.screenHeight,
    required this.devicePixelRatio,
    required this.orientation,
    required this.platform,
    required this.isAndroid,
    required this.isIOS,
    required this.brightness,
    required this.isDarkMode,
    required this.statusBarHeight,
    required this.bottomPadding,
    required this.safeAreaTop,
    required this.safeAreaBottom,
    required this.screenSizeCategory,
    required this.densityCategory,
  });

  String get screenSizeName {
    switch (screenSizeCategory) {
      case ScreenSizeCategory.compact:
        return 'Compact';
      case ScreenSizeCategory.medium:
        return 'Medium';
      case ScreenSizeCategory.expanded:
        return 'Expanded';
    }
  }

  String get densityName {
    switch (densityCategory) {
      case DensityCategory.ldpi:
        return 'LDPI';
      case DensityCategory.mdpi:
        return 'MDPI';
      case DensityCategory.hdpi:
        return 'HDPI';
      case DensityCategory.xhdpi:
        return 'XHDPI';
      case DensityCategory.xxhdpi:
        return 'XXHDPI';
      case DensityCategory.xxxhdpi:
        return 'XXXHDPI';
    }
  }
}

/// Device capabilities data class
class DeviceCapabilities {
  final bool hasCamera;
  final bool hasLocation;
  final bool hasNotifications;
  final bool hasInternet;
  final bool isEmulator;
  final bool canVibrate;

  DeviceCapabilities({
    required this.hasCamera,
    required this.hasLocation,
    required this.hasNotifications,
    required this.hasInternet,
    required this.isEmulator,
    required this.canVibrate,
  });

  factory DeviceCapabilities.defaultCapabilities() {
    return DeviceCapabilities(
      hasCamera: false,
      hasLocation: false,
      hasNotifications: false,
      hasInternet: false,
      isEmulator: true,
      canVibrate: false,
    );
  }
}

/// Device performance metrics
class DevicePerformance {
  final DateTime timestamp;
  final double memoryUsage;
  final double cpuUsage;
  final double frameRate;

  DevicePerformance({
    required this.timestamp,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.frameRate,
  });
}

/// Network test result
class NetworkTestResult {
  final bool isConnected;
  final int latency;
  final String? error;

  NetworkTestResult({
    required this.isConnected,
    required this.latency,
    this.error,
  });
}

/// Orientation information
class OrientationInfo {
  final Orientation orientation;
  final bool isPortrait;
  final bool isLandscape;
  final double aspectRatio;

  OrientationInfo({
    required this.orientation,
    required this.isPortrait,
    required this.isLandscape,
    required this.aspectRatio,
  });
}

/// Screen size categories
enum ScreenSizeCategory { compact, medium, expanded }

/// Screen density categories
enum DensityCategory { ldpi, mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi }
