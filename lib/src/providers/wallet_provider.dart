import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _walletService = WalletService();

  WalletModel? _wallet;
  List<CoinTransactionModel> _coinTransactions = [];
  List<WithdrawalModel> _withdrawals = [];
  bool _isLoading = false;
  String? _error;

  WalletModel? get wallet => _wallet;
  List<CoinTransactionModel> get coinTransactions => _coinTransactions;
  List<WithdrawalModel> get withdrawals => _withdrawals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWallet(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallet = await _walletService.getWallet(userId);
      await loadCoinTransactions(userId);
      await loadWithdrawals(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCoinTransactions(String userId) async {
    try {
      _coinTransactions = await _walletService.getCoinTransactions(userId);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadWithdrawals(String userId) async {
    try {
      _withdrawals = await _walletService.getWithdrawals(userId);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> addCoins(String userId, int amount, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _walletService.addCoins(userId, amount, reason);
      await loadWallet(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deductCoins(String userId, int amount, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _walletService.deductCoins(userId, amount, reason);
      await loadWallet(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestWithdrawal(String userId, int amount, String paymentMethod, String accountDetails) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _walletService.requestWithdrawal(userId, amount, paymentMethod, accountDetails);
      await loadWithdrawals(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
