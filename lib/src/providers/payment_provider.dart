import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  
  bool _isInitialized = false;
  bool _isProcessing = false;
  List<ProductDetails> _availableProducts = [];
  String? _error;
  bool _purchaseSuccess = false;
  
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  List<ProductDetails> get availableProducts => _availableProducts;
  String? get error => _error;
  bool get purchaseSuccess => _purchaseSuccess;
  
  PaymentProvider() {
    _initialize();
  }
  
  /// Initialize payment service
  Future<void> _initialize() async {
    try {
      _isInitialized = await _paymentService.initialize();
      if (_isInitialized) {
        await _loadAvailableProducts();
        _listenToPurchaseUpdates();
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize payments: $e';
      notifyListeners();
    }
  }
  
  /// Load available products from Google Play
  Future<void> _loadAvailableProducts() async {
    try {
      _availableProducts = await _paymentService.getAvailableProducts();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load products: $e';
      notifyListeners();
    }
  }
  
  /// Listen to purchase updates
  void _listenToPurchaseUpdates() {
    _paymentService.getPurchaseUpdates().listen(
      (purchases) {
        for (final purchase in purchases) {
          _handlePurchaseUpdate(purchase);
        }
      },
      onError: (error) {
        _error = 'Purchase stream error: $error';
        notifyListeners();
      },
    );
  }
  
  /// Handle individual purchase update
  void _handlePurchaseUpdate(PurchaseDetails purchase) async {
    // This should be called from the main app to process purchases
    // Handled in the purchase method below
  }
  
  /// Initiate coin purchase
  Future<bool> purchaseCoins(String productId, String userId) async {
    try {
      _isProcessing = true;
      _error = null;
      _purchaseSuccess = false;
      notifyListeners();
      
      // Initiate purchase
      final success = await _paymentService.purchaseCoins(productId, userId);
      
      if (!success) {
        _error = 'Failed to initiate purchase';
      }
      
      _isProcessing = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Purchase error: $e';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Process purchase after verification
  Future<bool> processPurchase(
    PurchaseDetails purchase,
    String userId,
  ) async {
    try {
      final success = await _paymentService.handlePurchaseUpdate(purchase, userId);
      
      if (success) {
        _purchaseSuccess = true;
      } else {
        _error = 'Failed to process purchase';
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error processing purchase: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Restore previous purchases
  Future<bool> restorePurchases(String userId) async {
    try {
      _isProcessing = true;
      notifyListeners();
      
      final success = await _paymentService.restorePurchases(userId);
      
      _isProcessing = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Failed to restore purchases: $e';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Get product details
  ProductDetails? getProductDetails(String productId) {
    try {
      return _availableProducts.firstWhere(
        (product) => product.id == productId,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Get purchase history
  Future<List<Map<String, dynamic>>> getPurchaseHistory(String userId) async {
    try {
      return await _paymentService.getPurchaseHistory(userId);
    } catch (e) {
      _error = 'Failed to load purchase history: $e';
      notifyListeners();
      return [];
    }
  }
  
  /// Check if billing is supported
  Future<bool> isBillingSupported() async {
    try {
      return await _paymentService.isBillingSupported();
    } catch (e) {
      return false;
    }
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Reset purchase success flag
  void resetPurchaseSuccess() {
    _purchaseSuccess = false;
    notifyListeners();
  }
}
