# Google Play Billing Integration Guide

## Prerequisites

1. **Google Play Developer Account**
   - Create account at [Google Play Console](https://play.google.com/console)
   - Pay registration fee ($25 one-time)

2. **App Created in Google Play Console**
   - Internal test version first
   - Production version after testing

## Step 1: Add Flutter Packages

Update `pubspec.yaml`:

```yaml
dependencies:
  in_app_purchase: ^0.13.11
  in_app_purchase_android: ^0.2.12
  cloud_firestore: ^4.13.0
  provider: ^6.0.0
```

Run:
```bash
flutter pub get
```

## Step 2: Configure Android

### 2.1 Update `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        multiDexEnabled true
    }
}

dependencies {
    implementation 'com.android.billingclient:billing:6.1.0'
    implementation 'com.google.android.gms:play-services-base:18.2.0'
}
```

### 2.2 Update `android/build.gradle`

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 2.3 Add Permissions to `android/app/src/AndroidManifest.xml`

```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

## Step 3: Set Up Products in Google Play Console

### 3.1 Navigate to Your App

1. Open [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to **Monetize** → **Products** → **In-app products**

### 3.2 Create In-App Products

Create these products with exact SKU matching `PaymentService`:

| SKU | Name | Price |
|-----|------|-------|
| `coins_100` | 100 Coins | $0.99 |
| `coins_500` | 500 Coins | $4.99 |
| `coins_1000` | 1000 Coins | $9.99 |
| `coins_5000` | 5000 Coins | $39.99 |
| `coins_10000` | 10000 Coins | $79.99 |
| `coins_50000` | 50000 Coins | $299.99 |

**For each product:**
1. Click **Create product**
2. Select **In-app product**
3. Enter SKU (e.g., `coins_100`)
4. Enter title (e.g., "100 Coins")
5. Set price
6. Add description
7. Click **Save** and then **Activate**

### 3.3 Set Up Test Accounts

1. Go to **Settings** → **License Testing**
2. Add test email addresses under **Test accounts**
3. These accounts can make test purchases without charging

## Step 4: Get Billing Key

1. Go to **Monetize** → **Setup**
2. Copy **Public App Signing Key** (Base64)
3. Store securely (used for receipt verification)

## Step 5: Update App Manifest

### Add to `android/app/src/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.android.vending.billing.BILLING_KEY"
    android:value="YOUR_PUBLIC_KEY_HERE" />
```

## Step 6: Initialize in Flutter App

### Update `lib/main.dart`:

```dart
import 'package:provider/provider.dart';
import 'src/providers/payment_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        // ... rest of app config
      ),
    );
  }
}
```

## Step 7: Implement Purchase Flow in UI

### Example in `CoinRechargeScreen`:

```dart
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';

class CoinRechargeScreen extends StatefulWidget {
  @override
  State<CoinRechargeScreen> createState() => _CoinRechargeScreenState();
}

class _CoinRechargeScreenState extends State<CoinRechargeScreen> {
  @override
  void initState() {
    super.initState();
    _setupPurchaseListener();
  }

  void _setupPurchaseListener() {
    final paymentProvider = context.read<PaymentProvider>();
    final authProvider = context.read<AuthProvider>();n    
    // Listen to purchase updates
    paymentProvider.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        // Process each purchase
        final success = await paymentProvider.processPurchase(
          purchase,
          authProvider.userModel!.userId,
        );
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coins purchased successfully!'),
                backgroundColor: Color(0xFF27AE60),
              ),
            );
          }
        }
      }
    });
  }

  void _purchaseCoins(String productId) {
    final paymentProvider = context.read<PaymentProvider>();
    final authProvider = context.read<AuthProvider>();
    
    paymentProvider.purchaseCoins(
      productId,
      authProvider.userModel!.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, _) {
        return ElevatedButton(
          onPressed: paymentProvider.isProcessing 
            ? null 
            : () => _purchaseCoins('coins_500'),
          child: paymentProvider.isProcessing
              ? const CircularProgressIndicator()
              : const Text('Purchase Coins'),
        );
      },
    );
  }
}
```

## Step 8: Testing

### 8.1 Local Testing

1. Build debug APK:
   ```bash
   flutter build apk --debug
   ```

2. Install on test device:
   ```bash
   flutter install
   ```

3. Use test account email for testing

### 8.2 Internal Testing Track

1. Upload APK to Google Play Console
2. Go to **Testing** → **Internal testing**
3. Add test users
4. Share internal testing link
5. Test purchases with test account

### 8.3 Test Scenarios

- **Successful purchase**: Should add coins to wallet
- **Canceled purchase**: Should show cancellation message
- **Failed payment**: Should display error
- **Duplicate purchase**: Should be idempotent

## Step 9: Security Best Practices

### 9.1 Server-Side Receipt Verification

Implement Cloud Function to verify receipts:

```javascript
// functions/verifyReceipt.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { google } = require('googleapis');

exports.verifyReceipt = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Request requires authentication'
    );
  }

  const { packageName, productId, purchaseToken } = data;
  
  try {
    const androidPublisher = google.androidpublisher({
      version: 'v3',
      auth: new google.auth.GoogleAuth({
        keyFile: 'path/to/service-account-key.json',
      }),
    });

    const result = await androidPublisher.purchases.products.get({
      packageName,
      productId,
      token: purchaseToken,
    });

    // Verify purchase state
    if (result.data.purchaseState === 0) { // 0 = Purchased
      // Credit coins to user
      return { verified: true };
    }

    throw new functions.https.HttpsError(
      'failed-precondition',
      'Purchase state invalid'
    );
  } catch (error) {
    console.error('Verification failed:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Receipt verification failed'
    );
  }
});
```

### 9.2 Firestore Security Rules

Update `firestore.rules`:

```firestore
match /transactions/{transactionId} {
  // Only authenticated users can create transactions
  allow create: if request.auth != null &&
    request.resource.data.userId == request.auth.uid;
  
  // Users can read their own transactions
  allow read: if request.auth.uid == resource.data.userId;
  
  // Only admin can update (for manual adjustments)
  allow update: if isAdmin();
}
```

### 9.3 Prevent Fraud

- ✅ Always verify receipts server-side
- ✅ Check purchase token validity
- ✅ Verify product ID matches request
- ✅ Check purchase timestamp is recent
- ✅ Rate limit purchase requests
- ✅ Log all transactions
- ✅ Monitor for suspicious patterns

## Step 10: Production Deployment

### 10.1 Pre-Launch Checklist

- [ ] All products created in Google Play Console
- [ ] Test accounts configured
- [ ] Payment processing tested
- [ ] Receipt verification working
- [ ] Error handling implemented
- [ ] Analytics events tracked
- [ ] Privacy policy updated
- [ ] Terms of service updated

### 10.2 Release Process

1. Build release APK:
   ```bash
   flutter build appbundle --release
   ```

2. Upload to Google Play Console

3. Go to **Internal testing** → **Manage testers**

4. Once stable, promote to **Closed testing** or **Open testing**

5. Finally promote to **Production**

## Troubleshooting

### Common Issues

**Issue: "Billing service unavailable"**
- Ensure Google Play Services installed
- Check device has Google Play Store app
- Verify test account is Google account

**Issue: "Product not found"**
- Confirm SKU matches exactly in Google Play Console
- Verify product is "Active"
- Wait 24 hours for product to propagate

**Issue: "Purchase canceled"**
- Show clear purchase flow
- Handle user cancellation gracefully
- Offer retry option

**Issue: "Payment method required"**
- Add payment method to test account
- Use valid test credit card

## Monitoring & Analytics

Track purchases with Firebase Analytics:

```dart
await FirebaseAnalytics.instance.logPurchase(
  value: double.parse(product.price),
  currency: 'USD',
  items: [
    AnalyticsEventItem(
      itemId: productId,
      itemName: product.title,
      price: double.parse(product.price),
    ),
  ],
);
```

## References

- [Google Play Billing Documentation](https://developer.android.com/google/play/billing)
- [Flutter In-App Purchase Plugin](https://pub.dev/packages/in_app_purchase)
- [Receipt Verification Guide](https://developer.android.com/google/play/billing/security)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
