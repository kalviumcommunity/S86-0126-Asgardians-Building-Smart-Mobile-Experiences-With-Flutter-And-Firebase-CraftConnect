import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'package:craftconnect/config/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppDecorations.cardDecoration,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    authProvider.currentUser?.name
                            .substring(0, 1)
                            .toUpperCase() ??
                        'U',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  authProvider.currentUser?.name ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  authProvider.currentUser?.email ?? '',
                  style: const TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Language Selection
          _buildSettingCard(
            context,
            'Language',
            Icons.language,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Language'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('English'),
                        onTap: () {
                          authProvider.changeLanguage(const Locale('en'));
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('हिंदी (Hindi)'),
                        onTap: () {
                          authProvider.changeLanguage(const Locale('hi'));
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('తెలుగు (Telugu)'),
                        onTap: () {
                          authProvider.changeLanguage(const Locale('te'));
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Notifications
          _buildSettingCard(
            context,
            'Notifications',
            Icons.notifications,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notification settings coming soon!')),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Help & Support
          _buildSettingCard(
            context,
            'Help & Support',
            Icons.help,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support coming soon!')),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // About
          _buildSettingCard(
            context,
            'About CraftConnect',
            Icons.info,
            () {
              showAboutDialog(
                context: context,
                applicationName: 'CraftConnect',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    '© 2026 CraftConnect\nEmpowering Local Artisans',
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // Logout Button
          ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorColor),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await authProvider.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: AppDecorations.cardDecoration,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}