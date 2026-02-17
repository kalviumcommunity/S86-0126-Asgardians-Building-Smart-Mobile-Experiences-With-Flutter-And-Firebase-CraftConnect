# CraftConnect Cloud Functions

This directory contains all Firebase Cloud Functions for the CraftConnect application.

## 📋 Functions Overview

### Order Management
- **onOrderCreated** - Sends notifications when new order is placed
- **onOrderStatusUpdate** - Notifies buyer when order status changes

### Return Management
- **onReturnRequestCreated** - Notifies admin and shop owner about return requests
- **onReturnStatusUpdate** - Notifies user when return is approved/rejected

### Chat Notifications
- **onNewMessage** - Sends push notifications for new chat messages

### Analytics & Reports
- **generateDailySalesReport** - Creates daily sales reports (runs at 11 PM IST)
- **onReviewCreated** - Updates product rating when new review is added

### Scheduled Tasks
- **checkLowStock** - Sends alerts for low stock products (runs daily at 9 AM IST)
- **cleanupExpiredCoupons** - Deactivates expired coupons (runs daily at midnight IST)

### User & Shop Management
- **onUserCreated** - Sends welcome notification to new users
- **onShopCreated** - Notifies admins when new shop is created

## 🚀 Setup

### 1. Install Dependencies
```bash
cd functions
npm install
```

### 2. Firebase Configuration
Ensure you have Firebase CLI installed:
```bash
npm install -g firebase-tools
firebase login
```

### 3. Initialize Firebase (if not done)
```bash
firebase init functions
# Select: Use an existing project
# Choose: JavaScript
# Enable ESLint: Yes
# Install dependencies: Yes
```

## 📦 Deployment

### Deploy All Functions
```bash
firebase deploy --only functions
```

### Deploy Specific Function
```bash
firebase deploy --only functions:onOrderCreated
```

### Deploy Multiple Functions
```bash
firebase deploy --only functions:onOrderCreated,functions:onOrderStatusUpdate
```

## 🧪 Testing Locally

### Start Emulator
```bash
npm run serve
# Or
firebase emulators:start --only functions
```

### Test in Shell
```bash
npm run shell
# Or
firebase functions:shell
```

## 📊 Monitoring

### View Logs
```bash
npm run logs
# Or
firebase functions:log
```

### View Specific Function Logs
```bash
firebase functions:log --only onOrderCreated
```

## ⚙️ Environment Variables

If you need to use environment variables:

```bash
firebase functions:config:set service.key="your-api-key"
```

Access in code:
```javascript
const apiKey = functions.config().service.key;
```

## 📝 Function Triggers

### Firestore Triggers
- `onCreate` - When document is created
- `onUpdate` - When document is updated
- `onDelete` - When document is deleted
- `onWrite` - Any write operation

### Scheduled Functions (Cron Jobs)
Format: `"minute hour day month weekday"`
- `"0 9 * * *"` - Every day at 9:00 AM
- `"0 0 * * 0"` - Every Sunday at midnight
- `"*/15 * * * *"` - Every 15 minutes

## 🔒 Security

### Enable Required APIs
```bash
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable cloudtasks.googleapis.com
```

### IAM Permissions
Ensure the Cloud Functions service account has:
- Cloud Datastore User
- Firebase Cloud Messaging Admin
- Cloud Scheduler Admin

## 💰 Cost Optimization

### Free Tier Limits
- 2M invocations/month
- 400,000 GB-seconds, 200,000 GHz-seconds of compute time
- 5GB network egress

### Tips
1. Use scheduled functions wisely
2. Implement proper error handling to avoid retries
3. Set timeouts appropriately
4. Use batching for bulk operations

## 🐛 Debugging

### Enable Debug Logging
```bash
firebase functions:log --only onOrderCreated
```

### Common Issues

**Issue: Function timeout**
```javascript
exports.myFunction = functions
  .runWith({ timeoutSeconds: 300 }) // Increase timeout
  .firestore.document('...')
```

**Issue: Memory limit**
```javascript
exports.myFunction = functions
  .runWith({ memory: '1GB' }) // Increase memory
  .firestore.document('...')
```

## 📚 Documentation

- [Cloud Functions Docs](https://firebase.google.com/docs/functions)
- [Cloud Scheduler](https://cloud.google.com/scheduler/docs)
- [Admin SDK Reference](https://firebase.google.com/docs/reference/admin)

## 📞 Support

For issues or questions:
1. Check Firebase Console logs
2. Review function execution history
3. Enable detailed logging
4. Test in local emulator first
