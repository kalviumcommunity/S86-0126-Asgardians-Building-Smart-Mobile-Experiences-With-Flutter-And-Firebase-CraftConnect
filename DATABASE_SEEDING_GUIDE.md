# DATABASE SEEDING GUIDE

## ✨ Quick Start

Your app now has a **Developer Tools** screen that can populate the database with realistic test data!

### 🚀 How to Access

1. **Launch the app** (hot reload after changes)
2. **Go to Account/Profile screen** (bottom navigation)
3. **Scroll down** to find "Developer" section
4. **Tap "Developer Tools"**
5. **Click "Seed Database"** button

### 📊 What Gets Created

When you seed the database, you'll get:

#### Users (2)
- **Buyer**: Rajesh Kumar
  - Email: `rajesh.buyer@craftconnect.app`
  - Phone: `+919876543210`
  
- **Seller**: Priya Sharma  
  - Email: `priya.artisan@craftconnect.app`
  - Phone: `+919876543211`

#### Shop (1)
- **Priya's Handicrafts**
  - Approved and active
  - Complete profile with images

#### Products (10)
All products have real images from Unsplash:

1. **Handcrafted Silver Earrings** - Jewelry (₹1,299)
2. **Traditional Kundan Necklace** - Jewelry (₹3,499)
3. **Ceramic Wall Hanging** - Home Decor (₹899)
4. **Handwoven Bamboo Basket** - Home Decor (₹499)
5. **Handloom Cotton Saree** - Clothing (₹2,199)
6. **Block Print Cotton Kurta** - Clothing (₹1,599)
7. **Leather Wallet - Handmade** - Accessories (₹799)
8. **Madhubani Painting** - Art (₹2,999)
9. **Terracotta Planter Set** - Pottery (₹699)
10. **Jute Tote Bag** - Accessories (₹599)

#### Reviews (15)
- **First 5 products** get 3 reviews each
- **Mix of 4-star and 5-star ratings**
- Realistic comments from verified buyers
- Average ratings calculated automatically

#### Orders (2)
- **2 orders** placed by buyer
- One **Shipped**, one **Completed**
- Different quantities and amounts
- One with gift wrapping

#### Cart Items (2)
- **Products #3 and #4** added to buyer's cart
- Ready for checkout testing

#### Wishlist (1)
- **Product #5** saved for later

---

## 🎯 Use Cases

### Test the App Features
- ✅ Browse products with real images
- ✅ See products with ratings/reviews
- ✅ Test cart & wishlist functionality
- ✅ View order history
- ✅ Test shop/store pages
- ✅ Search across categories

### Test Buyer Flow
1. Login as buyer (create account with buyer email)
2. Browse seeded products
3. Products already in cart
4. Products in wishlist
5. Order history visible

### Test Seller Flow
1. Login as seller (create account with seller email)
2. View shop dashboard
3. See products listed
4. View incoming orders
5. Test order management

---

## 🔄 Clear & Re-seed

If you want to start fresh:

1. Go to **Developer Tools** screen
2. Click **"Clear Seed Data"** button
3. Confirm the action
4. Click **"Seed Database"** again

---

## ⚠️ Important Notes

### Firebase Auth Required
The seeding creates **Firestore documents** but **NOT Firebase Auth users**.

**You need to:**
1. Sign up manually using the test emails
2. OR the users will be created on first login

### Production Warning
- **Remove the Developer Tools** section before production
- Or wrap it in `kDebugMode` check:
```dart
if (kDebugMode) {
  _buildSection('Developer', [...]);
}
```

### Image Sources
- All product images are from **Unsplash** (free to use)
- Images are high-quality and relevant to products
- Links are direct HTTPS URLs (fast loading)

---

## 🐛 Troubleshooting

### "Error seeding database"
**Cause:** Firebase not initialized properly

**Fix:**
1. Check `firebase_options.dart` exists
2. Verify Firebase is initialized in `main.dart`
3. Check Firestore rules allow writes

### Products not showing
**Cause:** Firestore indexes might be building

**Fix:**
1. Wait 1-2 minutes
2. Pull to refresh the product list
3. Check Firebase Console for index status

### Images not loading
**Cause:** Network connectivity or Unsplash rate limits

**Fix:**
1. Check internet connection
2. Wait a few seconds and retry
3. Images are cached after first load

---

## 📱 Screenshots Expected

After seeding, you should see:

**Home Screen:**
- 10 products in various categories
- Category filters working
- Product images loading

**Product Details:**
- Full product info
- Image gallery (2 images each)
- Star ratings (for first 5 products)
- Reviews visible

**Cart:**
- 2 products pre-added
- Total calculation working

**Orders:**
- 2 orders in history
- Different statuses
- Order details accessible

---

## 🎨 Categories Covered

- 💎 **Jewelry** (2 products)
- 🏠 **Home Decor** (2 products)
- 👔 **Clothing** (2 products)
- 👜 **Accessories** (2 products)
- 🎨 **Art** (1 product)
- 🏺 **Pottery** (1 product)

---

## 💡 Tips

1. **Seed once** - No need to seed multiple times
2. **Clear before re-seed** - Avoid duplicates
3. **Test all features** - Each product is different
4. **Check Firebase Console** - Verify data structure
5. **Use for demos** - Perfect for presentations!

---

## 📞 Support

If you encounter any issues:
1. Check console logs for detailed errors
2. Verify Firebase project configuration
3. Ensure all dependencies are installed
4. Check Firestore security rules

---

Happy Testing! 🚀
