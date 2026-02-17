import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../widgets/empty_state_widget.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final _firestore = FirebaseFirestore.instance;
  String _filter = 'all'; // all, buyers, artisans, suspended

  Future<void> _toggleUserStatus(String userId, bool currentStatus) async {
    final action = currentStatus ? 'suspend' : 'activate';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action == 'suspend' ? 'Suspend' : 'Activate'} User'),
        content: Text(
          'Are you sure you want to $action this user?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'suspend'
                  ? AppTheme.errorColor
                  : AppTheme.successColor,
            ),
            child: Text(action == 'suspend' ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _firestore.collection('users').doc(userId).update({
        'isActive': !currentStatus,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${action}d successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  Future<void> _viewUserDetails(Map<String, dynamic> user) async {
    // Get user's orders count and total spent
    final ordersSnapshot = await _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: user['uid'])
        .get();

    final totalOrders = ordersSnapshot.docs.length;
    final totalSpent = ordersSnapshot.docs.fold<double>(
      0,
      (total, doc) => total + (doc.data()['totalAmount'] ?? 0),
    );

    // Get user's shops if artisan
    QuerySnapshot? shopsSnapshot;
    if (user['userType'] == 'artisan') {
      shopsSnapshot = await _firestore
          .collection('shops')
          .where('ownerId', isEqualTo: user['uid'])
          .get();
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(user['name'] ?? 'User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Email', user['email'] ?? 'N/A'),
                _buildDetailRow('Phone', user['phone'] ?? 'N/A'),
                _buildDetailRow('User Type', user['userType'] ?? 'N/A'),
                _buildDetailRow(
                  'Status',
                  (user['isActive'] ?? true) ? 'Active' : 'Suspended',
                ),
                _buildDetailRow('Total Orders', totalOrders.toString()),
                _buildDetailRow(
                    'Total Spent', '₹${totalSpent.toStringAsFixed(0)}'),
                if (user['userType'] == 'artisan' && shopsSnapshot != null)
                  _buildDetailRow(
                      'Shops', shopsSnapshot.docs.length.toString()),
                _buildDetailRow(
                  'Member Since',
                  _formatDate(user['createdAt']),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    final date = (timestamp as Timestamp).toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('Buyers', 'buyers'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('Artisans', 'artisans'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('Suspended', 'suspended'),
                ],
              ),
            ),
          ),

          // Users List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.people,
                    title: 'No Users',
                    message: 'No users found',
                  );
                }

                final users = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    final user = userDoc.data() as Map<String, dynamic>;
                    final userId = userDoc.id;
                    final isActive = user['isActive'] ?? true;

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user['userType'] == 'artisan'
                              ? AppTheme.accentColor
                              : AppTheme.primaryColor,
                          child: Text(
                            (user['name'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user['name'] ?? 'Unknown User'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email'] ?? 'No email'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user['userType'] == 'artisan'
                                        ? AppTheme.accentColor
                                            .withValues(alpha: 0.1)
                                        : AppTheme.primaryColor
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (user['userType'] ?? 'buyer').toUpperCase(),
                                    style: TextStyle(
                                      color: user['userType'] == 'artisan'
                                          ? AppTheme.accentColor
                                          : AppTheme.primaryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppTheme.successColor
                                            .withValues(alpha: 0.1)
                                        : AppTheme.errorColor
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActive ? 'ACTIVE' : 'SUSPENDED',
                                    style: TextStyle(
                                      color: isActive
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.info),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                              onTap: () => Future.delayed(
                                const Duration(milliseconds: 100),
                                () => _viewUserDetails(user),
                              ),
                            ),
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(
                                    isActive ? Icons.block : Icons.check_circle,
                                    color: isActive
                                        ? AppTheme.errorColor
                                        : AppTheme.successColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(isActive ? 'Suspend' : 'Activate'),
                                ],
                              ),
                              onTap: () => Future.delayed(
                                const Duration(milliseconds: 100),
                                () => _toggleUserStatus(userId, isActive),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getUsersStream() {
    var query = _firestore.collection('users');

    switch (_filter) {
      case 'buyers':
        return query.where('userType', isEqualTo: 'buyer').snapshots();
      case 'artisans':
        return query.where('userType', isEqualTo: 'artisan').snapshots();
      case 'suspended':
        return query.where('isActive', isEqualTo: false).snapshots();
      default:
        return query.snapshots();
    }
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
