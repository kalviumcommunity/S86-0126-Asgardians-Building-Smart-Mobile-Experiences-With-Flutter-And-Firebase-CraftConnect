import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_state.dart';

/// Theme settings screen
/// Demonstrates app-wide theme state management
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: Consumer<ThemeState>(
        builder: (context, themeState, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: themeState.isDarkMode,
                  onChanged: (value) {
                    themeState.toggleTheme();
                  },
                  secondary: Icon(
                    themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Primary Color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ColorOption(
                    color: Colors.teal,
                    isSelected: themeState.primaryColor == Colors.teal,
                    onTap: () => themeState.setPrimaryColor(Colors.teal),
                  ),
                  _ColorOption(
                    color: Colors.blue,
                    isSelected: themeState.primaryColor == Colors.blue,
                    onTap: () => themeState.setPrimaryColor(Colors.blue),
                  ),
                  _ColorOption(
                    color: Colors.purple,
                    isSelected: themeState.primaryColor == Colors.purple,
                    onTap: () => themeState.setPrimaryColor(Colors.purple),
                  ),
                  _ColorOption(
                    color: Colors.green,
                    isSelected: themeState.primaryColor == Colors.green,
                    onTap: () => themeState.setPrimaryColor(Colors.green),
                  ),
                  _ColorOption(
                    color: Colors.orange,
                    isSelected: themeState.primaryColor == Colors.orange,
                    onTap: () => themeState.setPrimaryColor(Colors.orange),
                  ),
                  _ColorOption(
                    color: Colors.red,
                    isSelected: themeState.primaryColor == Colors.red,
                    onTap: () => themeState.setPrimaryColor(Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Theme State',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'This screen demonstrates global theme management using Provider. '
                        'Changes made here affect the entire app immediately, including the '
                        'AppBar, background colors, and all other themed widgets.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 30,
              )
            : null,
      ),
    );
  }
}
