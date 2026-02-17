# Quick Implementation Guide

This guide shows how to use the new utilities and components.

## 1. Input Validation

### Email Validation
```dart
import '../../utils/validators.dart';

TextFormField(
  controller: emailController,
  validator: Validators.validateEmail,
)
```

### Phone Validation with Auto-Formatting
```dart
import '../../utils/validators.dart';

TextFormField(
  controller: phoneController,
  inputFormatters: [PhoneNumberFormatter()],
  decoration: InputDecoration(
    prefixText: '+91 ',
    helperText: 'Enter 10-digit mobile number',
  ),
  validator: Validators.validatePhone,
)
```

### Password Validation
```dart
TextFormField(
  controller: passwordController,
  obscureText: true,
  decoration: InputDecoration(
    helperText: 'Min 8 chars with uppercase, lowercase & number',
  ),
  validator: Validators.validatePassword,
)
```

### Price Validation
```dart
TextFormField(
  controller: priceController,
  validator: (value) => Validators.validatePrice(
    value,
    min: 1,
    max: 999999,
  ),
)
```

### Quantity Validation
```dart
TextFormField(
  controller: quantityController,
  validator: (value) => Validators.validateQuantity(
    value,
    min: 0,
    max: 10000,
  ),
)
```

## 2. Image Handling

### Pick and Validate Single Image
```dart
import '../../utils/image_helper.dart';

Future<void> _pickImage() async {
  final result = await ImageHelper.pickImage(
    source: ImageSource.gallery,
    maxSizeInMB: 5.0,
  );

  if (result.isValid && result.file != null) {
    setState(() {
      _imageFile = result.file;
    });
    ImageHelper.showSuccess(
      context,
      'Image selected (${ImageHelper.formatFileSize(result.fileSizeInMB!)})',
    );
  } else if (result.errorMessage != null) {
    ImageHelper.showValidationError(context, result.errorMessage!);
  }
}
```

### Pick Multiple Images
```dart
final results = await ImageHelper.pickMultipleImages(
  maxImages: 5,
  maxSizeInMB: 5.0,
);

for (final result in results) {
  if (result.isValid && result.file != null) {
    // Add to list
  }
}
```

## 3. Cached Images

### Basic Product Image
```dart
import '../../widgets/cached_image.dart';

ProductImage(
  imageUrl: product.imageUrl,
  width: 200,
  height: 200,
)
```

### Shop Logo
```dart
ShopLogoImage(
  imageUrl: shop.logoUrl,
  size: 80,
)
```

### User Avatar with Fallback
```dart
UserAvatarImage(
  imageUrl: user.photoUrl,
  userName: user.name,
  size: 40,
)
```

### Custom Cached Image
```dart
CachedImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(12),
)
```

## 4. Empty States

### Predefined Empty States
```dart
import '../../widgets/empty_state_widget.dart';

// Empty cart
EmptyStates.cart(
  onShopNow: () => context.go('/home'),
)

// No orders
EmptyStates.orders()

// No products (for artisans)
EmptyStates.products(
  onAddProduct: () => context.go('/add-product'),
)

// Search with no results
EmptyStates.search(query: searchQuery)

// Error with retry
EmptyStates.error(
  message: 'Failed to load data',
  onRetry: () => _loadData(),
)

// No internet
EmptyStates.noInternet(
  onRetry: () => _loadData(),
)
```

### Custom Empty State
```dart
EmptyStateWidget(
  icon: Icons.favorite_outline,
  title: 'Custom Title',
  message: 'Custom message here',
  actionLabel: 'Action Button',
  onAction: () {
    // Handle action
  },
)
```

## 5. Loading States

### Full Screen Loading
```dart
import '../../widgets/loading_state_widget.dart';

LoadingStateWidget(
  message: 'Loading products...',
)
```

### Inline Loading
```dart
InlineLoadingIndicator(
  size: 20,
  label: 'Processing...',
)
```

### Shimmer Loading
```dart
// Product card skeleton
ProductCardShimmer()

// Shop card skeleton
ShopCardShimmer()

// Custom shimmer
ShimmerLoading(
  width: 200,
  height: 100,
  borderRadius: BorderRadius.circular(12),
)
```

## 6. Search Debouncing

```dart
import '../../utils/debouncer.dart';

class _SearchScreenState extends State<SearchScreen> {
  final _searchDebouncer = SearchDebouncer();

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        // Update UI immediately
        setState(() {
          _showSearchHistory = value.isEmpty;
        });
        
        // Debounce the search
        _searchDebouncer(() {
          _performSearch(value);
        });
      },
    );
  }
}
```

## 7. App Configuration

### Access Carousel Banners
```dart
import '../../config/app_content.dart';

final banners = AppContent.carouselBanners;

// Use in carousel
Image.network(
  banner['fallbackUrl'] ?? banner['image']!,
)
```

### Access Limits
```dart
// Validate against limits
if (imageSize > AppContent.maxImageSizeMB) {
  // Show error
}

if (productName.length > AppContent.maxProductNameLength) {
  // Show error
}
```

### Feature Flags
```dart
if (AppContent.enableWishlist) {
  // Show wishlist button
}

if (AppContent.enablePushNotifications) {
  // Setup notifications
}
```

## 8. Complete Form Example

```dart
import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import '../../utils/image_helper.dart';

class AddProductScreen extends StatefulWidget {
  // ...
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  
  File? _imageFile;
  
  Future<void> _pickImage() async {
    final result = await ImageHelper.pickImage();
    if (result.isValid && result.file != null) {
      setState(() => _imageFile = result.file);
    } else if (result.errorMessage != null) {
      ImageHelper.showValidationError(context, result.errorMessage!);
    }
  }
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Process form
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Image picker
          GestureDetector(
            onTap: _pickImage,
            child: _imageFile != null
                ? Image.file(_imageFile!)
                : Placeholder(),
          ),
          
          // Product name
          TextFormField(
            controller: _nameController,
            validator: (v) => Validators.required(v, 'Product name'),
          ),
          
          // Price
          TextFormField(
            controller: _priceController,
            validator: (v) => Validators.validatePrice(v, min: 1, max: 999999),
          ),
          
          // Stock
          TextFormField(
            controller: _stockController,
            validator: (v) => Validators.validateQuantity(v, min: 0, max: 10000),
          ),
          
          // Submit
          ElevatedButton(
            onPressed: _submit,
            child: Text('Add Product'),
          ),
        ],
      ),
    );
  }
}
```

## 9. List with Loading and Empty States

```dart
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_state_widget.dart';

Widget build(BuildContext context) {
  return Consumer<ProductProvider>(
    builder: (context, provider, child) {
      // Loading state
      if (provider.isLoading) {
        return ListView.builder(
          itemCount: 3,
          itemBuilder: (_, __) => ProductCardShimmer(),
        );
      }
      
      // Empty state
      if (provider.products.isEmpty) {
        return EmptyStates.products(
          onAddProduct: () => context.go('/add-product'),
        );
      }
      
      // Success state
      return ListView.builder(
        itemCount: provider.products.length,
        itemBuilder: (context, index) {
          final product = provider.products[index];
          return ProductCard(product: product);
        },
      );
    },
  );
}
```

## Tips

1. **Always dispose Debouncers** in `dispose()` method
2. **Use const constructors** for empty states when possible
3. **Validate before network calls** to reduce API usage
4. **Show inline errors** for better UX
5. **Use shimmer for lists**, spinner for actions
6. **Provide retry options** in error states
7. **Keep validation messages** user-friendly and actionable
