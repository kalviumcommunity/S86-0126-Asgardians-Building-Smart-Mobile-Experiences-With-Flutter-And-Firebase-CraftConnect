# 🚀 Firebase Cloud Functions Setup Guide

## 📋 Prerequisites

1. **Node.js** (v18 or higher)
   ```bash
   node --version  # Should be v18.x or higher
   ```

2. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase --version
   ```

3. **Firebase Project** - Your project should already be set up

## 🔧 Initial Setup

### Step 1: Login to Firebase
```bash
firebase login
```

### Step 2: Initialize Cloud Functions (If Not Already Done)
```bash
cd "d:\Kalvium\SimulationDec\Sprint #2\craftconnect_demo"
firebase init functions
```

**Configuration:**
- Use an existing project: **Select your CraftConnect project**
- Language: **JavaScript**
- ESLint: **Yes**
- Install dependencies: **Yes**

### Step 3: Install Dependencies
```bash
cd functions
npm install
```

## 📦 Deploy Functions

### Deploy All Functions
```bash
firebase deploy --only functions
```

### First-Time Deployment
You may need to upgrade to Blaze (Pay as you go) plan:
```bash
firebase open billing
```
**Note:** Free tier includes generous limits - unlikely to exceed for small apps.

### Deploy Specific Functions (Faster)
```bash
# Deploy only order-related functions
firebase deploy --only functions:onOrderCreated,functions:onOrderStatusUpdate

# Deploy only scheduled functions
firebase deploy --only functions:checkLowStock,functions:cleanupExpiredCoupons
```

## 🧪 Local Testing

### Start Emulators
```bash
cd functions
npm run serve
```

**Or with full Firebase emulator suite:**
```bash
firebase emulators:start
```

### Test Functions Locally
1. Start emulator: `npm run serve`
2. Trigger functions via Firestore emulator
3. Check logs in terminal

## ⚙️ Enable Required APIs

### 1. Cloud Scheduler (for scheduled functions)
```bash
gcloud services enable cloudscheduler.googleapis.com
```

Or via Firebase Console:
- Go to: https://console.cloud.google.com/cloudscheduler
- Click "Enable API"

### 2. Cloud Pub/Sub (for scheduled functions)
```bash
gcloud services enable pubsub.googleapis.com
```

## 📊 Function Details

### Firestore Triggered Functions

| Function Name | Trigger | Purpose |
|---------------|---------|---------|
| `onOrderCreated` | New order created | Notify shop owner & buyer |
| `onOrderStatusUpdate` | Order status changes | Update buyer on progress |
| `onReturnRequestCreated` | Return request created | Alert admin & shop owner |
| `onReturnStatusUpdate` | Return status changes | Notify user |
| `onNewMessage` | New chat message | Send push notification |
| `onReviewCreated` | New review posted | Update product rating |
| `onUserCreated` | New user registers | Send welcome message |
| `onShopCreated` | New shop created | Notify admins |

### Scheduled Functions (Cron Jobs)

| Function Name | Schedule | Purpose |
|---------------|----------|---------|
| `checkLowStock` | Daily at 9 AM IST | Alert artisans about low stock |
| `cleanupExpiredCoupons` | Daily at midnight IST | Deactivate expired coupons |
| `generateDailySalesReport` | Daily at 11 PM IST | Create sales analytics |

## 🔐 Security & Permissions

### Set App Check (Recommended for Production)
```bash
firebase apps:sdkconfig web
```

### Service Account Permissions
The default Firebase service account has these permissions:
- ✅ Cloud Datastore User
- ✅ Firebase Cloud Messaging Admin
- ✅ Cloud Functions Developer

**No additional setup needed!**

## 📱 FCM Token Setup

For push notifications to work, ensure your Flutter app:

1. **Saves FCM tokens to Firestore:**
```dart
// lib/services/notification_service.dart
FirebaseMessaging.instance.getToken().then((token) {
  FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({'fcmToken': token});
});
```

2. **Updates token on refresh:**
```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({'fcmToken': newToken});
});
```

## 📊 Monitoring & Logs

### View Function Logs
```bash
firebase functions:log
```

### View Specific Function
```bash
firebase functions:log --only onOrderCreated
```

### Firebase Console
View in real-time:
https://console.firebase.google.com/project/YOUR_PROJECT/functions/logs

## 💰 Cost Estimates

### Free Tier (Spark Plan)
- ❌ Cloud Functions: Not available
- Need Blaze plan for Cloud Functions

### Blaze Plan (Pay as you go)
**Free Monthly Allowances:**
- 2M invocations
- 400,000 GB-seconds compute
- 200,000 GHz-seconds compute
- 5GB network egress

**Your Expected Usage (small app):**
- ~10,000-50,000 invocations/month
- **Estimated Cost: $0-5/month**

## 🐛 Troubleshooting

### Error: "Billing account not configured"
**Solution:** Upgrade to Blaze plan
```bash
firebase open billing
```

### Error: "Cloud Scheduler API not enabled"
**Solution:**
```bash
gcloud services enable cloudscheduler.googleapis.com
```

### Error: "Function timeout"
**Solution:** Increase timeout in function config:
```javascript
exports.myFunction = functions
  .runWith({ timeoutSeconds: 300 })
  .firestore.document('...')
```

### Error: "Insufficient permissions"
**Solution:** Grant permissions in IAM:
https://console.cloud.google.com/iam-admin/iam

## ✅ Deployment Checklist

Before deploying:
- [ ] All dependencies installed (`npm install`)
- [ ] No linting errors (`npm run lint`)
- [ ] Local testing passed (`npm run serve`)
- [ ] Billing enabled (Blaze plan)
- [ ] Cloud Scheduler API enabled
- [ ] FCM tokens saved in Firestore
- [ ] Reviewed function costs

## 🚀 Deploy Commands

```bash
# Deploy everything
firebase deploy

# Deploy only functions
firebase deploy --only functions

# Deploy single function
firebase deploy --only functions:onOrderCreated

# Deploy with debug logging
firebase deploy --only functions --debug
```

## 📈 After Deployment

### Verify Functions
1. Go to Firebase Console → Functions
2. Check all functions are deployed
3. Verify scheduled functions have triggers

### Test Notifications
1. Create a test order in app
2. Check notifications collection in Firestore
3. Verify FCM notification received on device

### Monitor Execution
```bash
firebase functions:log --only onOrderCreated --tail
```

## 🎯 Next Steps

1. **Deploy functions:** `firebase deploy --only functions`
2. **Test order flow:** Create order → Check notifications
3. **Test chat:** Send message → Verify push notification
4. **Monitor logs:** Check Firebase Console
5. **Optimize:** Review execution times and costs

## 📞 Support

**Firebase Console:**
https://console.firebase.google.com

**Function Logs:**
https://console.firebase.google.com/project/YOUR_PROJECT/functions/logs

**Documentation:**
https://firebase.google.com/docs/functions

---

**🎊 Your Cloud Functions are ready to deploy!**
