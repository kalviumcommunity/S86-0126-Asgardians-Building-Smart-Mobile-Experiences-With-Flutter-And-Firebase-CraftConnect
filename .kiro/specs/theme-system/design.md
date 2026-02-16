# Design Document: Theme System

## Overview

The theme system will provide a comprehensive, production-ready theming solution for the CraftConnect Flutter application. The design leverages Flutter's Material 3 design system, Provider state management, and SharedPreferences for persistence. The system will replace the existing basic ThemeState implementation with a robust solution that supports light, dark, and system theme modes with full persistence and dynamic switching capabilities.

The architecture follows the existing Provider patterns in the codebase (CounterState, FavoritesState, CartState) and integrates seamlessly with the current app structure. The design prioritizes user experience with immediate visual feedback, smooth transitions, and reliable persistence.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        MaterialApp                          │
│                    (Consumer<ThemeManager>)                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ observes
                         │
┌────────────────────────▼────────────────────────────────────┐
│                     ThemeManager                            │
│              (ChangeNotifier Provider)                      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ - ThemeMode (light/dark/system)                      │  │
│  │ - Material 3 ColorSchemes                            │  │
│  │ - ThemeData objects                                  │  │
│  │ - System brightness listener                         │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ uses
                         │
┌────────────────────────▼────────────────────────────────────┐
│              ThemePersistenceService                        │
│                 (SharedPreferences)                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ - saveThemeMode(ThemeMode)                           │  │
│  │ - loadThemeMode() -> ThemeMode                       │  │
│  │ - clearThemePreferences()                            │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

1. **App Initialization**: ThemeManager initializes, loads saved preferences via ThemePersistenceService
2. **Theme Application**: MaterialApp consumes ThemeManager and applies the appropriate ThemeData
3. **User Interaction**: User changes theme in Settings UI → ThemeManager updates state → notifies listeners
4. **Persistence**: ThemeManager saves new preference via ThemePersistenceService
5. **System Changes**: Device theme changes → ThemeManager detects via WidgetsBindingObserver → updates if in system mode

## Components and Interfaces

### 1. ThemeMode Enum

```dart
enum AppThemeMode {
  light,   // Always use light theme
  dark,    // Always use dark theme
  system   // Follow device system setting
}
```

### 2. ThemePersistenceService

**Purpose**: Handles saving and loading theme preferences using SharedPreferences.

**Interface**:
```dart
class ThemePersistenceService {
  static const String _themeModeKey = 'app_theme_mode';
  
  // Initialize SharedPreferences instance
  Future<void> initialize();
  
  // Save theme mode to persistent storage
  Future<bool> saveThemeMode(AppThemeMode mode);
  
  // Load theme mode from persistent storage
  // Returns null if no preference is saved
  Future<AppThemeMode?> loadThemeMode();
  
  // Clear all theme preferences
  Future<bool> clearThemePreferences();
}
```

**Implementation Details**:
- Uses SharedPreferences for local storage
- Stores theme mode as string enum value
- Handles initialization errors gracefully
- Returns default values on read failures
- Logs errors for debugging

### 3. ThemeManager

**Purpose**: Central state management for theme configuration, mode switching, and system theme detection.

**Interface**:
```dart
class ThemeManager extends ChangeNotifier with WidgetsBindingObserver {
  // Dependencies
  final ThemePersistenceService _persistenceService;
  
  // State
  AppThemeMode _themeMode;
  Brightness? _systemBrightness;
  bool _isInitialized;
  
  // Getters
  AppThemeMode get themeMode;
  ThemeData get lightTheme;
  ThemeData get darkTheme;
  ThemeData get currentTheme;
  bool get isInitialized;
  
  // Methods
  Future<void> initialize();
  Future<void> setThemeMode(AppThemeMode mode);
  ThemeData _buildLightTheme();
  ThemeData _buildDarkTheme();
  Brightness _getCurrentBrightness();
  
  // WidgetsBindingObserver
  @override
  void didChangePlatformBrightness();
}
```

**Implementation Details**:

**Initialization**:
- Loads saved theme preference from ThemePersistenceService
- Defaults to system mode if no preference exists
- Registers as WidgetsBindingObserver to listen for system brightness changes
- Sets _isInitialized flag when complete

**Theme Building**:
- Uses Material 3 ColorScheme.fromSeed() for consistent color generation
- Defines custom seed colors for light and dark themes
- Configures useMaterial3: true flag
- Sets up component themes (AppBar, Card, Button, etc.)
- Ensures proper contrast ratios

**Theme Mode Logic**:
```
getCurrentTheme():
  if themeMode == light:
    return lightTheme
  else if themeMode == dark:
    return darkTheme
  else if themeMode == system:
    if systemBrightness == dark:
      return darkTheme
    else:
      return lightTheme
```

**System Brightness Detection**:
- Implements WidgetsBindingObserver.didChangePlatformBrightness()
- Queries WidgetsBinding.instance.platformDispatcher.platformBrightness
- Only triggers updates when in system mode
- Notifies listeners on brightness changes

### 4. ThemeSettingsScreen (Enhanced)

**Purpose**: User interface for theme configuration with improved UX.

**Interface**:
```dart
class ThemeSettingsScreen extends StatelessWidget {
  // Displays current theme mode
  // Provides theme mode selection controls
  // Shows visual previews of each mode
  // Applies changes immediately
}
```

**UI Components**:
- **Header**: Title and description
- **Theme Mode Selector**: Segmented button or radio tiles for light/dark/system
- **Visual Indicators**: Icons showing current mode (sun/moon/auto)
- **Preview Cards**: Optional preview of how each theme looks
- **Info Section**: Explanation of system mode behavior

**Layout**:
```
┌─────────────────────────────────────┐
│  Theme Settings                     │
├─────────────────────────────────────┤
│                                     │
│  Choose Theme Mode                  │
│                                     │
│  ○ Light Mode      ☀️              │
│  ● Dark Mode       🌙              │
│  ○ System Default  ⚙️              │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ℹ️  System mode follows     │   │
│  │    your device settings     │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### 5. MaterialApp Integration

**Purpose**: Apply theme from ThemeManager to the entire application.

**Implementation**:
```dart
class CraftConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        // Show loading screen while theme initializes
        if (!themeManager.isInitialized) {
          return MaterialApp(
            home: SplashScreen(),
          );
        }
        
        return MaterialApp(
          theme: themeManager.lightTheme,
          darkTheme: themeManager.darkTheme,
          themeMode: _convertToFlutterThemeMode(themeManager.themeMode),
          // ... rest of MaterialApp configuration
        );
      },
    );
  }
  
  ThemeMode _convertToFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
```

## Data Models

### AppThemeMode Enum

```dart
enum AppThemeMode {
  light,
  dark,
  system;
  
  // Convert to string for persistence
  String toStorageString() {
    return name;
  }
  
  // Parse from storage string
  static AppThemeMode? fromStorageString(String? value) {
    if (value == null) return null;
    try {
      return AppThemeMode.values.firstWhere(
        (mode) => mode.name == value,
      );
    } catch (e) {
      return null;
    }
  }
}
```

### Theme Configuration Constants

```dart
class ThemeConfig {
  // Seed colors for Material 3 color scheme generation
  static const Color lightSeedColor = Color(0xFF006B5A); // Teal
  static const Color darkSeedColor = Color(0xFF4DB6AC);  // Light teal
  
  // SharedPreferences keys
  static const String themeModeKey = 'app_theme_mode';
  
  // Default values
  static const AppThemeMode defaultThemeMode = AppThemeMode.system;
  
  // Animation durations
  static const Duration themeTransitionDuration = Duration(milliseconds: 200);
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: ColorScheme Completeness

*For any* ThemeData object generated by ThemeManager (light or dark), the ColorScheme should have all required Material 3 semantic colors defined (primary, secondary, tertiary, surface, background, error, and their variants).

**Validates: Requirements 1.1, 1.2**

### Property 2: Theme Mode Determines Applied Theme

*For any* AppThemeMode value (light, dark, or system) and any system brightness setting, when the theme mode is set, the currentTheme returned should match the expected theme: light mode returns lightTheme, dark mode returns darkTheme, and system mode returns the theme matching the system brightness.

**Validates: Requirements 2.1, 2.2, 2.3, 10.1, 10.4, 10.5**

### Property 3: System Brightness Changes Trigger Updates

*For any* initial system brightness value, when ThemeManager is in system mode and the system brightness changes, the ThemeManager should notify listeners and update the current theme to match the new brightness.

**Validates: Requirements 2.4, 10.2**

### Property 4: Theme Mode Change Method Updates State

*For any* valid AppThemeMode value, calling setThemeMode should update the themeMode property to the new value and notify all listeners.

**Validates: Requirements 2.6, 4.1, 7.4**

### Property 5: Theme Changes Persist Immediately

*For any* AppThemeMode value, when setThemeMode is called, the new mode should be saved to persistent storage via ThemePersistenceService before the method completes.

**Validates: Requirements 3.1**

### Property 6: Persistence Round-Trip Consistency

*For any* valid AppThemeMode value, if it is saved to persistent storage and then loaded, the loaded value should equal the original saved value.

**Validates: Requirements 3.2, 9.2**

### Property 7: Theme Changes Preserve Unrelated State

*For any* application state (counter, favorites, cart, etc.) and any theme mode change, the unrelated application state should remain unchanged after the theme change completes.

**Validates: Requirements 4.5**

### Property 8: Contrast Ratios Meet Accessibility Standards

*For any* ThemeData object (light or dark) generated by ThemeManager, the contrast ratio between primary text color and background color should meet WCAG AA standards (minimum 4.5:1 for normal text).

**Validates: Requirements 6.5**

### Property 9: Input Validation Prevents Invalid States

*For any* input to ThemeManager methods, if the input is invalid (null, out of range, wrong type), the method should either reject the input or sanitize it to a valid value without entering an invalid state.

**Validates: Requirements 8.5**

### Property 10: Default Theme Used During Initialization

*For any* initialization state, before the saved preferences are loaded, the ThemeManager should return a valid default theme (system mode with appropriate brightness-based theme).

**Validates: Requirements 9.3**

### Property 11: Initialization Completion Notifies Listeners

*For any* initialization sequence, when the ThemeManager completes loading saved preferences, it should notify all listeners exactly once to trigger UI updates.

**Validates: Requirements 9.4**

## Error Handling

### Persistence Failures

**Scenario**: SharedPreferences initialization or read/write operations fail

**Handling Strategy**:
1. Log error with details for debugging
2. Continue with default theme mode (system)
3. Set internal flag indicating persistence is unavailable
4. Allow theme changes to work in-memory only
5. Do not crash or block user interaction

**Implementation**:
```dart
Future<void> _saveThemeMode(AppThemeMode mode) async {
  try {
    final success = await _persistenceService.saveThemeMode(mode);
    if (!success) {
      debugPrint('Failed to save theme mode: $mode');
    }
  } catch (e) {
    debugPrint('Error saving theme mode: $e');
    // Continue without persistence
  }
}
```

### Invalid Stored Data

**Scenario**: Corrupted or invalid theme mode value in SharedPreferences

**Handling Strategy**:
1. Detect invalid value during parsing
2. Log warning about corrupted data
3. Clear the invalid preference
4. Fall back to default (system mode)
5. Save the default to fix the corruption

**Implementation**:
```dart
Future<AppThemeMode> _loadThemeMode() async {
  try {
    final mode = await _persistenceService.loadThemeMode();
    if (mode == null) {
      return ThemeConfig.defaultThemeMode;
    }
    return mode;
  } catch (e) {
    debugPrint('Error loading theme mode: $e');
    await _persistenceService.clearThemePreferences();
    return ThemeConfig.defaultThemeMode;
  }
}
```

### System Brightness Detection Failure

**Scenario**: Unable to access system brightness (rare platform issue)

**Handling Strategy**:
1. Catch exception when accessing platformBrightness
2. Log error for debugging
3. Default to Brightness.light
4. Continue operating with fallback value

**Implementation**:
```dart
Brightness _getCurrentBrightness() {
  try {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  } catch (e) {
    debugPrint('Error getting system brightness: $e');
    return Brightness.light;
  }
}
```

### Initialization Timeout

**Scenario**: Persistence loading takes too long

**Handling Strategy**:
1. Set timeout for initialization (500ms)
2. If timeout occurs, proceed with defaults
3. Log timeout event
4. Mark as initialized to unblock UI
5. Continue attempting to load in background

## Testing Strategy

### Dual Testing Approach

The theme system will be validated using both unit tests and property-based tests:

**Unit Tests**: Focus on specific examples, edge cases, and error conditions
- Test specific theme mode transitions (light → dark, dark → system, etc.)
- Test error handling scenarios (persistence failures, invalid data)
- Test initialization with various starting states
- Test UI widget behavior in ThemeSettingsScreen
- Test integration points between components

**Property-Based Tests**: Verify universal properties across all inputs
- Test theme mode application across all possible modes and brightness values
- Test persistence round-trips with randomly generated theme modes
- Test state preservation across random theme changes
- Test contrast ratios for randomly generated color schemes
- Test input validation with randomly generated invalid inputs

Together, these approaches provide comprehensive coverage: unit tests catch concrete bugs in specific scenarios, while property tests verify general correctness across the input space.

### Property-Based Testing Configuration

**Framework**: Use the `test` package with custom property-based testing helpers (or a library like `check` if available for Dart)

**Configuration**:
- Minimum 100 iterations per property test
- Each property test references its design document property
- Tag format: **Feature: theme-system, Property {number}: {property_text}**

**Example Property Test Structure**:
```dart
test('Feature: theme-system, Property 2: Theme Mode Determines Applied Theme', () {
  // Run 100 iterations with different combinations
  for (var i = 0; i < 100; i++) {
    final mode = _randomThemeMode();
    final brightness = _randomBrightness();
    
    final themeManager = ThemeManager(mockPersistence);
    themeManager.setThemeMode(mode);
    
    final expectedTheme = _getExpectedTheme(mode, brightness);
    expect(themeManager.currentTheme, equals(expectedTheme));
  }
});
```

### Test Coverage Requirements

**ThemeManager**:
- All public methods must have unit tests
- All properties must have property-based tests
- Error handling paths must be tested
- Initialization sequence must be tested
- WidgetsBindingObserver callbacks must be tested

**ThemePersistenceService**:
- Save/load round-trip tests
- Error handling for SharedPreferences failures
- Invalid data handling tests
- Clear preferences functionality

**ThemeSettingsScreen**:
- Widget tests for UI rendering
- Interaction tests for theme mode selection
- Integration tests with ThemeManager

**MaterialApp Integration**:
- Integration tests verifying theme application
- Tests for theme switching without navigation
- Tests for initialization flow

### Testing Best Practices

1. **Mock SharedPreferences**: Use mock implementations for unit tests to avoid file system dependencies
2. **Test Isolation**: Each test should create fresh instances and not share state
3. **Async Handling**: Properly await all async operations in tests
4. **Platform Brightness Mocking**: Mock WidgetsBinding for testing system brightness changes
5. **Listener Verification**: Verify notifyListeners is called at appropriate times
6. **Performance Testing**: While not property tests, include performance benchmarks for initialization and switching

### Example Unit Test

```dart
group('ThemeManager', () {
  late ThemeManager themeManager;
  late MockThemePersistenceService mockPersistence;
  
  setUp(() {
    mockPersistence = MockThemePersistenceService();
    themeManager = ThemeManager(mockPersistence);
  });
  
  test('should default to system mode when no preference saved', () async {
    when(mockPersistence.loadThemeMode()).thenAnswer((_) async => null);
    
    await themeManager.initialize();
    
    expect(themeManager.themeMode, equals(AppThemeMode.system));
  });
  
  test('should save theme mode when changed', () async {
    await themeManager.setThemeMode(AppThemeMode.dark);
    
    verify(mockPersistence.saveThemeMode(AppThemeMode.dark)).called(1);
  });
  
  test('should notify listeners when theme mode changes', () {
    var notified = false;
    themeManager.addListener(() => notified = true);
    
    themeManager.setThemeMode(AppThemeMode.light);
    
    expect(notified, isTrue);
  });
});
```

## Implementation Notes

### Material 3 Migration

The existing ThemeState uses Material 2 with MaterialColor for primarySwatch. The new implementation will:
- Use Material 3 ColorScheme.fromSeed() instead of primarySwatch
- Set useMaterial3: true in ThemeData
- Remove primarySwatch (deprecated in Material 3)
- Use seedColor for consistent color generation

### Provider Pattern Consistency

The ThemeManager follows the same patterns as existing providers:
- Extends ChangeNotifier
- Uses private fields with public getters
- Calls notifyListeners() after state changes
- Provided at app root in MultiProvider
- Consumed via Consumer<T> or Provider.of<T>

### Backward Compatibility

The new ThemeManager replaces the existing ThemeState. Migration steps:
1. Rename ThemeState to ThemeManager
2. Add ThemePersistenceService dependency
3. Add initialization logic
4. Update MaterialApp to use new theme properties
5. Update ThemeSettingsScreen to use new API
6. Remove old color picker functionality (replaced with theme modes)

### Performance Considerations

- **Initialization**: Async loading prevents blocking the UI thread
- **Theme Switching**: Lightweight operation, only notifies listeners
- **Persistence**: Async saves don't block theme changes
- **System Brightness**: Observer pattern minimizes overhead
- **Memory**: Single ThemeData instances reused, not recreated on every access

### Platform Considerations

- **iOS**: System brightness detection works via PlatformDispatcher
- **Android**: System brightness detection works via PlatformDispatcher
- **Web**: System brightness detection supported in modern browsers
- **Desktop**: System brightness detection supported on macOS, Windows, Linux

All platforms support SharedPreferences through the shared_preferences package.
