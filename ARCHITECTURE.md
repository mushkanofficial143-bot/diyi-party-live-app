# Architecture Overview - Diyo Party Live App

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase config
└── src/
    ├── config/
    │   ├── routes/
    │   │   └── app_router.dart       # Navigation routing
    │   └── theme/
    │       └── app_theme.dart        # Theme & styling
    │
    ├── models/                        # Data models
    │   ├── user_model.dart
    │   ├── wallet_model.dart
    │   ├── party_room_model.dart
    │   └── gift_model.dart
    │
    ├── services/                      # Business logic
    │   ├── user_service.dart
    │   ├── wallet_service.dart
    │   ├── room_service.dart
    │   ├── gift_service.dart
    │   └── payment_service.dart
    │
    ├── providers/                     # State management
    │   ├── auth_provider.dart
    │   ├── wallet_provider.dart
    │   ├── room_provider.dart
    │   └── payment_provider.dart
    │
    └── screens/                       # UI screens
        ├── auth/
        │   ├── login_screen.dart
        │   └── phone_otp_screen.dart
        │
        ├── home/
        │   └── home_screen.dart
        │
        ├── profile/
        │   └── profile_screen.dart
        │
        ├── party_room/
        │   └── party_room_screen.dart
        │
        ├── wallet/
        │   ├── wallet_screen.dart
        │   ├── coin_recharge_screen.dart
        │   └── withdrawal_screen.dart
        │
        └── admin/
            └── admin_dashboard.dart
```

## Technology Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider 6.x
- **Navigation**: GoRouter / Flutter Navigator
- **UI Components**: Material 3 Design

### Backend
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth (Phone + Google)
- **Cloud Functions**: Node.js 20 (Firebase)
- **Storage**: Firebase Cloud Storage
- **Payment**: Google Play Billing 6.1

### Development Tools
- **Version Control**: Git + GitHub
- **CI/CD**: GitHub Actions (optional)
- **Code Quality**: Flutter Analyzer
- **Testing**: Flutter Test Framework

## Core Features

### 1. Authentication System
- Phone number login with OTP
- Google sign-in
- Role-based access (user, host, admin)
- Session management

### 2. Party Rooms
- Live streaming functionality
- Real-time chat messaging
- Co-host management
- Gift sending system
- User moderation (kick/block)

### 3. Wallet System
- Coins: In-app currency for purchases
- Diamonds: Premium currency from gifts
- Multiple payment methods
- Transaction history
- Withdrawal requests

### 4. Payment Integration
- Google Play Billing
- 6 coin packages with bonuses
- Receipt verification
- Transaction logging
- Purchase history

### 5. Gift System
- Multiple gift types
- Coin-based sending
- Host earnings
- Gift history tracking
- Animation support

### 6. Admin Dashboard
- User management
- Withdrawal approvals
- Content moderation
- Report management
- Analytics & monitoring

## Data Flow

### Purchase Flow
```
User selects package
    ↓
Initiate Google Play purchase
    ↓
User completes payment in Play Store
    ↓
Payment service receives confirmation
    ↓
Verify receipt with Google Play
    ↓
Server-side verification (Cloud Function)
    ↓
Update user wallet (Firestore)
    ↓
Log transaction
    ↓
Show success notification
```

### Gift Flow
```
Sender views gift options
    ↓
Selects gift & recipient
    ↓
Confirms transaction
    ↓
Deduct coins from sender wallet
    ↓
Add diamonds to receiver wallet
    ↓
Create transaction record
    ↓
Show gift animation
    ↓
Notify receiver
```

### Withdrawal Flow
```
User requests withdrawal
    ↓
Validate amount (≥100 diamonds)
    ↓
Create withdrawal request in Firestore
    ↓
Notify admin
    ↓
Admin reviews & approves/rejects
    ↓
If approved: Transfer to payment account
    ↓
Update withdrawal status
    ↓
Notify user
```

## Security Architecture

### Authentication
- Firebase Auth manages credentials
- Phone verification via SMS
- JWT token-based sessions
- Role-based access control

### Authorization
- Firestore Rules enforce permissions
- Users only access their data
- Admins can access all data
- Field-level access control

### Data Protection
- Encryption in transit (HTTPS)
- Firestore security rules
- Payment token validation
- Server-side receipt verification
- Fraud detection

### Audit Trail
- All transactions logged
- Admin actions recorded
- Change history maintained
- Compliance with payment regulations

## Performance Optimization

### Frontend
- Lazy loading of screens
- Provider-based state caching
- Optimized image loading
- Efficient list rendering

### Backend
- Firestore indexes on key fields
- Batch operations for bulk updates
- Cloud Function optimization
- CDN for media files

### Network
- Request/response compression
- Caching strategies
- Pagination for large datasets
- Efficient subscription listeners

## Error Handling

### Network Errors
- Retry logic with exponential backoff
- Offline mode support
- Graceful degradation
- User-friendly error messages

### Business Logic Errors
- Input validation
- Transaction rollback on failure
- Duplicate purchase prevention
- Insufficient balance checks

### System Errors
- Error logging & monitoring
- Admin notifications
- Auto-recovery mechanisms
- Fallback services

## Scalability Considerations

- Horizontal scaling via Cloud Functions
- Firestore auto-scaling
- Sharded user collections (if needed)
- CDN for static assets
- Load balancing for APIs

## Deployment Pipeline

### Development
```bash
flutter run         # Local testing
flutter test        # Unit tests
```

### Staging
```bash
flutter build apk --debug     # Debug APK
flutter build appbundle       # App Bundle
# Upload to internal testing track
```

### Production
```bash
flutter build appbundle --release  # Release bundle
# Upload to Google Play Console
# Run staged rollout
# Monitor crash rates & reviews
```

## Monitoring & Analytics

### User Metrics
- DAU (Daily Active Users)
- Retention rate
- Purchase conversion
- Session duration

### Performance Metrics
- App startup time
- Screen load time
- API response time
- Crash rate

### Business Metrics
- Revenue per user
- Average transaction value
- Withdrawal rate
- User satisfaction (ratings)

## Future Enhancements

- [ ] Video streaming optimization
- [ ] Real-time voice chat
- [ ] Multiple language support
- [ ] Social features (follow, DM)
- [ ] Advanced analytics dashboard
- [ ] Machine learning recommendations
- [ ] Blockchain integration (optional)
- [ ] Web platform expansion

## Contact & Support

- **Developer**: Mr Salam
- **Email**: mushkanofficial143@gmail.com
- **Repository**: [GitHub](https://github.com/mushkanofficial143-bot/diyi-party-live-app)
