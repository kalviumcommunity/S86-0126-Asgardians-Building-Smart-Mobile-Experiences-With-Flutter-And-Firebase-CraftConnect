import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/shop_provider.dart';
import 'package:craftconnect/config/app_constants.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 100,
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Not logged in',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Login / Sign Up'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Profile Card
              Container(
                decoration: AppDecorations.cardDecoration,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user.phone,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Account Options
              _buildSection('Account Settings', [
                _buildListTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    context.push('/account/edit-profile');
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.favorite_outline,
                  title: 'My Wishlist',
                  onTap: () {
                    context.push('/account/wishlist');
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.people_outline,
                  title: 'Following',
                  onTap: () {
                    context.push('/account/following');
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'My Addresses',
                  onTap: () {
                    context.push('/account/addresses');
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.payment_outlined,
                  title: 'Payment Methods',
                  onTap: () {
                    context.push('/account/payment-methods');
                  },
                ),
              ]),

              const SizedBox(height: AppSpacing.md),

              _buildSection('Preferences', [
                _buildListTile(
                  context,
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    _showLanguageDialog(context);
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {
                    context.push('/account/notifications');
                  },
                ),
              ]),

              const SizedBox(height: AppSpacing.md),

              _buildSection('Support', [
                _buildListTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    context.push('/account/help-support');
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CraftConnect v1.0.0')),
                    );
                  },
                ),
              ]),

              const SizedBox(height: AppSpacing.md),

              // Developer Tools (only show in debug mode)
              _buildSection('Developer', [
                _buildListTile(
                  context,
                  icon: Icons.developer_mode,
                  title: 'Developer Tools',
                  subtitle: 'Database seeding & testing',
                  onTap: () {
                    context.push('/dev-tools');
                  },
                ),
              ]),

              const SizedBox(height: AppSpacing.xl),

              // Logout Button
              ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context, authProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        Container(
          decoration: AppDecorations.cardDecoration,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clear all providers
              Provider.of<OrderProvider>(context, listen: false).clear();
              Provider.of<ChatProvider>(context, listen: false).clear();
              Provider.of<ProductProvider>(context, listen: false).clear();
              Provider.of<ShopProvider>(context, listen: false).clear();
              // Try to clear cart and wishlist if they have clear methods
              try {
                // If these providers have clear() methods
                // Provider.of<CartProvider>(context, listen: false).clear();
                // Provider.of<WishlistProvider>(context, listen: false).clear();
              } catch (_) {}

              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String selectedLanguage = 'en';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(
                    context, 'English', 'en', selectedLanguage, setState,
                    (value) {
                  selectedLanguage = value;
                }),
                _buildLanguageOption(
                    context, 'हिन्दी (Hindi)', 'hi', selectedLanguage, setState,
                    (value) {
                  selectedLanguage = value;
                }),
                _buildLanguageOption(context, 'తెలుగు (Telugu)', 'te',
                    selectedLanguage, setState, (value) {
                  selectedLanguage = value;
                }),
                _buildLanguageOption(
                    context, 'தமிழ் (Tamil)', 'ta', selectedLanguage, setState,
                    (value) {
                  selectedLanguage = value;
                }),
                _buildLanguageOption(context, 'বাংলা (Bengali)', 'bn',
                    selectedLanguage, setState, (value) {
                  selectedLanguage = value;
                }),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.updateLanguage(selectedLanguage);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Language changed to ${_getLanguageName(selectedLanguage)}'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      case 'te':
        return 'Telugu';
      case 'ta':
        return 'Tamil';
      case 'bn':
        return 'Bengali';
      default:
        return 'English';
    }
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String value,
    String selectedValue,
    StateSetter setState,
    Function(String) onSelect,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          onSelect(value);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(
              selectedValue == value
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selectedValue == value
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}
