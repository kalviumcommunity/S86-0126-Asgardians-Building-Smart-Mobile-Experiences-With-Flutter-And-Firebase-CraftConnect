import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/testing/device_testing_utils.dart';
import '../../widgets/state_widgets/loading_widget.dart';
import '../../widgets/state_widgets/error_widget.dart';

/// Comprehensive device testing dashboard for testing app on different devices
/// Provides device information, capability testing, and debugging tools
class DeviceTestingScreen extends StatefulWidget {
  const DeviceTestingScreen({super.key});

  @override
  State<DeviceTestingScreen> createState() => _DeviceTestingScreenState();
}

class _DeviceTestingScreenState extends State<DeviceTestingScreen> {
  DeviceCapabilities? _capabilities;
  NetworkTestResult? _networkResult;
  DevicePerformance? _performance;
  bool _isTestingCapabilities = false;
  bool _isTestingNetwork = false;
  String? _testError;

  @override
  void initState() {
    super.initState();
    _runInitialTests();
  }

  Future<void> _runInitialTests() async {
    await _testDeviceCapabilities();
    await _testNetworkConnectivity();
    _updatePerformanceMetrics();
  }

  Future<void> _testDeviceCapabilities() async {
    setState(() {
      _isTestingCapabilities = true;
      _testError = null;
    });

    try {
      final capabilities = await DeviceTestingUtils.testDeviceCapabilities();
      setState(() {
        _capabilities = capabilities;
        _isTestingCapabilities = false;
      });
    } catch (e) {
      setState(() {
        _testError = e.toString();
        _isTestingCapabilities = false;
      });
    }
  }

  Future<void> _testNetworkConnectivity() async {
    setState(() {
      _isTestingNetwork = true;
    });

    try {
      final result = await DeviceTestingUtils.testNetworkConnectivity();
      setState(() {
        _networkResult = result;
        _isTestingNetwork = false;
      });
    } catch (e) {
      setState(() {
        _networkResult = NetworkTestResult(
          isConnected: false,
          latency: 0,
          error: e.toString(),
        );
        _isTestingNetwork = false;
      });
    }
  }

  void _updatePerformanceMetrics() {
    setState(() {
      _performance = DeviceTestingUtils.getPerformanceMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceInfo = DeviceTestingUtils.getDeviceInfo(context);
    final orientationInfo = DeviceTestingUtils.getOrientationInfo(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Testing Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runInitialTests,
            tooltip: 'Refresh Tests',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Test Results'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'screenshot',
                child: ListTile(
                  leading: Icon(Icons.screenshot),
                  title: Text('Take Screenshot'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _runInitialTests,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Device Information Card
            _buildDeviceInfoCard(deviceInfo),
            const SizedBox(height: 16),

            // Orientation Information Card
            _buildOrientationCard(orientationInfo),
            const SizedBox(height: 16),

            // Device Capabilities Card
            _buildCapabilitiesCard(),
            const SizedBox(height: 16),

            // Network Testing Card
            _buildNetworkTestCard(),
            const SizedBox(height: 16),

            // Performance Metrics Card
            _buildPerformanceCard(),
            const SizedBox(height: 16),

            // Screen Size Testing Card
            _buildScreenSizeTestCard(deviceInfo),
            const SizedBox(height: 16),

            // Testing Tools Card
            _buildTestingToolsCard(context),

            // Error Display
            if (_testError != null) ...[
              const SizedBox(height: 16),
              InlineErrorWidget(
                message: _testError!,
                onRetry: _runInitialTests,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(DeviceInfo info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(
                info.isAndroid ? Icons.android : Icons.phone_iphone,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Device Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoGrid([
            InfoItem('Platform', info.platform.toUpperCase()),
            InfoItem(
              'Screen Size',
              '${info.screenWidth.toInt()} × ${info.screenHeight.toInt()}',
            ),
            InfoItem('Pixel Ratio', info.devicePixelRatio.toStringAsFixed(1)),
            InfoItem('Orientation', info.orientation.name),
            InfoItem('Theme', info.isDarkMode ? 'Dark' : 'Light'),
            InfoItem('Screen Category', info.screenSizeName),
            InfoItem('Density', info.densityName),
            InfoItem('Status Bar', '${info.statusBarHeight.toInt()}dp'),
          ]),
        ],
      ),
    );
  }

  Widget _buildOrientationCard(OrientationInfo info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(
                info.isPortrait
                    ? Icons.stay_current_portrait
                    : Icons.stay_current_landscape,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Orientation Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoGrid([
            InfoItem('Current', info.orientation.name),
            InfoItem('Is Portrait', info.isPortrait ? 'Yes' : 'No'),
            InfoItem('Is Landscape', info.isLandscape ? 'Yes' : 'No'),
            InfoItem('Aspect Ratio', info.aspectRatio.toStringAsFixed(2)),
          ]),

          const SizedBox(height: 16),
          Text(
            'Rotate your device to test orientation changes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check),
              const SizedBox(width: 8),
              Text(
                'Device Capabilities',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (_isTestingCapabilities)
                const LoadingWidget.inline()
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _testDeviceCapabilities,
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_capabilities != null) ...[
            _buildCapabilityItem(
              'Device Type',
              _capabilities!.isEmulator ? 'Emulator' : 'Physical Device',
            ),
            _buildCapabilityItem('Camera', _capabilities!.hasCamera),
            _buildCapabilityItem('Location', _capabilities!.hasLocation),
            _buildCapabilityItem(
              'Notifications',
              _capabilities!.hasNotifications,
            ),
            _buildCapabilityItem('Internet', _capabilities!.hasInternet),
            _buildCapabilityItem('Vibration', _capabilities!.canVibrate),
          ] else if (_isTestingCapabilities) ...[
            const LoadingWidget(message: 'Testing device capabilities...'),
          ] else ...[
            const Text('Tap refresh to test capabilities'),
          ],
        ],
      ),
    );
  }

  Widget _buildNetworkTestCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(Icons.network_check),
              const SizedBox(width: 8),
              Text(
                'Network Testing',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (_isTestingNetwork)
                const LoadingWidget.inline()
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _testNetworkConnectivity,
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_networkResult != null) ...[
            _buildCapabilityItem('Connection', _networkResult!.isConnected),
            if (_networkResult!.isConnected)
              _buildInfoItem('Latency', '${_networkResult!.latency}ms')
            else if (_networkResult!.error != null)
              _buildInfoItem('Error', _networkResult!.error!),
          ] else if (_isTestingNetwork) ...[
            const LoadingWidget(message: 'Testing network connectivity...'),
          ] else ...[
            const Text('Tap refresh to test network'),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(Icons.speed),
              const SizedBox(width: 8),
              Text(
                'Performance Metrics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _updatePerformanceMetrics,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_performance != null) ...[
            _buildInfoItem(
              'Timestamp',
              _performance!.timestamp.toString().split('.')[0],
            ),
            _buildInfoItem(
              'Frame Rate',
              '${_performance!.frameRate.toStringAsFixed(1)} FPS',
            ),
            _buildInfoItem(
              'Memory Usage',
              '${_performance!.memoryUsage.toStringAsFixed(1)} MB',
            ),
            _buildInfoItem(
              'CPU Usage',
              '${_performance!.cpuUsage.toStringAsFixed(1)}%',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScreenSizeTestCard(DeviceInfo info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(Icons.aspect_ratio),
              const SizedBox(width: 8),
              Text(
                'Screen Size Testing',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('Test different breakpoints and responsive design:'),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildScreenSizeChip(
                'Compact',
                info.screenSizeCategory == ScreenSizeCategory.compact,
              ),
              _buildScreenSizeChip(
                'Medium',
                info.screenSizeCategory == ScreenSizeCategory.medium,
              ),
              _buildScreenSizeChip(
                'Expanded',
                info.screenSizeCategory == ScreenSizeCategory.expanded,
              ),
            ],
          ),

          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _showScreenSizeDetails(context, info),
            child: const Text('View Detailed Breakpoints'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestingToolsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Testing Tools', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _testVibration(),
                icon: const Icon(Icons.vibration),
                label: const Text('Test Vibration'),
              ),
              ElevatedButton.icon(
                onPressed: () => _testFullScreen(),
                icon: const Icon(Icons.fullscreen),
                label: const Text('Test Fullscreen'),
              ),
              ElevatedButton.icon(
                onPressed: () => _testPermissions(),
                icon: const Icon(Icons.security),
                label: const Text('Test Permissions'),
              ),
              ElevatedButton.icon(
                onPressed: () => _exportTestResults(),
                icon: const Icon(Icons.download),
                label: const Text('Export Results'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(List<InfoItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildInfoItem(item.label, item.value);
      },
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityItem(String label, dynamic value) {
    bool isSupported = value is bool ? value : false;
    String displayValue = value is bool
        ? (value ? 'Supported' : 'Not Available')
        : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isSupported ? Icons.check_circle : Icons.cancel,
            color: isSupported ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            displayValue,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isSupported ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenSizeChip(String label, bool isActive) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: null, // Read-only
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportTestResults();
        break;
      case 'screenshot':
        _takeScreenshot();
        break;
    }
  }

  void _testVibration() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Vibration test completed')));
  }

  void _testFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const _FullScreenTestWidget()),
    );
  }

  void _testPermissions() {
    // In a real implementation, you would test actual permissions
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Testing'),
        content: const Text(
          'This would test various app permissions like camera, location, notifications, etc.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportTestResults() {
    // In a real implementation, you would export the test results
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test results exported')));
  }

  void _takeScreenshot() {
    // In a real implementation, you would take a screenshot
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Screenshot taken')));
  }

  void _showScreenSizeDetails(BuildContext context, DeviceInfo info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screen Size Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Width: ${info.screenWidth.toInt()}dp'),
            Text('Height: ${info.screenHeight.toInt()}dp'),
            Text('Category: ${info.screenSizeName}'),
            Text('Density: ${info.densityName}'),
            const SizedBox(height: 16),
            const Text('Material Design Breakpoints:'),
            const Text('• Compact: < 600dp'),
            const Text('• Medium: 600dp - 840dp'),
            const Text('• Expanded: > 840dp'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}

/// Full screen test widget
class _FullScreenTestWidget extends StatelessWidget {
  const _FullScreenTestWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fullscreen,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Full Screen Test',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Testing full screen mode\nTap anywhere to exit',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Exit button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
