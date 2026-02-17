import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';

class ArtisanMainNavigation extends StatelessWidget {
  const ArtisanMainNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OrderProvider, ProductProvider>(
      builder: (context, orderProvider, productProvider, child) {
        final pendingOrdersCount = orderProvider.newOrders.length;
        final productsCount = productProvider.products.length;

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondaryColor,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text('$productsCount'),
                  isLabelVisible: productsCount > 0,
                  child: const Icon(Icons.inventory_2_outlined),
                ),
                activeIcon: Badge(
                  label: Text('$productsCount'),
                  isLabelVisible: productsCount > 0,
                  child: const Icon(Icons.inventory_2),
                ),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text('$pendingOrdersCount'),
                  isLabelVisible: pendingOrdersCount > 0,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                activeIcon: Badge(
                  label: Text('$pendingOrdersCount'),
                  isLabelVisible: pendingOrdersCount > 0,
                  child: const Icon(Icons.shopping_bag),
                ),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
