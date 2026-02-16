import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Theme settings screen allowing users to customize their theme preferences
/// Provides options for theme mode, dynamic colors, and theme preview
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings'), elevation: 0),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current theme info card
              _buildCurrentThemeCard(context, themeProvider),
              const SizedBox(height: 16),

              // Theme mode selection
              _buildThemeModeSection(context, themeProvider),
              const SizedBox(height: 24),

              // Dynamic color settings
              _buildDynamicColorSection(context, themeProvider),
              const SizedBox(height: 24),

              // Theme preview section
              _buildThemePreviewSection(context),
              const SizedBox(height: 24),

              // Reset button
              _buildResetSection(context, themeProvider),
            ],
          );
        },
      ),
    );
  }

  /// Current theme information card
  Widget _buildCurrentThemeCard(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(
                themeProvider.currentThemeIcon,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Theme', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      themeProvider.currentThemeName,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      themeProvider.currentThemeDescription,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColorPreview('Primary', colorScheme.primary),
              _buildColorPreview('Secondary', colorScheme.secondary),
              _buildColorPreview('Surface', colorScheme.surface),
            ],
          ),
        ],
      ),
    );
  }

  /// Color preview widget
  Widget _buildColorPreview(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// Theme mode selection section
  Widget _buildThemeModeSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme Mode', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Choose how the app should display colors',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        // Theme mode options
        _buildThemeModeOption(
          context,
          themeProvider,
          ThemeMode.system,
          'System',
          'Follow device setting',
          Icons.brightness_auto,
        ),
        _buildThemeModeOption(
          context,
          themeProvider,
          ThemeMode.light,
          'Light',
          'Bright theme for daytime',
          Icons.light_mode,
        ),
        _buildThemeModeOption(
          context,
          themeProvider,
          ThemeMode.dark,
          'Dark',
          'Dark theme for low light',
          Icons.dark_mode,
        ),
      ],
    );
  }

  /// Individual theme mode option
  Widget _buildThemeModeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = themeProvider.isCurrentTheme(mode);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? colorScheme.primaryContainer : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? colorScheme.onPrimaryContainer : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : null,
            color: isSelected ? colorScheme.onPrimaryContainer : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimaryContainer : null,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: colorScheme.primary)
            : null,
        onTap: () => themeProvider.setThemeMode(mode),
      ),
    );
  }

  /// Dynamic color settings section
  Widget _buildDynamicColorSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dynamic Colors', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Use colors from your wallpaper (Android 12+)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        Card(
          child: SwitchListTile(
            title: const Text('Enable Dynamic Colors'),
            subtitle: const Text('Adapts colors to your device wallpaper'),
            value: themeProvider.isDynamicColorEnabled,
            onChanged: themeProvider.setDynamicColorEnabled,
            secondary: const Icon(Icons.palette),
          ),
        ),
      ],
    );
  }

  /// Theme preview section
  Widget _buildThemePreviewSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme Preview', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'See how your selected theme looks',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Primary Button'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outlined'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Text')),
                ],
              ),
              const SizedBox(height: 16),

              // Sample list tiles
              Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      'Sample List Item',
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      'This is how list items will look',
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.settings, color: colorScheme.primary),
                    title: Text('Settings', style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      'Configure app preferences',
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Reset section
  Widget _buildResetSection(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reset Theme', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Restore default theme settings',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showResetDialog(context, themeProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Reset to System Default'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }

  /// Show reset confirmation dialog
  void _showResetDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Theme Settings'),
        content: const Text(
          'This will reset all theme preferences to their default values. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              themeProvider.resetToDefault();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme settings reset to default'),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
