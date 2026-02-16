# 🎨 CraftConnect Theming System

A comprehensive theming solution for Flutter applications supporting light/dark modes, dynamic colors (Material You), and theme persistence.

## 🌟 Features

- ✅ **Light & Dark Themes** - Custom designed themes with proper contrast ratios
- ✅ **System Theme Support** - Automatically follows device preferences  
- ✅ **Dynamic Colors** - Material You support for Android 12+ devices
- ✅ **Theme Persistence** - Remembers user's theme choice using SharedPreferences
- ✅ **Real-time Theme Switching** - Instant theme updates across the entire app
- ✅ **Accessibility** - Proper color contrast and accessibility features
- ✅ **Customizable** - Easy to modify colors and styling

## 🏗️ Architecture

```
lib/
├── providers/
│   └── theme_provider.dart          # Theme state management
├── services/
│   └── theme_service.dart           # Theme persistence service
├── theme/
│   ├── light_theme.dart            # Light theme configuration
│   └── dark_theme.dart             # Dark theme configuration
├── screens/
│   └── theme_settings_screen.dart   # Theme settings UI
├── widgets/
│   └── theme_toggle_widget.dart     # Theme toggle components
└── main.dart                        # App entry point
```

## 🚀 Quick Start

### 1. Dependencies

The theming system uses these packages (already added to `pubspec.yaml`):

```yaml
dependencies:
  provider: ^6.1.2
  shared_preferences: ^2.3.2
  dynamic_color: ^1.7.0
```

### 2. Basic Usage

The theming system is already integrated into the main app. Users can:

- **Toggle themes** using the theme button in the app bar
- **Access full theme settings** via "Theme Settings" button on home screen
- **Choose from three modes**: System (auto), Light, Dark

### 3. Theme Modes

```dart
// Available theme modes
ThemeMode.system  // Follows device setting (default)
ThemeMode.light   // Always light theme
ThemeMode.dark    // Always dark theme
```

## 🎯 Usage Examples

### Quick Theme Toggle

```dart
// Simple theme toggle button for app bars
AppBarThemeToggle()

// Floating action button for theme switching  
ThemeToggleFAB()

// Compact toggle widget
ThemeToggleWidget(compactMode: true)

// Full theme widget with description
ThemeToggleWidget(showLabel: true)
```

### Programmatic Theme Control

```dart
// Access theme provider
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

// Set specific theme
await themeProvider.setLightTheme();
await themeProvider.setDarkTheme(); 
await themeProvider.setSystemTheme();

// Toggle between light/dark
await themeProvider.toggleTheme(true); // Set to dark
await themeProvider.toggleTheme(false); // Set to light

// Enable/disable dynamic colors
await themeProvider.setDynamicColorEnabled(true);
```

### Reading Theme State

```dart
// Check current theme mode
if (themeProvider.isDark) {
  // App is using dark theme
}

if (themeProvider.isLight) {
  // App is using light theme  
}

if (themeProvider.isSystem) {
  // App follows system preference
}

// Get theme information
String themeName = themeProvider.currentThemeName;        // "Light", "Dark", "System"
String description = themeProvider.currentThemeDescription;
IconData icon = themeProvider.currentThemeIcon;
```

## 🎨 Customizing Themes

### Modify Light Theme

Edit [`lib/theme/light_theme.dart`](lib/theme/light_theme.dart):

```dart
static const Color _primaryColor = Color(0xFF00897B); // Change primary color
static const Color _secondaryColor = Color(0xFF66BB6A); // Change secondary color
static const Color _backgroundColor = Color(0xFFF8F8F8); // Change background
```

### Modify Dark Theme

Edit [`lib/theme/dark_theme.dart`](lib/theme/dark_theme.dart):

```dart
static const Color _primaryColor = Color(0xFF4DB6AC); // Lighter teal for dark mode
static const Color _secondaryColor = Color(0xFF81C784); // Light green
static const Color _backgroundColor = Color(0xFF121212); // Material dark background
```

### Theme Components

Both themes customize:
- **AppBar** styling and colors
- **Button** styles (Elevated, Outlined, Text)
- **Input** field appearance
- **Card** elevation and colors
- **Navigation** bar styling
- **Text** styles and hierarchy
- **Colors** for all UI elements

## 🔧 Components

### ThemeProvider

Central theme state management:

```dart
class ThemeProvider with ChangeNotifier {
  // Theme mode management
  ThemeMode get themeMode;
  Future<void> setThemeMode(ThemeMode mode);
  Future<void> toggleTheme(bool isDark);
  
  // Dynamic colors
  bool get isDynamicColorEnabled;
  Future<void> setDynamicColorEnabled(bool enabled);
  
  // Convenience methods  
  Future<void> setLightTheme();
  Future<void> setDarkTheme();
  Future<void> setSystemTheme();
  Future<void> resetToDefault();
}
```

### ThemeService

Handles persistence with SharedPreferences:

```dart
class ThemeService {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Future<bool> isDynamicColorEnabled();
  Future<void> setDynamicColorEnabled(bool enabled);
  Future<void> clearThemePreferences();
}
```

### Theme Toggle Widgets

Ready-to-use UI components:

```dart
AppBarThemeToggle()           // Simple app bar button
ThemeToggleFAB()             // Floating action button  
ThemeToggleWidget()          // Full-featured toggle
ThemeIndicatorChip()         // Compact chip indicator
```

## 📱 User Experience

### Theme Settings Screen

Full-featured theme configuration:
- **Visual theme preview** with live examples
- **Theme mode selection** with descriptions
- **Dynamic colors toggle** for Material You
- **Color scheme preview** showing current colors
- **Reset to defaults** option

Access via: Home Screen → "Theme Settings" button

### Quick Theme Toggle

Fast theme switching via:
- **App bar button** - Cycles through System → Light → Dark
- **Quick menu** - Dropdown with all options + settings link
- **Settings screen** - Full configuration interface

### Theme Persistence

- Automatically saves user's theme preference
- Restores saved theme on app restart
- Handles migration from old theme systems
- Graceful fallbacks if persistence fails

## 🛠️ Development Notes

### Best Practices

1. **Use theme colors** instead of hardcoded colors:
   ```dart
   // ✅ Good - uses theme colors
   color: Theme.of(context).colorScheme.primary
   
   // ❌ Bad - hardcoded color
   color: Colors.blue
   ```

2. **Access theme provider properly**:
   ```dart
   // ✅ For reading only (rebuilds on changes)
   context.watch<ThemeProvider>()
   
   // ✅ For actions only (no rebuilds)  
   context.read<ThemeProvider>()
   
   // ✅ Traditional approach
   Provider.of<ThemeProvider>(context)
   ```

3. **Handle theme initialization**:
   ```dart
   // Theme provider initializes automatically
   // No manual setup required in most cases
   ```

### Material You Support

Dynamic colors automatically adapt the theme to:
- User's wallpaper colors
- System color palette preferences  
- Material You design guidelines

Fallback to custom themes when:
- Device doesn't support dynamic colors
- User disables dynamic colors
- Dynamic colors unavailable

### Performance Considerations

- Theme changes rebuild the entire MaterialApp tree
- State preservation during theme switches
- Minimal impact on app performance
- Efficient SharedPreferences usage

## 🎯 Integration Examples

### Adding Theme Toggle to Any Screen

```dart
import '../widgets/theme_toggle_widget.dart';

// In your AppBar actions
actions: [
  AppBarThemeToggle(),
  // other actions...
]

// Or in your body
body: Column(
  children: [
    ThemeToggleWidget(),
    // other widgets...
  ],
)
```

### Custom Theme-Aware Widgets

```dart
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  
  return Container(
    color: theme.colorScheme.surface,
    child: Text(
      'Theme-aware text',
      style: TextStyle(
        color: theme.colorScheme.onSurface,
      ),
    ),
  );
}
```

### Listening to Theme Changes

```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return Text('Current theme: ${themeProvider.currentThemeName}');
  },
)
```

## 📖 Additional Resources

- [Flutter Theming Documentation](https://docs.flutter.dev/ui/themes)
- [Material Design 3 Guidelines](https://m3.material.io/)
- [Dynamic Color Package](https://pub.dev/packages/dynamic_color)
- [Provider State Management](https://pub.dev/packages/provider)
- [SharedPreferences Package](https://pub.dev/packages/shared_preferences)

## 🤝 Contributing

When modifying the theming system:

1. **Test both themes** - Ensure changes work in light and dark modes
2. **Check accessibility** - Verify proper contrast ratios
3. **Test persistence** - Confirm settings save and restore correctly  
4. **Update documentation** - Keep this README current
5. **Consider edge cases** - Handle missing preferences, initialization errors

---

*Built with ❤️ for CraftConnect - Enhancing user experience through thoughtful theming*