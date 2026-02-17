/// Configuration for app content like carousel images, categories, etc.
class AppContent {
  // Carousel banner images
  // TODO: Replace these with your own hosted images or local assets
  static const List<Map<String, String>> carouselBanners = [
    {
      'image': 'assets/images/banner_1.jpg',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1530103043960-ef38714abb15?w=800',
      'title': 'Discover Handcrafted Treasures',
      'subtitle': 'Support Local Artisans',
      'action': '/explore',
    },
    {
      'image': 'assets/images/banner_2.jpg',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1513519245088-0e12902e35ca?w=800',
      'title': 'Unique Handmade Products',
      'subtitle': 'One-of-a-kind Designs',
      'action': '/products',
    },
    {
      'image': 'assets/images/banner_3.jpg',
      'fallbackUrl':
          'https://images.unsplash.com/photo-1596638250683-bf5e0653139a?w=800',
      'title': 'Shop from Local Makers',
      'subtitle': 'Quality Craftsmanship',
      'action': '/shops',
    },
  ];

  // Featured categories with icons
  static const List<Map<String, String>> categories = [
    {'name': 'Jewelry', 'icon': 'diamond_outlined', 'slug': 'jewelry'},
    {'name': 'Home Decor', 'icon': 'home_outlined', 'slug': 'home-decor'},
    {'name': 'Clothing', 'icon': 'checkroom_outlined', 'slug': 'clothing'},
    {
      'name': 'Accessories',
      'icon': 'shopping_bag_outlined',
      'slug': 'accessories'
    },
    {'name': 'Art', 'icon': 'palette_outlined', 'slug': 'art'},
    {'name': 'Pottery', 'icon': 'liquor_outlined', 'slug': 'pottery'},
  ];

  // Placeholder image URLs for empty states
  static const String placeholderProduct =
      'https://via.placeholder.com/400x400.png?text=Product';
  static const String placeholderShop =
      'https://via.placeholder.com/200x200.png?text=Shop';
  static const String placeholderUser =
      'https://via.placeholder.com/100x100.png?text=User';

  // App information
  static const String supportEmail = 'support@craftconnect.com';
  static const String supportPhone = '+91-1234567890';
  static const String termsUrl = 'https://craftconnect.com/terms';
  static const String privacyUrl = 'https://craftconnect.com/privacy';

  // Social media links
  static const String facebookUrl = 'https://facebook.com/craftconnect';
  static const String instagramUrl = 'https://instagram.com/craftconnect';
  static const String twitterUrl = 'https://twitter.com/craftconnect';

  // Feature flags
  static const bool enablePushNotifications = true;
  static const bool enableSocialSharing = true;
  static const bool enableWishlist = true;
  static const bool enableReviews = true;

  // Limits and constraints
  static const int maxCartItems = 50;
  static const int maxWishlistItems = 100;
  static const int maxProductImages = 5;
  static const double maxImageSizeMB = 5.0;
  static const int maxProductNameLength = 100;
  static const int maxProductDescLength = 1000;
  static const double minProductPrice = 1.0;
  static const double maxProductPrice = 999999.0;
}
