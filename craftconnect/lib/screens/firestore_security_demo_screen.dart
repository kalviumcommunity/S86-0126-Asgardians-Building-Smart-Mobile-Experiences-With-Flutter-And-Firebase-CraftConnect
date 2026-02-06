import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/secure_firestore_service.dart';

/// Demo screen showcasing Firestore Security Rules and Authentication
class FirestoreSecurityDemoScreen extends StatefulWidget {
  const FirestoreSecurityDemoScreen({super.key});

  @override
  State<FirestoreSecurityDemoScreen> createState() =>
      _FirestoreSecurityDemoScreenState();
}

class _FirestoreSecurityDemoScreenState
    extends State<FirestoreSecurityDemoScreen> {
  final SecureFirestoreService _firestoreService = SecureFirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postContentController = TextEditingController();

  bool _isLoading = false;
  String _statusMessage = '';
  DocumentSnapshot? _userProfile;
  List<DocumentSnapshot> _userPosts = [];
  Map<String, bool> _securityTestResults = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _postTitleController.dispose();
    _postContentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!_firestoreService.isAuthenticated) {
      setState(() => _statusMessage = '⚠️ User not authenticated');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profile = await _firestoreService.getUserProfile();
      setState(() {
        _userProfile = profile;
        if (profile.exists) {
          _nameController.text = profile.get('name') ?? '';
        }
      });
    } catch (e) {
      _showMessage('Error loading profile: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createOrUpdateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Please enter a name', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestoreService.createUserProfile(
        name: _nameController.text.trim(),
        bio: 'Testing secure Firestore operations',
      );

      _showMessage('✅ Profile saved successfully!');
      await _loadUserData();
    } catch (e) {
      _showMessage('❌ Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createPost() async {
    if (_postTitleController.text.trim().isEmpty ||
        _postContentController.text.trim().isEmpty) {
      _showMessage('Please enter title and content', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestoreService.createPost(
        title: _postTitleController.text.trim(),
        content: _postContentController.text.trim(),
        tags: ['demo', 'security'],
      );

      _showMessage('✅ Post created successfully!');
      _postTitleController.clear();
      _postContentController.clear();
      await _loadUserPosts();
    } catch (e) {
      _showMessage('❌ Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserPosts() async {
    setState(() => _isLoading = true);

    try {
      _firestoreService.getUserPosts().listen((snapshot) {
        setState(() {
          _userPosts = snapshot.docs;
        });
      });
    } catch (e) {
      _showMessage('Error loading posts: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePost(String postId) async {
    setState(() => _isLoading = true);

    try {
      await _firestoreService.deletePost(postId);
      _showMessage('✅ Post deleted successfully!');
      await _loadUserPosts();
    } catch (e) {
      _showMessage('❌ Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testSecurityRules() async {
    setState(() => _isLoading = true);

    try {
      final results = await _firestoreService.testSecurityRules();
      setState(() {
        _securityTestResults = results;
      });
      _showMessage('✅ Security tests completed!');
    } catch (e) {
      _showMessage('❌ Error testing rules: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testUnauthorizedAccess() async {
    setState(() => _isLoading = true);

    try {
      // Try to access another user's data (should fail)
      await _firestoreService.attemptUnauthorizedRead('fake_user_id_123');
      _showMessage(
        '❌ Security breach: Unauthorized read succeeded!',
        isError: true,
      );
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        _showMessage('✅ Security works: Unauthorized read blocked!');
      } else {
        _showMessage('❌ Unexpected error: $e', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    setState(() => _statusMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Firestore Security Demo')),
        body: const Center(
          child: Text(
            '⚠️ Please sign in to test Firestore security',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Security Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
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
                  _buildAuthInfoCard(user),
                  const SizedBox(height: 16),
                  _buildProfileSection(),
                  const SizedBox(height: 16),
                  _buildPostSection(),
                  const SizedBox(height: 16),
                  _buildSecurityTestSection(),
                  const SizedBox(height: 16),
                  _buildUserPostsList(),
                  const SizedBox(height: 16),
                  _buildRulesInfoCard(),
                  if (_statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildStatusCard(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildAuthInfoCard(User user) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified_user, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Authentication Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Status:', '✅ Authenticated'),
            _buildInfoRow('Email:', user.email ?? 'No email'),
            _buildInfoRow('UID:', user.uid),
            _buildInfoRow(
              'Email Verified:',
              user.emailVerified ? '✅ Yes' : '❌ No',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'User Profile (Secured)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _createOrUpdateProfile,
              icon: const Icon(Icons.save),
              label: Text(
                _userProfile?.exists == true
                    ? 'Update Profile'
                    : 'Create Profile',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            if (_userProfile?.exists == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Profile:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${_userProfile!.get('name')}'),
                    Text('Email: ${_userProfile!.get('email')}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPostSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.post_add, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Create Post (Secured)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            TextField(
              controller: _postTitleController,
              decoration: const InputDecoration(
                labelText: 'Post Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _postContentController,
              decoration: const InputDecoration(
                labelText: 'Post Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _createPost,
              icon: const Icon(Icons.send),
              label: const Text('Create Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTestSection() {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.security, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Security Tests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testSecurityRules,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Test Rules'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testUnauthorizedAccess,
                    icon: const Icon(Icons.block),
                    label: const Text('Test Breach'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            if (_securityTestResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Results:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._securityTestResults.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              entry.value ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: entry.value ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(entry.key),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserPostsList() {
    if (_userPosts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.article_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'No posts yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadUserPosts,
                child: const Text('Load Posts'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Posts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_userPosts.length} posts',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userPosts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final post = _userPosts[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.article)),
                  title: Text(post.get('title')),
                  subtitle: Text(
                    post.get('content'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePost(post.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesInfoCard() {
    return Card(
      color: Colors.blue.shade50,
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
                  'Security Rules Applied',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildRuleInfo('✅ Only authenticated users can access data'),
            _buildRuleInfo('✅ Users can only modify their own profile'),
            _buildRuleInfo('✅ Users can only delete their own posts'),
            _buildRuleInfo('✅ Private data is accessible only by owner'),
            _buildRuleInfo('✅ Cross-account access is blocked'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Deploy rules to Firebase Console for production',
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

  Widget _buildRuleInfo(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _statusMessage.contains('❌')
          ? Colors.red.shade50
          : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          _statusMessage,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
