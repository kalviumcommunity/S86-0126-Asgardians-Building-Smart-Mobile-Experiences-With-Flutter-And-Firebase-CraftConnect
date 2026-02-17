import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/font_size_provider.dart';
import '../../utils/accessibility_helper.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return AccessibleWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings_title),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
              title: const Text('Font Size'),
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
                              'Text size decreased: ${fontSizeProvider.getFontSizeLabel()}',
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
                              'Text size increased: ${fontSizeProvider.getFontSizeLabel()}',
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
              title: Text(l10n.settings_profile),
              subtitle:
                  Text(authProvider.currentUser?.email ?? 'Not logged in'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/profile-edit');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.notifications, color: AppTheme.primaryColor),
              title: Text(l10n.settings_notifications),
              subtitle: const Text('Manage notification preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/notification-settings');
              },
            ),
            const Divider(),

            // Language Section
            _buildSectionHeader(context, 'Language & Region'),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primaryColor),
              title: Text(l10n.settings_language),
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
              title: Text(l10n.settings_about),
              subtitle: const Text('Version 1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showAboutDialog(context);
              },
            ),
            const Divider(),

            // Sign Out
            if (authProvider.isAuthenticated)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: OutlinedButton(
                  onPressed: () => _showSignOutDialog(context, authProvider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: Text(l10n.auth_logout),
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'te':
        return 'తెలుగు (Telugu)';
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
              'हिंदी (Hindi)',
              'भाषा हिंदी में बदल गई',
            ),
            _buildLanguageOption(
              context,
              authProvider,
              'te',
              'తెలుగు (Telugu)',
              'భాష తెలుగుకు మార్చబడింది',
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
          Icons.store,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: const [
        Padding(
          padding: EdgeInsets.only(top: AppSpacing.md),
          child:
              Text('CraftConnect is a digital storefront for local artisans.'),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.auth_logout),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.auth_logout),
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
