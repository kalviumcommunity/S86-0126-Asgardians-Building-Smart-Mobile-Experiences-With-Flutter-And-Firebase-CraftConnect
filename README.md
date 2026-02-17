# CraftConnect 🎨

**Digital Storefront for Local Artisans - Empowering Traditional Crafts in the Digital Age**

> One app. One link. Infinite possibilities for artisans.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Powered-FFCA28?logo=firebase)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-brightgreen)
![License](https://img.shields.io/badge/License-MIT-blue)

## 🎯 Overview

**CraftConnect** is a modern, production-ready e-commerce platform specifically designed for local artisans and craftspeople. It eliminates the barriers of entry into digital commerce by providing a complete, ready-to-use solution without requiring any technical knowledge, website maintenance, or hosting costs.

### The Problem We Solve
Traditional artisans often lack:
- **Technical Skills**: Don't know how to build/maintain websites
- **Financial Resources**: Can't afford expensive e-commerce platforms
- **Digital Presence**: Miss out on online customers
- **Marketing Tools**: Struggle to reach wider audiences

### Our Solution
CraftConnect provides a **free, mobile-first platform** where artisans can:
- Create a digital storefront in under 5 minutes
- Get a shareable link for their shop (like Instagram's bio link)
- Manage products, orders, and customers from their phone
- Accept payments and track sales
- Reach customers through social media sharing

---

## ✨ Key Features

### 🛍️ For Artisans (Sellers)
| Feature | Description |
|---------|-------------|
| **Instant Shop Creation** | Create your digital storefront in minutes with an easy step-by-step process |
| **Product Management** | Add unlimited products with images, descriptions, pricing, and stock tracking |
| **Auto-Generated Links** | Get unique, shareable URLs for your shop and individual products (`craftconnect.com/shop/yourname`) |
| **Social Media Integration** | Share directly to WhatsApp, Facebook, Instagram, and more with pre-formatted messages |
| **Order Dashboard** | Real-time order management with status tracking (New → Accepted → Shipped → Delivered) |
| **Push Notifications** | Instant alerts for new orders, messages, and customer inquiries |
| **Analytics Dashboard** | Track sales, revenue, popular products, and customer behavior |
| **Inventory Management** | Automated stock tracking with low-stock alerts |
| **Multi-Language Support** | Interface available in English, Hindi, and Telugu |
| **Messaging System** | Direct chat with customers for queries and support |
| **Return Management** | Handle returns and refunds professionally |
| **Coupon & Discounts** | Create promotional codes and special offers |
| **Gift Wrapping** | Offer premium gift wrapping services |

### 🛒 For Buyers (Customers)
| Feature | Description |
|---------|-------------|
| **No Login Required** | Browse and shop without creating an account (optional login for order tracking) |
| **Cross-Platform Access** | Shop from Android app or web browser |
| **Simple Checkout** | 3-step checkout process (Cart → Details → Payment) |
| **Multiple Payment Options** | UPI, Cards, Cash on Delivery support |
| **Order Tracking** | Real-time order status and delivery updates |
| **Wishlist** | Save favorite products for later |
| **Product Reviews** | Read and write reviews with ratings |
| **Chat with Artisan** | Direct messaging to ask questions about products |
| **Return Requests** | Easy return/refund process with photo upload |
| **Recently Viewed** | Quick access to products you've browsed |
| **Product Comparison** | Compare up to 3 products side-by-side |
| **Advanced Search** | Filter by category, price, rating, and more |

### 👨‍💼 For Admins
| Feature | Description |
|---------|-------------|
| **Shop Management** | Approve, monitor, and manage all artisan shops |
| **Order Monitoring** | View all platform orders and transactions |
| **Analytics Dashboard** | Platform-wide metrics and insights |
| **User Management** | Manage buyer and seller accounts |
| **Return Oversight** | Monitor and resolve return requests |
| **Coupon Management** | Create and manage platform-wide promotions |

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.0+ (Dart)
- **State Management**: Provider Pattern
- **Routing**: GoRouter (Deep linking support)
- **UI Components**: Material Design 3
- **Localization**: Flutter Intl (Multi-language)
- **Image Handling**: Cached Network Images
- **Fonts**: Google Fonts

### Backend
- **Authentication**: Firebase Auth (Email, Phone, Google)
- **Database**: Cloud Firestore (NoSQL)
- **Storage**: Firebase Cloud Storage (Images & Files)
- **Functions**: Firebase Cloud Functions (Business Logic)
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Analytics**: Firebase Analytics
- **Hosting**: Firebase Hosting (Web deployment)

### DevOps & Tools
- **Version Control**: Git & GitHub
- **CI/CD**: GitHub Actions
- **Testing**: Flutter Widget Tests
- **Performance**: Firebase Performance Monitoring
- **Crash Reporting**: Firebase Crashlytics

---

## 📁 Project Structure

```
craftconnect/
├── android/                    # Android-specific configuration
├── web/                        # Web-specific configuration
├── lib/
│   ├── main.dart              # App entry point
│   ├── config/                # Configuration files
│   │   ├── firebase_config.dart
│   │   ├── routes.dart
│   │   └── theme.dart
│   ├── models/                # Data models
│   │   ├── user_model.dart
│   │   ├── shop_model.dart
│   │   ├── product_model.dart
│   │   └── order_model.dart
│   ├── services/              # Business logic services
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   ├── notification_service.dart
│   │   └── deep_link_service.dart
│   ├── providers/             # State management
│   │   ├── auth_provider.dart
│   │   ├── shop_provider.dart
│   │   ├── product_provider.dart
│   │   └── order_provider.dart
│   ├── screens/               # UI screens
│   │   ├── auth/
│   │   ├── artisan/
│   │   ├── buyer/
│   │   └── admin/
│   ├── widgets/               # Reusable widgets
│   └── l10n/                  # Localization files
├── functions/                 # Cloud Functions
├── .github/workflows/         # CI/CD pipelines
├── assets/                    # Images, icons, fonts
├── pubspec.yaml              # Dependencies
└── README.md                 # This file
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Firebase CLI
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/craftconnect.git
   cd craftconnect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Enable the following services:
      - Authentication (Email/Password + Phone)
      - Cloud Firestore
      - Cloud Storage
      - Cloud Messaging
      - Hosting
   
   c. Download configuration files:
      - `google-services.json` for Android → place in `android/app/`
      - `GoogleService-Info.plist` for iOS → place in `ios/Runner/`
   
   d. Update `lib/config/firebase_config.dart` with your Firebase credentials

4. **Configure Deep Linking**
   
   Update the following files with your domain:
   - `android/app/src/main/AndroidManifest.xml`
   - `web/index.html`

5. **Run the app**
   ```bash
   # For Android
   flutter run -d android
   
   # For Web
   flutter run -d chrome
   
   # For iOS (Mac only)
   flutter run -d ios
   ```

## 🔧 Configuration

### Firebase Configuration

Update `lib/config/firebase_config.dart` with your Firebase project credentials:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'your-project-id',
  // ... other config
);
```

### Deep Linking

**Web:** Update `web/index.html` base href  
**Android:** Update `android/app/src/main/AndroidManifest.xml` with your domain

### Localization

The app supports three languages:
- English (en)
- Hindi (hi)
- Telugu (te)

Localization files are in `lib/l10n/`:
- `app_en.arb`
- `app_hi.arb`
- `app_te.arb`

## 📱 Building for Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Web

```bash
flutter build web --release
```

Output: `build/web/`

Deploy to Firebase Hosting:
```bash
firebase deploy --only hosting
```

## 🔄 CI/CD with GitHub Actions

The project includes automated APK building on every push.

Workflow file: `.github/workflows/build.yml`

On every push to `main`:
1. Builds Android APK
2. Uploads as artifact
3. Creates release (optional)

## 🗄️ Database Schema

### Collections

#### users
```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "phone": "string",
  "role": "artisan | buyer | admin",
  "language": "en | hi | te",
  "fcmToken": "string",
  "createdAt": "timestamp"
}
```

#### shops
```json
{
  "shopId": "string",
  "ownerId": "string",
  "shopName": "string",
  "slug": "string (unique)",
  "description": "string",
  "contact": "string",
  "imageUrl": "string",
  "isApproved": "boolean",
  "isActive": "boolean",
  "createdAt": "timestamp"
}
```

#### products
```json
{
  "productId": "string",
  "shopId": "string",
  "name": "string",
  "description": "string",
  "price": "number",
  "imageUrl": "string",
  "stock": "number",
  "isAvailable": "boolean",
  "createdAt": "timestamp"
}
```

#### orders
```json
{
  "orderId": "string",
  "productId": "string",
  "shopId": "string",
  "artisanId": "string",
  "buyerName": "string",
  "buyerPhone": "string",
  "buyerAddress": "string",
  "quantity": "number",
  "totalAmount": "number",
  "status": "new | accepted | shipped | completed | cancelled",
  "paymentStatus": "pending | success | failed",
  "paymentMethod": "upi",
  "upiId": "string",
  "createdAt": "timestamp"
}
```

## 🔐 Security Rules

Firestore security rules are configured to:
- Allow public read access to shops and products
- Restrict write access to authenticated users
- Ensure users can only modify their own data
- Admin-only access for sensitive operations

## 🎨 Design System

### Color Palette
- **Primary:** Terracotta (#D4735E)
- **Secondary:** Golden Yellow (#F4A261)
- **Accent:** Deep Teal (#2A9D8F)
- **Background:** Cream (#F8F4E3)
- **Text:** Dark Brown (#3D2E2E)

### Typography
- **Headers:** Poppins (Bold)
- **Body:** Inter (Regular)

## 📊 Features Roadmap

- [x] Authentication (Email + Phone)
- [x] Shop Creation & Management
- [x] Product Management
- [x] Order System
- [x] Mock UPI Payment
- [x] Push Notifications
- [x] Multi-language Support
- [x] Deep Linking
- [x] Social Sharing
- [ ] Real Payment Integration
- [ ] Chat Support
- [ ] Reviews & Ratings
- [ ] Advanced Analytics
- [ ] Inventory Management
- [ ] Discount Coupons

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Project Lead:** Your Name
- **Backend:** Firebase
- **Frontend:** Flutter Team

## 📞 Support

For support, email support@craftconnect.app or join our Slack channel.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for the robust backend
- All the artisans who inspired this project

---

**Made with ❤️ for Local Artisans**

*Empowering craftspeople, one digital storefront at a time.*
