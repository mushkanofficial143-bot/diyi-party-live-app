import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  static const String _androidPlayVersion = '6.1.0';
  
  late InAppPurchase _inAppPurchase;
  late FirebaseFirestore _firestore;
  
  // Product IDs for coins packages
  static const Map<String, int> coinPackages = {
    'coins_100': 100,
    'coins_500': 500,
    'coins_1000': 1000,
    'coins_5000': 5000,
    'coins_10000': 10000,
    'coins_50000': 50000,
  };
  
  // Bonus coins mapping
  static const Map<String, int> bonusCoins = {
    'coins_100': 0,
    'coins_500': 50,
    'coins_1000': 200,
    'coins_5000': 1000,
    'coins_10000': 2500,
    'coins_50000': 15000,
  };
  
  factory PaymentService() {
    return _instance;
  }
  
  PaymentService._internal() {
    _inAppPurchase = InAppPurchase.instance;
    _firestore = FirebaseFirestore.instance;
  }
  
  /// Initialize payment service
  Future<bool> initialize() async {
    try {
      // Initialize Android IAP
      if (defaultTargetPlatform == TargetPlatform.android) {
        InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
      }
      
      // Check if IAP is available
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        print('In-App Purchase is not available');
        return false;
      }
      
      print('Payment Service initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing payment service: $e');
      return false;
    }
  }
  
  /// Get available products
  Future<List<ProductDetails>> getAvailableProducts() async {
    try {
      final productIds = coinPackages.keys.toSet();
      final productDetails = await _inAppPurchase.queryProductDetails(productIds);
      
      if (productDetails.error != null) {
        print('Error fetching products: ${productDetails.error}');
        return [];
      }
      
      return productDetails.productDetails;
    } catch (e) {
      print('Error getting available products: $e');
      return [];
    }
  }
  
  /// Purchase coins package
  Future<bool> purchaseCoins(
    String productId,
    String userId,
  ) async {
    try {
      // Validate product ID
      if (!coinPackages.containsKey(productId)) {
        print('Invalid product ID: $productId');
        return false;
      }
      
      // Get product details
      final products = await getAvailableProducts();
      final product = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );
      
      // Initiate purchase
      final purchaseParam = PurchaseParam(productDetails: product);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      return true;
    } catch (e) {
      print('Error initiating purchase: $e');
      return false;
    }
  }
  
  /// Listen to purchase updates
  Stream<List<PurchaseDetails>> getPurchaseUpdates() {
    return _inAppPurchase.purchaseStream;
  }
  
  /// Handle purchase completion
  Future<bool> handlePurchaseUpdate(
    PurchaseDetails purchase,
    String userId,
  ) async {
    try {
      if (purchase.pendingCompleteMark) {
        // Mark purchase as complete
        await _inAppPurchase.completePurchase(purchase);
      }
      
      // Verify purchase validity
      final isValid = await _verifyPurchase(purchase);
      if (!isValid) {
        print('Purchase verification failed');
        return false;
      }
      
      // Process purchase on backend
      if (purchase.status == PurchaseStatus.purchased) {
        return await _processPurchase(purchase, userId);
      } else if (purchase.status == PurchaseStatus.restored) {
        return await _processPurchase(purchase, userId);
      } else if (purchase.status == PurchaseStatus.canceled) {
        print('Purchase canceled by user');
        return false;
      } else if (purchase.status == PurchaseStatus.error) {
        print('Purchase error: ${purchase.error}');
        return false;
      }
      
      return false;
    } catch (e) {
      print('Error handling purchase update: $e');
      return false;
    }
  }
  
  /// Verify purchase with Google Play
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      if (purchase.verificationData.localVerificationData.isEmpty) {
        print('Verification data is empty');
        return false;
      }
      
      // For production, verify with Google Play Billing Library
      // This is a basic check - implement server-side verification for security
      return purchase.verificationData.localVerificationData.isNotEmpty;
    } catch (e) {
      print('Error verifying purchase: $e');
      return false;
    }
  }
  
  /// Process purchase and credit coins
  Future<bool> _processPurchase(
    PurchaseDetails purchase,
    String userId,
  ) async {
    try {
      final productId = purchase.productID;
      final coins = coinPackages[productId] ?? 0;
      final bonus = bonusCoins[productId] ?? 0;
      final totalCoins = coins + bonus;
      
      // Create transaction record
      final transactionRef = _firestore.collection('transactions').doc();
      await transactionRef.set({
        'userId': userId,
        'type': 'coin_purchase',
        'productId': productId,
        'coins': coins,
        'bonus': bonus,
        'totalCoins': totalCoins,
        'purchaseToken': purchase.purchaseID,
        'price': purchase.billingClientPurchase?.originalJson ?? '',
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Update wallet
      final walletRef = _firestore.collection('wallets').doc(userId);
      await walletRef.update({
        'coinsBalance': FieldValue.increment(totalCoins),
        'totalCoinsEarned': FieldValue.increment(totalCoins),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Log transaction
      print('Purchase processed: $productId - $totalCoins coins (including $bonus bonus)');
      return true;
    } catch (e) {
      print('Error processing purchase: $e');
      return false;
    }
  }
  
  /// Restore previous purchases
  Future<bool> restorePurchases(String userId) async {
    try {
      await _inAppPurchase.restorePurchases();
      print('Purchases restored for user: $userId');
      return true;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }
  
  /// Get purchase history
  Future<List<Map<String, dynamic>>> getPurchaseHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'coin_purchase')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching purchase history: $e');
      return [];
    }
  }
  
  /// Check if device supports billing
  Future<bool> isBillingSupported() async {
    try {
      return await _inAppPurchase.isAvailable();
    } catch (e) {
      print('Error checking billing support: $e');
      return false;
    }
  }
  
  /// Get coin package details
  static Map<String, dynamic> getCoinPackageDetails(String productId) {
    if (!coinPackages.containsKey(productId)) {
      return {};
    }
    
    return {
      'productId': productId,
      'coins': coinPackages[productId],
      'bonus': bonusCoins[productId],
      'total': (coinPackages[productId] ?? 0) + (bonusCoins[productId] ?? 0),
    };
  }
  
  /// Calculate coin value (USD to coins conversion)
  static double getCoinValue(int coins) {
    // Price per coin varies based on package
    // Standard: $0.99 for 100 coins = $0.0099 per coin
    // But larger packages offer better rates
    const basePrice = 0.99;
    const baseCoins = 100.0;
    return basePrice / baseCoins;
  }
}
