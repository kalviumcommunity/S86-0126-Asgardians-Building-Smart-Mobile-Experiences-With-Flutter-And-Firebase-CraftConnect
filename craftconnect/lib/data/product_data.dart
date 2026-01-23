import '../models/product.dart';

class ProductData {
  static List<Product> getSampleProducts() {
    return [
      Product(
        id: '1',
        name: 'Handwoven Basket',
        description:
            'Beautiful handwoven basket made from natural materials. Perfect for storage or decoration.',
        price: 45.99,
        category: 'Home Decor',
        imageUrl:
            'https://images.unsplash.com/photo-1567225557594-88d73e55f2cb?w=400',
        artisanName: 'Maria Santos',
        rating: 4.8,
        reviewCount: 124,
        inStock: true,
      ),
      Product(
        id: '2',
        name: 'Ceramic Pottery Set',
        description:
            'Hand-painted ceramic pottery set. Includes 4 bowls and 4 plates with traditional designs.',
        price: 89.99,
        category: 'Kitchenware',
        imageUrl:
            'https://images.unsplash.com/photo-1578500494198-246f612d3b3d?w=400',
        artisanName: 'John Maker',
        rating: 4.9,
        reviewCount: 89,
        inStock: true,
      ),
      Product(
        id: '3',
        name: 'Leather Wallet',
        description:
            'Premium handcrafted leather wallet with multiple card slots and coin pocket.',
        price: 35.50,
        category: 'Accessories',
        imageUrl:
            'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400',
        artisanName: 'David Craft',
        rating: 4.7,
        reviewCount: 203,
        inStock: true,
      ),
      Product(
        id: '4',
        name: 'Wooden Wall Art',
        description:
            'Rustic wooden wall art featuring intricate carved patterns. Adds warmth to any room.',
        price: 125.00,
        category: 'Home Decor',
        imageUrl:
            'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=400',
        artisanName: 'Sarah Woods',
        rating: 4.6,
        reviewCount: 67,
        inStock: true,
      ),
      Product(
        id: '5',
        name: 'Macrame Plant Hanger',
        description:
            'Handmade macrame plant hanger perfect for indoor plants. Includes hanging hardware.',
        price: 28.99,
        category: 'Home Decor',
        imageUrl:
            'https://images.unsplash.com/photo-1493106819501-66d381c466f1?w=400',
        artisanName: 'Emma Thread',
        rating: 4.8,
        reviewCount: 156,
        inStock: true,
      ),
      Product(
        id: '6',
        name: 'Knitted Wool Scarf',
        description:
            'Cozy hand-knitted wool scarf in beautiful patterns. Perfect for cold weather.',
        price: 42.00,
        category: 'Fashion',
        imageUrl:
            'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=400',
        artisanName: 'Lisa Knits',
        rating: 4.9,
        reviewCount: 178,
        inStock: true,
      ),
      Product(
        id: '7',
        name: 'Glass Jewelry Box',
        description:
            'Elegant handcrafted glass jewelry box with brass fittings. Perfect for storing treasures.',
        price: 67.50,
        category: 'Accessories',
        imageUrl:
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=400',
        artisanName: 'Robert Glass',
        rating: 4.7,
        reviewCount: 92,
        inStock: false,
      ),
      Product(
        id: '8',
        name: 'Beaded Necklace',
        description:
            'Colorful handmade beaded necklace with traditional patterns and vibrant colors.',
        price: 24.99,
        category: 'Jewelry',
        imageUrl:
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=400',
        artisanName: 'Anna Beads',
        rating: 4.6,
        reviewCount: 134,
        inStock: true,
      ),
    ];
  }

  static List<String> getCategories() {
    return [
      'All',
      'Home Decor',
      'Kitchenware',
      'Accessories',
      'Fashion',
      'Jewelry',
    ];
  }
}
