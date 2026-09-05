# Firebase Setup Guide - Diyo Party Live

## Prerequisites
- Firebase Project created on [Firebase Console](https://console.firebase.google.com/)
- Flutter Firebase CLI installed: `npm install -g firebase-tools`
- Firebase initialized in project: `firebase init`

## Step 1: Enable Services

### 1. Firestore Database
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Select "Start in production mode"
4. Choose location: `us-central1` (or your preferred region)
5. Create database

### 2. Authentication
1. Go to Firebase Console → Authentication
2. Click "Get started"
3. Enable "Phone" provider:
   - Click "Phone"
   - Enable the toggle
   - (Optional) Add reCAPTCHA v3 for production
4. Enable "Google" provider:
   - Click "Google"
   - Enable the toggle
   - Add your support email
   - Add authorized domains

### 3. Cloud Functions
1. Go to Firebase Console → Functions
2. Click "Get started"
3. Deploy functions (see functions/ directory)

### 4. Cloud Storage
1. Go to Firebase Console → Storage
2. Click "Get started"
3. Keep default security rules for now

## Step 2: Deploy Firestore Rules

```bash
# Login to Firebase
firebase login

# Set your Firebase project
firebase use --add
# Select your project from the list

# Deploy Firestore rules
firebase deploy --only firestore:rules
```

## Step 3: Create Firestore Indexes

The indexes are defined in `firebase.json`. Deploy them:

```bash
firebase deploy --only firestore:indexes
```

## Step 4: Configure Flutter App

### For Android:

1. Add your Android app in Firebase Console
2. Download `google-services.json`
3. Place it in: `android/app/google-services.json`
4. Update `android/build.gradle`:

```gradle
classPath 'com.google.gms:google-services:4.3.15'
```

5. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.firebase:firebase-bom:32.3.1'
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
    implementation 'com.google.firebase:firebase-storage'
}
```

### For iOS:

1. Add your iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. In Xcode, drag it to the Runner folder
4. Select "Copy items if needed" and target "Runner"
5. Update `ios/Podfile`:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_ios_post_install(installer)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'FIREBASE_ANALYTICS_COLLECTION_ENABLED=1'
      ]
    end
  end
end
```

## Step 5: Update pubspec.yaml

Add Firebase dependencies:

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.10.0
  firebase_firestore: ^4.13.0
  firebase_storage: ^11.2.0
  cloud_functions: ^4.2.0
  go_router: ^13.0.0
  provider: ^6.0.0
```

Run:
```bash
flutter pub get
```

## Step 6: Initialize Firebase in Flutter

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

future void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

## Step 7: Security Rules Overview

### Key Security Principles:

1. **Authentication Required**: Most operations require `isAuthenticated()`
2. **User Privacy**: Users can only see their own data
3. **Admin Privileges**: Admins can access and modify restricted data
4. **Role-Based Access**: Different permissions for user/host/admin roles
5. **Transaction Safety**: Withdrawal amounts must be >= 100 diamonds

### Firestore Rules Structure:

```
/users/{userId}
  ├── Can read: Owner, Admin
  ├── Can update: Owner (limited fields)
  └── Subcollections:
      ├── /transactions
      └── /followers

/party_rooms/{roomId}
  ├── Can read: Authenticated (active), Admin (all)
  ├── Can create: Authenticated (own room)
  └── Subcollections:
      ├── /messages
      ├── /viewers
      └── /gifts

/wallets/{userId}
  ├── Can read: Owner, Admin
  ├── Can write: Admin only
  └── Subcollections:
      ├── /coin_transactions
      └── /diamond_transactions

/withdrawals/{withdrawalId}
  ├── Can read: Owner, Admin
  ├── Can create: Authenticated (own withdrawal)
  └── Can update status: Admin only

/reports/{reportId}
  ├── Can create: Authenticated
  ├── Can read: Owner, Admin
  └── Can update: Admin only
```

## Step 8: Testing Rules

Use Firebase Emulator Suite for local testing:

```bash
# Install emulator
firebase setup:emulators:firestore
firebase setup:emulators:auth

# Start emulator
firebase emulators:start
```

Update `firebase_options.dart` for emulator:

```dart
if (kDebugMode) {
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

## Step 9: Monitor and Manage

### Firestore Monitoring:
1. Go to Firebase Console → Firestore Database
2. View "Usage" tab for real-time metrics
3. Check "Rules" tab for current rules

### Backup & Recovery:
```bash
# Export data
firebase firestore:delete --all --confirm

# Schedule automatic backups in Firebase Console
```

## Troubleshooting

### Permission Denied Error:
- Check if user is authenticated
- Verify user ID matches document ID
- Review Firestore rules for correct conditions

### Rules Not Updating:
```bash
# Clear cache and redeploy
firebase deploy --only firestore:rules --force
```

### Slow Queries:
- Check composite indexes are created
- View suggested indexes in Firebase Console
- Add missing indexes from `firebase.json`

## Production Deployment Checklist

- [ ] All Firestore rules deployed
- [ ] Indexes created and built
- [ ] Cloud Functions deployed
- [ ] Firebase Authentication configured
- [ ] Storage rules configured
- [ ] Backups scheduled
- [ ] Monitoring alerts set up
- [ ] Rate limiting configured
- [ ] Admin users assigned
- [ ] App signed and released

## Additional Resources

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/start)
- [Firebase Authentication Best Practices](https://firebase.google.com/docs/auth/best-practices)
- [Cloud Functions Guide](https://firebase.google.com/docs/functions)
- [Firestore Data Modeling](https://firebase.google.com/docs/firestore/data-model)
