# Implementation Plan: Theme System

## Overview

This implementation plan breaks down the theme system feature into discrete, incremental coding tasks. Each task builds on previous work, with testing integrated throughout to catch issues early. The plan follows the existing Provider patterns in the codebase and ensures smooth integration with the current app structure.

## Tasks

- [ ] 1. Create core theme infrastructure and models
  - Create `lib/models/app_theme_mode.dart` with enum and conversion methods
  - Create `lib/config/theme_config.dart` with constants and seed colors
  - Add `shared_preferences` dependency to `pubspec.yaml`
  - _Requirements: 1.1, 1.2, 1.4, 3.4_

- [ ] 2. Implement ThemePersistenceService
  - [ ] 2.1 Create `lib/services/theme_persistence_service.dart`
    - Implement SharedPreferences initialization
    - Implement saveThemeMode method
    - Implement loadThemeMode method with error handling
    - Implement clearThemePreferences method
    - _Requirements: 3.1, 3.2, 3.4, 8.1, 8.2, 8.3_
  
  - [ ]* 2.2 Write property test for persistence round-trip
    - **Property 6: Persistence Round-Trip Consistency**
    - **Validates: Requirements 3.2, 9.2**
  
  - [ ]* 2.3 Write unit tests for ThemePersistenceService
    - Test save and load operations
    - Test error handling for SharedPreferences failures
    - Test invalid data handling
    - Test clear functionality
    - _Requirements: 3.1, 3.2, 8.1, 8.2, 8.3, 8.4_

- [ ] 3. Build Material 3 theme definitions
  - [ ] 3.1 Create theme builder methods in ThemeManager
    - Implement _buildLightTheme() with Material 3 ColorScheme
    - Implement _buildDarkTheme() with Material 3 ColorScheme
    - Configure component themes (AppBar, Card, Button, etc.)
    - Set useMaterial3: true flag
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_
  
  - [ ]* 3.2 Write property test for ColorScheme completeness
    - **Property 1: ColorScheme Completeness**
    - **Validates: Requirements 1.1, 1.2**
  
  - [ ]* 3.3 Write property test for contrast ratios
    - **Property 8: Contrast Ratios Meet Accessibility Standards**
    - **Validates: Requirements 6.5**
  
  - [ ]* 3.4 Write unit tests for theme generation
    - Test Material 3 flag is set
    - Test typography configuration
    - Test component themes are configured
    - _Requirements: 1.3, 1.5, 1.6_

- [ ] 4. Implement ThemeManager core functionality
  - [ ] 4.1 Create `lib/providers/theme_manager.dart` replacing theme_state.dart
    - Extend ChangeNotifier and implement WidgetsBindingObserver
    - Add ThemePersistenceService dependency
    - Implement state fields (themeMode, systemBrightness, isInitialized)
    - Implement getters (themeMode, lightTheme, darkTheme, currentTheme, isInitialized)
    - _Requirements: 2.5, 7.1, 7.4, 9.3_
  
  - [ ] 4.2 Implement theme mode logic
    - Implement setThemeMode method with persistence and notification
    - Implement currentTheme getter with mode-based logic
    - Implement _getCurrentBrightness helper with error handling
    - _Requirements: 2.1, 2.2, 2.3, 2.6, 10.1, 10.4, 10.5_
  
  - [ ] 4.3 Implement system brightness detection
    - Implement didChangePlatformBrightness callback
    - Register/unregister as WidgetsBindingObserver
    - Add logic to update theme only in system mode
    - _Requirements: 2.4, 10.2_
  
  - [ ]* 4.4 Write property test for theme mode application
    - **Property 2: Theme Mode Determines Applied Theme**
    - **Validates: Requirements 2.1, 2.2, 2.3, 10.1, 10.4, 10.5**
  
  - [ ]* 4.5 Write property test for system brightness reactivity
    - **Property 3: System Brightness Changes Trigger Updates**
    - **Validates: Requirements 2.4, 10.2**
  
  - [ ]* 4.6 Write property test for theme mode change method
    - **Property 4: Theme Mode Change Method Updates State**
    - **Validates: Requirements 2.6, 4.1, 7.4**

- [ ] 5. Checkpoint - Ensure core theme logic works
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Implement ThemeManager initialization
  - [ ] 6.1 Add initialization logic to ThemeManager
    - Implement initialize() method with async preference loading
    - Set default theme before loading completes
    - Handle initialization errors gracefully
    - Notify listeners after initialization
    - _Requirements: 3.2, 3.3, 8.1, 8.2, 9.1, 9.2, 9.3, 9.4_
  
  - [ ]* 6.2 Write property test for default theme during initialization
    - **Property 10: Default Theme Used During Initialization**
    - **Validates: Requirements 9.3**
  
  - [ ]* 6.3 Write property test for initialization notification
    - **Property 11: Initialization Completion Notifies Listeners**
    - **Validates: Requirements 9.4**
  
  - [ ]* 6.4 Write unit tests for initialization
    - Test initialization with saved preferences
    - Test initialization without saved preferences (default)
    - Test initialization error handling
    - Test isInitialized flag behavior
    - _Requirements: 3.2, 3.3, 8.1, 8.2, 9.1, 9.2, 9.3, 9.4_

- [ ] 7. Implement error handling and validation
  - [ ] 7.1 Add error handling throughout ThemeManager
    - Add try-catch blocks for persistence operations
    - Add error logging for debugging
    - Add graceful fallbacks for all error scenarios
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_
  
  - [ ]* 7.2 Write property test for input validation
    - **Property 9: Input Validation Prevents Invalid States**
    - **Validates: Requirements 8.5**
  
  - [ ]* 7.3 Write unit tests for error scenarios
    - Test SharedPreferences initialization failure
    - Test load failure handling
    - Test save failure handling
    - Test invalid stored data handling
    - Test system brightness detection failure
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [ ] 8. Update MaterialApp integration
  - [ ] 8.1 Update main.dart to use ThemeManager
    - Replace ThemeState with ThemeManager in MultiProvider
    - Initialize ThemeManager before MaterialApp builds
    - Update Consumer to use ThemeManager
    - Use MaterialApp's theme, darkTheme, and themeMode properties
    - Show SplashScreen while theme initializes
    - _Requirements: 2.1, 2.2, 2.3, 4.2, 7.2, 9.1_
  
  - [ ]* 8.2 Write integration test for MaterialApp theme application
    - Test that theme changes propagate to MaterialApp
    - Test initialization flow with MaterialApp
    - _Requirements: 4.2, 6.1, 9.1_

- [ ] 9. Checkpoint - Ensure integration works
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Implement enhanced ThemeSettingsScreen
  - [ ] 10.1 Update `lib/screens/theme_settings_screen.dart`
    - Replace dark mode toggle with theme mode selector
    - Add radio buttons or segmented control for light/dark/system
    - Add icons for each theme mode (sun/moon/auto)
    - Add info card explaining system mode
    - Remove color picker functionality (replaced by theme modes)
    - Update to consume ThemeManager instead of ThemeState
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_
  
  - [ ]* 10.2 Write widget tests for ThemeSettingsScreen
    - Test that current theme mode is displayed correctly
    - Test that selecting a mode calls ThemeManager.setThemeMode
    - Test visual feedback for selected mode
    - _Requirements: 5.1, 5.2, 5.3, 5.6_

- [ ] 11. Add state preservation testing
  - [ ]* 11.1 Write property test for state preservation
    - **Property 7: Theme Changes Preserve Unrelated State**
    - **Validates: Requirements 4.5**

- [ ] 12. Verify theme application across existing screens
  - [ ] 12.1 Test theme on all existing screens
    - Manually verify home_screen.dart uses themed colors
    - Manually verify auth_screen.dart uses themed colors
    - Manually verify provider demo screens use themed colors
    - Manually verify all other screens use themed colors
    - Fix any hardcoded colors that don't respect theme
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 12.2 Update any screens with hardcoded colors
    - Replace hardcoded colors with Theme.of(context) colors
    - Ensure proper contrast in both light and dark themes
    - _Requirements: 6.2, 6.5_

- [ ] 13. Final checkpoint and cleanup
  - [ ] 13.1 Remove old theme_state.dart file
    - Delete `lib/providers/theme_state.dart`
    - Verify no imports reference the old file
  
  - [ ] 13.2 Run all tests and verify functionality
    - Run all unit tests
    - Run all property tests
    - Run all widget tests
    - Manually test theme switching in the app
    - Manually test theme persistence (close and reopen app)
    - Manually test system mode following device settings
  
  - [ ] 13.3 Final verification
    - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional testing tasks and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation throughout implementation
- Property tests validate universal correctness properties with 100+ iterations
- Unit tests validate specific examples, edge cases, and error conditions
- The implementation follows existing Provider patterns in the codebase
- Material 3 migration removes deprecated Material 2 APIs (primarySwatch)
- Theme persistence uses SharedPreferences for cross-platform compatibility
