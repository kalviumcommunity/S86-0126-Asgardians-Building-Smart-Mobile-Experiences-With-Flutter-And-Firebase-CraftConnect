import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/follow_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/shop_model.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final followProvider = Provider.of<FollowProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await followProvider.loadFollowing(authProvider.currentUser!.uid);
    }
  }

  Future<void> _unfollowShop(ShopModel shop) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final followProvider = Provider.of<FollowProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unfollow Artisan'),
        content: Text('Are you sure you want to unfollow ${shop.shopName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Unfollow'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await followProvider.unfollowShop(
        authProvider.currentUser!.uid,
        shop.shopId,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unfollowed ${shop.shopName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: Consumer<FollowProvider>(
        builder: (context, followProvider, child) {
          if (followProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final followedShops = followProvider.followedShops;

          if (followedShops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Not following anyone yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Follow artisans to get updates\non their new products',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/home');
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('Explore Artisans'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadFollowing,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: followedShops.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final shop = followedShops[index];
                return _buildArtisanCard(shop);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtisanCard(ShopModel shop) {
    final followProvider = Provider.of<FollowProvider>(context);
    final followerCount = followProvider.getFollowerCount(shop.shopId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('/artisan/${shop.shopId}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile picture
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  image: shop.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(shop.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: shop.imageUrl == null
                    ? const Icon(
                        Icons.store,
                        size: 30,
                        color: AppTheme.primaryColor,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Shop info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.shopName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (shop.isApproved)
                          Icon(
                            Icons.verified,
                            size: 18,
                            color: Colors.green[700],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (shop.description.isNotEmpty)
                      Text(
                        shop.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$followerCount followers',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Unfollow button
              OutlinedButton(
                onPressed: () => _unfollowShop(shop),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Unfollow'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
