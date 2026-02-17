import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/font_size_provider.dart';
import '../../utils/accessibility_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return AccessibleWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          children: [
            // Appearance Section
            _buildSectionHeader(context, 'Appearance'),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark themes'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
                AccessibilityHelper.announceMessage(
                  context,
                  value ? 'Dark mode enabled' : 'Light mode enabled',
                );
              },
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppTheme.primaryColor,
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.text_fields, color: AppTheme.primaryColor),
              title: const Text('Text Size'),
              subtitle: Text(fontSizeProvider.getFontSizeLabel()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.text_decrease),
                    onPressed: fontSizeProvider.fontScale > 0.8
                        ? () {
                            fontSizeProvider.decreaseFontSize();
                            AccessibilityHelper.announceMessage(
                              context,
                              'Text size changed: ${fontSizeProvider.getFontSizeLabel()}',
                            );
                          }
                        : null,
                    tooltip: 'Decrease text size',
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_increase),
                    onPressed: fontSizeProvider.fontScale < 2.0
                        ? () {
                            fontSizeProvider.increaseFontSize();
                            AccessibilityHelper.announceMessage(
                              context,
                              'Text size changed: ${fontSizeProvider.getFontSizeLabel()}',
                            );
                          }
                        : null,
                    tooltip: 'Increase text size',
                  ),
                ],
              ),
            ),
            const Divider(),

            // Accessibility Section
            _buildSectionHeader(context, 'Accessibility'),
            SwitchListTile(
              title: const Text('Screen Reader Support'),
              subtitle: const Text('Enhance accessibility for screen readers'),
              value: AccessibilityHelper.isScreenReaderEnabled(context),
              onChanged: null, // Read-only - system setting
              secondary:
                  const Icon(Icons.accessibility, color: AppTheme.primaryColor),
            ),
            const Divider(),

            // Account Section
            _buildSectionHeader(context, 'Account'),
            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.primaryColor),
              title: const Text('Profile'),
              subtitle:
                  Text(authProvider.currentUser?.email ?? 'Not logged in'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to profile
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.notifications, color: AppTheme.primaryColor),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to notification settings
              },
            ),
            const Divider(),

            // Language Section
            _buildSectionHeader(context, 'Language & Region'),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primaryColor),
              title: const Text('Language'),
              subtitle: Text(_getLanguageName(authProvider.currentLocale)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, authProvider),
            ),
            const Divider(),

            // Privacy Section
            _buildSectionHeader(context, 'Privacy & Legal'),
            ListTile(
              leading:
                  const Icon(Icons.privacy_tip, color: AppTheme.primaryColor),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/privacy-policy');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.description, color: AppTheme.primaryColor),
              title: const Text('Terms & Conditions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/terms-conditions');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return,
                  color: AppTheme.primaryColor),
              title: const Text('Return Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/return-policy');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete My Data'),
              subtitle: const Text('GDPR data deletion request'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/gdpr-data-deletion');
              },
            ),
            const Divider(),

            // About Section
            _buildSectionHeader(context, 'About'),
            ListTile(
              leading: const Icon(Icons.info, color: AppTheme.primaryColor),
              title: const Text('About CraftConnect'),
              subtitle: const Text('Version 1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showAboutDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: AppTheme.primaryColor),
              title: const Text('Rate Us'),
              subtitle: const Text('Leave a rating on the app store'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Open app store rating
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback, color: AppTheme.primaryColor),
              title: const Text('Send Feedback'),
              subtitle: const Text('Share your thoughts and suggestions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Open feedback form
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: AppTheme.primaryColor),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help with the app'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Open help center
              },
            ),
            const Divider(),

            // Sign Out
            if (authProvider.isAuthenticated)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showSignOutDialog(context, authProvider),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'te':
        return 'తెలుగు';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              authProvider,
              'en',
              'English',
              'Language changed to English',
            ),
            _buildLanguageOption(
              context,
              authProvider,
              'hi',
              'हिंदी',
              'Language changed to Hindi',
            ),
            _buildLanguageOption(
              context,
              authProvider,
              'te',
              'তెలుగు',
              'Language changed to Telugu',
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'CraftConnect',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.handyman,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: const [
        Text(
          'CraftConnect is a platform for artisans to showcase and sell their handcrafted products.',
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    authProvider,
    String languageCode,
    String title,
    String announcement,
  ) {
    final isSelected = authProvider.currentLocale.languageCode == languageCode;
    return GestureDetector(
      onTap: () {
        authProvider.changeLocale(Locale(languageCode));
        Navigator.pop(context);
        AccessibilityHelper.announceMessage(context, announcement);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
