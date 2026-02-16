import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_toggle_widget.dart';

/// Example screen demonstrating how to properly use the theming system
/// Shows best practices for creating theme-aware widgets and components
class ThemeExampleScreen extends StatelessWidget {
  const ThemeExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Examples'),
        actions: const [AppBarThemeToggle()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme toggle widget example
          _buildThemeToggleSection(),
          const SizedBox(height: 24),

          // Color usage examples
          _buildColorExampleSection(context),
          const SizedBox(height: 24),

          // Typography examples
          _buildTypographySection(context),
          const SizedBox(height: 24),

          // Component examples
          _buildComponentExamples(context),
          const SizedBox(height: 24),

          // Theme-aware custom widget
          _buildCustomWidgetExample(context),
          const SizedBox(height: 24),

          // Provider usage example
          _buildProviderExample(),
        ],
      ),
      floatingActionButton: const ThemeToggleFAB(),
    );
  }

  /// Theme toggle widget examples
  Widget _buildThemeToggleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Theme Toggle Widgets',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Full theme toggle widget
        const ThemeToggleWidget(),
        const SizedBox(height: 12),

        // Compact theme toggle
        const ThemeToggleWidget(compactMode: true),
        const SizedBox(height: 12),

        // Theme indicator chip
        const ThemeIndicatorChip(),
      ],
    );
  }

  /// Color usage examples showing proper theme integration
  Widget _buildColorExampleSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme Colors Usage', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Color Examples', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),

              // Color swatches showing proper usage
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildColorSwatch('Primary', colorScheme.primary),
                  _buildColorSwatch('Secondary', colorScheme.secondary),
                  _buildColorSwatch('Surface', colorScheme.surface),
                  _buildColorSwatch('Error', colorScheme.error),
                  _buildColorSwatch('Outline', colorScheme.outline),
                ],
              ),
              const SizedBox(height: 12),

              // Example of theme-aware text colors
              Text(
                'Primary text color',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              Text(
                'Secondary text color',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              Text(
                'Disabled text color',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.38),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Typography examples using theme text styles
  Widget _buildTypographySection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Typography Examples', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Headline Large', style: theme.textTheme.headlineLarge),
              Text('Headline Medium', style: theme.textTheme.headlineMedium),
              Text('Title Large', style: theme.textTheme.titleLarge),
              Text('Title Medium', style: theme.textTheme.titleMedium),
              Text('Body Large', style: theme.textTheme.bodyLarge),
              Text('Body Medium', style: theme.textTheme.bodyMedium),
              Text('Label Large', style: theme.textTheme.labelLarge),
              Text('Label Small', style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ],
    );
  }

  /// Component examples showing themed widgets
  Widget _buildComponentExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Component Examples',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),

        // Buttons
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Buttons', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Elevated'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outlined'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Text')),
                  FilledButton(onPressed: () {}, child: const Text('Filled')),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Input fields
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Input Fields',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              const TextField(
                decoration: InputDecoration(
                  labelText: 'Label',
                  hintText: 'Enter text here',
                ),
              ),
              const SizedBox(height: 12),

              const TextField(
                decoration: InputDecoration(
                  labelText: 'With Icon',
                  prefixIcon: Icon(Icons.email),
                  suffixIcon: Icon(Icons.visibility),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Switches and checkboxes
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Selection Controls',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text('Enable notifications'),
                value: true,
                onChanged: (value) {},
              ),

              CheckboxListTile(
                title: const Text('Accept terms'),
                value: true,
                onChanged: (value) {},
              ),

              RadioListTile<bool>(
                title: const Text('Option A'),
                value: true,
                groupValue: true,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Custom theme-aware widget example
  Widget _buildCustomWidgetExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Theme-Aware Widget',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),

        const CustomThemeAwareWidget(),
      ],
    );
  }

  /// Provider usage example
  Widget _buildProviderExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Provider Usage Example',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Theme Information',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),

                      _buildInfoRow(
                        'Theme Mode:',
                        themeProvider.currentThemeName,
                      ),
                      _buildInfoRow(
                        'Description:',
                        themeProvider.currentThemeDescription,
                      ),
                      _buildInfoRow(
                        'Is Dark:',
                        themeProvider.isDark.toString(),
                      ),
                      _buildInfoRow(
                        'Is Light:',
                        themeProvider.isLight.toString(),
                      ),
                      _buildInfoRow(
                        'Is System:',
                        themeProvider.isSystem.toString(),
                      ),
                      _buildInfoRow(
                        'Dynamic Color:',
                        themeProvider.isDynamicColorEnabled.toString(),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        onPressed: () =>
                            themeProvider.toggleTheme(!themeProvider.isDark),
                        child: Text(
                          themeProvider.isDark
                              ? 'Switch to Light Theme'
                              : 'Switch to Dark Theme',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper method to build color swatch
  Widget _buildColorSwatch(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        Text(
          label,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Helper method to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// Example of a custom theme-aware widget
/// Demonstrates how to create widgets that adapt to theme changes
class CustomThemeAwareWidget extends StatelessWidget {
  const CustomThemeAwareWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 8 : 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.primaryContainer.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Theme-Aware Widget',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'This widget automatically adapts its appearance based on the current theme. '
              'It uses theme colors, adjusts elevation for dark mode, and changes icons accordingly.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Current theme: ${isDark ? "Dark" : "Light"}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Best Practices for Theme-Aware Widgets:
/// 
/// 1. Always use Theme.of(context) to get current theme
/// 2. Use colorScheme colors instead of hardcoded colors
/// 3. Consider brightness for conditional styling
/// 4. Test in both light and dark modes
/// 5. Use theme text styles for consistency
/// 6. Handle theme changes gracefully
/// 7. Consider accessibility and contrast ratios