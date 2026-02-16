import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/theme_settings_screen.dart';

/// A compact theme toggle widget that can be embedded in app bars or settings
/// Provides quick theme switching with visual feedback
class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final bool compactMode;

  const ThemeToggleWidget({
    super.key,
    this.showLabel = true,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (compactMode) {
          return _buildCompactToggle(context, themeProvider);
        } else {
          return _buildFullToggle(context, themeProvider);
        }
      },
    );
  }

  /// Full theme toggle with label and description
  Widget _buildFullToggle(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(
                themeProvider.currentThemeIcon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLabel) ...[
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      themeProvider.currentThemeName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              _buildThemeSwitch(context, themeProvider),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => _showThemeOptions(context),
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('More Options'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              Text(
                themeProvider.currentThemeDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Compact theme toggle for app bars or tight spaces
  Widget _buildCompactToggle(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showQuickThemeMenu(context, themeProvider),
          icon: Icon(themeProvider.currentThemeIcon),
          tooltip: 'Theme: ${themeProvider.currentThemeName}',
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            themeProvider.currentThemeName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  /// Theme switch widget (for non-system modes only)
  Widget _buildThemeSwitch(BuildContext context, ThemeProvider themeProvider) {
    if (themeProvider.isSystem) {
      return TextButton(
        onPressed: () => _showThemeOptions(context),
        child: const Text('Auto'),
      );
    }

    return Switch(
      value: themeProvider.isDark,
      onChanged: (isDark) => themeProvider.toggleTheme(isDark),
      activeThumbImage: null,
      inactiveThumbImage: null,
    );
  }

  /// Show quick theme selection menu
  void _showQuickThemeMenu(BuildContext context, ThemeProvider themeProvider) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<ThemeMode>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: ThemeMode.system,
          child: ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text('System'),
            subtitle: const Text('Follow device setting'),
            trailing: themeProvider.isSystem ? const Icon(Icons.check) : null,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('Light'),
            subtitle: const Text('Bright theme'),
            trailing: themeProvider.isLight ? const Icon(Icons.check) : null,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark'),
            subtitle: const Text('Dark theme'),
            trailing: themeProvider.isDark ? const Icon(Icons.check) : null,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<ThemeMode>(
          value: null, // Special case for settings
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Theme Settings'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    ).then((selectedMode) {
      if (selectedMode == null) {
        // Navigate to theme settings
        _showThemeOptions(context);
      } else {
        themeProvider.setThemeMode(selectedMode);
      }
    });
  }

  /// Navigate to full theme settings screen
  void _showThemeOptions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()),
    );
  }
}

/// A simple theme toggle button for app bars
class AppBarThemeToggle extends StatelessWidget {
  const AppBarThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          onPressed: () {
            // Cycle through themes: System -> Light -> Dark -> System
            if (themeProvider.isSystem) {
              themeProvider.setLightTheme();
            } else if (themeProvider.isLight) {
              themeProvider.setDarkTheme();
            } else {
              themeProvider.setSystemTheme();
            }
          },
          icon: Icon(themeProvider.currentThemeIcon),
          tooltip: 'Switch Theme (Current: ${themeProvider.currentThemeName})',
        );
      },
    );
  }
}

/// Floating action button for theme switching
class ThemeToggleFAB extends StatelessWidget {
  final bool mini;

  const ThemeToggleFAB({super.key, this.mini = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return FloatingActionButton(
          onPressed: () => themeProvider.toggleTheme(!themeProvider.isDark),
          tooltip: themeProvider.isDark
              ? 'Switch to Light Theme'
              : 'Switch to Dark Theme',
          mini: mini,
          child: Icon(
            themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
          ),
        );
      },
    );
  }
}

/// Theme indicator chip widget
class ThemeIndicatorChip extends StatelessWidget {
  const ThemeIndicatorChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ActionChip(
          avatar: Icon(themeProvider.currentThemeIcon, size: 18),
          label: Text(themeProvider.currentThemeName),
          onPressed: () => _showQuickSettings(context),
        );
      },
    );
  }

  void _showQuickSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()),
    );
  }
}
