# Provider State Management - Quick Reference

## 🚀 Quick Start

### 1. Add Dependency
```yaml
dependencies:
  provider: ^6.1.2
```

### 2. Create State Class
```dart
import 'package:flutter/foundation.dart';

class CounterState with ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners(); // ⚠️ Don't forget this!
  }
}
```

### 3. Register Provider
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CounterState(),
      child: MyApp(),
    ),
  );
}
```

### 4. Use in UI

#### Read (No Rebuild)
```dart
// Use when calling methods only
context.read<CounterState>().increment();
```

#### Watch (Auto Rebuild)
```dart
// Widget rebuilds when state changes
final count = context.watch<CounterState>().count;
Text('$count');
```

#### Consumer (Selective Rebuild)
```dart
// Only this widget rebuilds
Consumer<CounterState>(
  builder: (context, counter, child) {
    return Text('${counter.count}');
  },
)
```

## 📋 Common Patterns

### Pattern: Toggle State
```dart
// Provider
class ThemeState with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  
  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

// UI
Switch(
  value: context.watch<ThemeState>().isDark,
  onChanged: (_) => context.read<ThemeState>().toggle(),
)
```

### Pattern: List Management
```dart
// Provider
class FavoritesState with ChangeNotifier {
  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);
  
  void add(String item) {
    _items.add(item);
    notifyListeners();
  }
  
  void remove(String item) {
    _items.remove(item);
    notifyListeners();
  }
}

// UI
ListView.builder(
  itemCount: context.watch<FavoritesState>().items.length,
  itemBuilder: (context, index) {
    final item = context.watch<FavoritesState>().items[index];
    return ListTile(title: Text(item));
  },
)
```

### Pattern: Computed Properties
```dart
// Provider
class CartState with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  
  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.total);
  }
  
  int get itemCount => _items.length;
}

// UI
Text('Total: \$${context.watch<CartState>().totalPrice}')
```

### Pattern: Multiple Providers
```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterState()),
        ChangeNotifierProvider(create: (_) => ThemeState()),
        ChangeNotifierProvider(create: (_) => CartState()),
      ],
      child: MyApp(),
    ),
  );
}
```

## 🎯 When to Use What

| Method | Use Case | Rebuilds? |
|--------|----------|-----------|
| `context.read<T>()` | Calling methods, one-time reads | ❌ No |
| `context.watch<T>()` | Displaying state, listening to changes | ✅ Yes |
| `Consumer<T>` | Selective rebuilds, performance optimization | ✅ Yes (only Consumer) |
| `Provider.of<T>(context, listen: false)` | Same as read (older syntax) | ❌ No |
| `Provider.of<T>(context)` | Same as watch (older syntax) | ✅ Yes |

## ⚠️ Common Mistakes

### ❌ Wrong: Using watch in onPressed
```dart
ElevatedButton(
  onPressed: () {
    context.watch<CounterState>().increment(); // ❌ Don't watch here!
  },
  child: Text('Increment'),
)
```

### ✅ Correct: Using read in onPressed
```dart
ElevatedButton(
  onPressed: () {
    context.read<CounterState>().increment(); // ✅ Use read!
  },
  child: Text('Increment'),
)
```

### ❌ Wrong: Forgetting notifyListeners
```dart
void increment() {
  _count++;
  // ❌ UI won't update!
}
```

### ✅ Correct: Always call notifyListeners
```dart
void increment() {
  _count++;
  notifyListeners(); // ✅ UI updates!
}
```

### ❌ Wrong: Exposing mutable state
```dart
List<String> get items => _items; // ❌ Can be modified externally!
```

### ✅ Correct: Return unmodifiable collections
```dart
List<String> get items => List.unmodifiable(_items); // ✅ Safe!
```

## 🔧 Debugging Tips

### Print when state changes
```dart
void increment() {
  _count++;
  print('Counter incremented to $_count'); // Debug
  notifyListeners();
}
```

### Check provider registration
```dart
// If you get "Provider not found" error:
// 1. Make sure provider is registered in main.dart
// 2. Check that it's above the widget trying to use it
// 3. Verify the type matches exactly
```

### Use DevTools
```dart
// Flutter DevTools shows:
// - Widget tree with providers
// - State changes
// - Rebuild counts
```

## 📱 Demo Screens in This Project

1. **Provider Demo Hub** (`/provider-demo`)
   - Overview of all demos
   - Real-time state statistics

2. **Counter Demo** (`/provider-counter`)
   - Basic state management
   - Multi-screen sharing

3. **Favorites Demo** (`/favorites`)
   - List management
   - Add/remove items

4. **Shopping Cart** (`/shopping-cart`)
   - Complex state
   - Calculations

5. **Theme Settings** (`/theme-settings`)
   - App-wide state
   - Dark mode toggle

## 🎓 Learning Path

1. ✅ Start with Counter (basic state)
2. ✅ Try Favorites (list management)
3. ✅ Explore Cart (complex state)
4. ✅ Experiment with Theme (global state)
5. ✅ Build your own provider!

## 📚 Resources

- [Provider Package](https://pub.dev/packages/provider)
- [Flutter State Management](https://docs.flutter.dev/data-and-backend/state-mgmt)
- [Provider Examples](https://github.com/rrousselGit/provider/tree/master/examples)
