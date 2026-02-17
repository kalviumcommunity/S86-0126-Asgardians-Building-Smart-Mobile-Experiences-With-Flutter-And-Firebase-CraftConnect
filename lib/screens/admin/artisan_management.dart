import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/shop_provider.dart';
import '../../models/shop_model.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';

class ArtisanManagement extends StatefulWidget {
  const ArtisanManagement({super.key});

  @override
  State<ArtisanManagement> createState() => _ArtisanManagementState();
}

class _ArtisanManagementState extends State<ArtisanManagement> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadArtisans();
  }

  Future<void> _loadArtisans() async {
    await Provider.of<ShopProvider>(context, listen: false).getAllShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artisan Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Search by shop name or owner...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredShops = shopProvider.shops.where((shop) {
            return shop.shopName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                shop.ownerId.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredShops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_search,
                    size: 64,
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'No artisans found',
                    style: TextStyle(color: AppTheme.textSecondaryColor),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filteredShops.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final shop = filteredShops[index];
              return _buildArtisanCard(context, shop, shopProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildArtisanCard(
    BuildContext context,
    ShopModel shop,
    ShopProvider shopProvider,
  ) {
    return Container(
      decoration: AppDecorations.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          backgroundImage:
              shop.imageUrl != null ? NetworkImage(shop.imageUrl!) : null,
          child: shop.imageUrl == null
              ? const Icon(Icons.store, color: AppTheme.primaryColor)
              : null,
        ),
        title: Text(
          shop.shopName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Owner ID: ${shop.ownerId}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Contact: ${shop.contact}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDelete(context, shop, shopProvider);
            } else if (value == 'view') {
              context.push('/shop/${shop.slug}');
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View Shop')),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Remove Shop',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ShopModel shop,
    ShopProvider shopProvider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Shop?'),
        content: Text(
          'Are you sure you want to remove "${shop.shopName}" from the platform? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await shopProvider.deleteShop(shop.shopId);
      if (!mounted) return;

      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Shop removed successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }
}
