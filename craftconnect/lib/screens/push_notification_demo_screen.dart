import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

/// Demo screen to showcase Firebase Cloud Messaging (FCM) features
class PushNotificationDemoScreen extends StatefulWidget {
  const PushNotificationDemoScreen({super.key});

  @override
  State<PushNotificationDemoScreen> createState() =>
      _PushNotificationDemoScreenState();
}

class _PushNotificationDemoScreenState
    extends State<PushNotificationDemoScreen> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _topicController = TextEditingController();

  String? _fcmToken;
  NotificationSettings? _notificationSettings;
  bool _isLoading = false;
  final List<String> _subscribedTopics = [];

  @override
  void initState() {
    super.initState();
    _loadFCMData();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _loadFCMData() async {
    setState(() => _isLoading = true);

    try {
      // Get FCM token
      _fcmToken = _notificationService.fcmToken;

      // Get notification settings
      _notificationSettings = await FirebaseMessaging.instance
          .getNotificationSettings();

      setState(() {});
    } catch (e) {
      _showSnackBar('Error loading FCM data: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshToken() async {
    setState(() => _isLoading = true);

    try {
      await _notificationService.deleteToken();
      await Future.delayed(const Duration(seconds: 1));
      await _notificationService.initialize();
      await _loadFCMData();

      _showSnackBar('FCM token refreshed successfully');
    } catch (e) {
      _showSnackBar('Error refreshing token: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _copyTokenToClipboard() async {
    if (_fcmToken != null) {
      await Clipboard.setData(ClipboardData(text: _fcmToken!));
      _showSnackBar('FCM token copied to clipboard');
    }
  }

  Future<void> _subscribeToTopic() async {
    final topic = _topicController.text.trim();

    if (topic.isEmpty) {
      _showSnackBar('Please enter a topic name', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _notificationService.subscribeToTopic(topic);
      setState(() {
        if (!_subscribedTopics.contains(topic)) {
          _subscribedTopics.add(topic);
        }
      });
      _topicController.clear();
      _showSnackBar('Subscribed to topic: $topic');
    } catch (e) {
      _showSnackBar('Error subscribing to topic: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unsubscribeFromTopic(String topic) async {
    setState(() => _isLoading = true);

    try {
      await _notificationService.unsubscribeFromTopic(topic);
      setState(() {
        _subscribedTopics.remove(topic);
      });
      _showSnackBar('Unsubscribed from topic: $topic');
    } catch (e) {
      _showSnackBar('Error unsubscribing from topic: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getPermissionStatus() {
    if (_notificationSettings == null) return 'Unknown';

    switch (_notificationSettings!.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return '✅ Authorized';
      case AuthorizationStatus.provisional:
        return '⚠️ Provisional';
      case AuthorizationStatus.denied:
        return '❌ Denied';
      case AuthorizationStatus.notDetermined:
        return '❓ Not Determined';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadFCMData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildFCMTokenCard(),
                  const SizedBox(height: 16),
                  _buildTopicSubscriptionCard(),
                  const SizedBox(height: 16),
                  _buildInstructionsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Notification Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Permission:', _getPermissionStatus()),
            _buildInfoRow(
              'Alert:',
              _notificationSettings?.alert == AppleNotificationSetting.enabled
                  ? '✅ Enabled'
                  : '❌ Disabled',
            ),
            _buildInfoRow(
              'Badge:',
              _notificationSettings?.badge == AppleNotificationSetting.enabled
                  ? '✅ Enabled'
                  : '❌ Disabled',
            ),
            _buildInfoRow(
              'Sound:',
              _notificationSettings?.sound == AppleNotificationSetting.enabled
                  ? '✅ Enabled'
                  : '❌ Disabled',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildFCMTokenCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.vpn_key, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'FCM Device Token',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (_fcmToken != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  _fcmToken!,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _copyTokenToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Token'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _refreshToken,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              const Text(
                'No FCM token available',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicSubscriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.topic, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Topic Subscriptions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(
                      labelText: 'Topic Name',
                      hintText: 'e.g., news, updates',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _subscribeToTopic,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            if (_subscribedTopics.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Subscribed Topics:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _subscribedTopics
                    .map(
                      (topic) => Chip(
                        label: Text(topic),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _unsubscribeFromTopic(topic),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'How to Test Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInstruction(
              '1',
              'Copy your FCM token using the button above',
            ),
            _buildInstruction('2', 'Go to Firebase Console → Cloud Messaging'),
            _buildInstruction('3', 'Click "Send your first message"'),
            _buildInstruction('4', 'Enter notification title and body'),
            _buildInstruction(
              '5',
              'Select "Send test message" and paste your token',
            ),
            _buildInstruction(
              '6',
              'Test in different app states: foreground, background, and terminated',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: Testing on iOS requires additional APNs setup',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
