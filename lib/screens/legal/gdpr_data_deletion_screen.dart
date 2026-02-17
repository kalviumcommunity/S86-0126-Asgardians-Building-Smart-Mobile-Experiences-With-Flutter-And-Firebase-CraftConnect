import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class GDPRDataDeletionScreen extends StatefulWidget {
  const GDPRDataDeletionScreen({super.key});

  @override
  State<GDPRDataDeletionScreen> createState() => _GDPRDataDeletionScreenState();
}

class _GDPRDataDeletionScreenState extends State<GDPRDataDeletionScreen> {
  bool _isDeleting = false;
  bool _confirmDeletion = false;
  final TextEditingController _confirmTextController = TextEditingController();

  @override
  void dispose() {
    _confirmTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete My Data'),
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningSection(),
            const SizedBox(height: 24),
            _buildDataTypesSection(),
            const SizedBox(height: 24),
            _buildConsequencesSection(),
            const SizedBox(height: 24),
            _buildConfirmationSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor, width: 2),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.errorColor,
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Permanent Data Deletion',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'This action cannot be undone. Once you delete your data, all information associated with your account will be permanently removed from our systems.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data to be Deleted',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildDataItem(Icons.person, 'Profile Information',
            'Name, email, phone number, profile picture'),
        _buildDataItem(Icons.shop, 'Shop Data',
            'Shop details, product listings, shop images'),
        _buildDataItem(Icons.shopping_cart, 'Order History',
            'Purchase records, transaction details'),
        _buildDataItem(Icons.chat, 'Messages',
            'All conversations with artisans and customers'),
        _buildDataItem(Icons.favorite, 'Preferences',
            'Wishlist, settings, search history'),
        _buildDataItem(Icons.star, 'Reviews', 'Reviews given and received'),
        _buildDataItem(Icons.analytics, 'Usage Data',
            'App usage patterns, analytics data'),
      ],
    );
  }

  Widget _buildDataItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsequencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consequences of Deletion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildConsequenceItem(
                  '• You will lose access to your account immediately'),
              _buildConsequenceItem(
                  '• All orders and transaction history will be deleted'),
              _buildConsequenceItem(
                  '• Your shop (if any) will be permanently closed'),
              _buildConsequenceItem(
                  '• All conversations with other users will be deleted'),
              _buildConsequenceItem('• You cannot recover this data later'),
              _buildConsequenceItem(
                  '• You must create a new account to use CraftConnect again'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsequenceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _confirmDeletion,
              onChanged: (value) {
                setState(() {
                  _confirmDeletion = value ?? false;
                });
              },
              activeColor: AppTheme.errorColor,
            ),
            const Expanded(
              child: Text(
                'I understand that this action is permanent and cannot be undone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmTextController,
          decoration: const InputDecoration(
            labelText: 'Type "DELETE MY DATA" to confirm',
            hintText: 'DELETE MY DATA',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
            ),
            labelStyle: TextStyle(color: AppTheme.errorColor),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final canDelete = _confirmDeletion &&
        _confirmTextController.text.trim() == 'DELETE MY DATA' &&
        !_isDeleting;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canDelete ? _deleteAllUserData : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Delete All My Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteAllUserData() async {
    if (!mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting your data...'),
            ],
          ),
        ),
      );

      // Delete user data from various services
      await _deleteUserDataServices(currentUser.uid);

      // Delete authentication account
      await FirebaseAuth.instance.currentUser?.delete();

      // Sign out
      await authProvider.signOut();

      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog

        // Show completion dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Data Deleted'),
            content: const Text(
              'Your account and all associated data have been permanently deleted. '
              'Thank you for using CraftConnect.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // Navigate to auth screen
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });

      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting data: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteUserDataServices(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    // Delete Firestore collections
    final batch = firestore.batch();

    // Delete user profile
    batch.delete(firestore.collection('users').doc(userId));

    // Delete user's shops
    final shopsQuery = await firestore
        .collection('shops')
        .where('artisanId', isEqualTo: userId)
        .get();

    for (final shop in shopsQuery.docs) {
      batch.delete(shop.reference);

      // Delete shop's products
      final productsQuery = await firestore
          .collection('products')
          .where('shopId', isEqualTo: shop.id)
          .get();

      for (final product in productsQuery.docs) {
        batch.delete(product.reference);
      }
    }

    // Delete user's orders
    final ordersQuery = await firestore
        .collection('orders')
        .where('buyerId', isEqualTo: userId)
        .get();

    for (final order in ordersQuery.docs) {
      batch.delete(order.reference);
    }

    // Delete user's reviews
    final reviewsQuery = await firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .get();

    for (final review in reviewsQuery.docs) {
      batch.delete(review.reference);
    }

    // Delete user's conversations
    final conversationsQuery = await firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .get();

    for (final conversation in conversationsQuery.docs) {
      batch.delete(conversation.reference);

      // Delete messages in conversation
      final messagesQuery = await firestore
          .collection('conversations')
          .doc(conversation.id)
          .collection('messages')
          .get();

      for (final message in messagesQuery.docs) {
        batch.delete(message.reference);
      }
    }

    // Delete user's wishlist
    final wishlistQuery = await firestore
        .collection('wishlists')
        .where('userId', isEqualTo: userId)
        .get();

    for (final wishlist in wishlistQuery.docs) {
      batch.delete(wishlist.reference);
    }

    // Delete user's notifications
    final notificationsQuery = await firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    for (final notification in notificationsQuery.docs) {
      batch.delete(notification.reference);
    }

    // Commit batch delete
    await batch.commit();

    // Delete user files from Storage
    try {
      final userStorageRef = storage.ref().child('users/$userId');
      await _deleteStorageFolder(userStorageRef);
    } catch (e) {
      debugPrint('Error deleting user storage: $e');
    }
  }

  Future<void> _deleteStorageFolder(Reference folderRef) async {
    try {
      final listResult = await folderRef.listAll();

      // Delete all files
      for (final item in listResult.items) {
        await item.delete();
      }

      // Delete all subfolders recursively
      for (final prefix in listResult.prefixes) {
        await _deleteStorageFolder(prefix);
      }
    } catch (e) {
      debugPrint('Error deleting storage folder: $e');
    }
  }
}
