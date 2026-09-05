import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int MIN_WITHDRAWAL = 100; // Minimum withdrawal amount

  Future<WalletModel> getWallet(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (doc.exists) {
        return WalletModel.fromFirestore(doc);
      }
      // Create default wallet if not exists
      final wallet = WalletModel(
        userId: userId,
        coinsBalance: 0,
        diamondsBalance: 0,
        lastUpdated: DateTime.now(),
      );
      await _firestore.collection('wallets').doc(userId).set(wallet.toFirestore());
      return wallet;
    } catch (e) {
      print('Error getting wallet: $e');
      rethrow;
    }
  }

  Future<void> addCoins(String userId, int amount, String reason) async {
    if (amount <= 0) throw Exception('Amount must be positive');

    try {
      await _firestore.runTransaction((transaction) async {
        final walletDoc = _firestore.collection('wallets').doc(userId);
        final snapshot = await transaction.get(walletDoc);

        if (snapshot.exists) {
          final wallet = WalletModel.fromFirestore(snapshot);
          final newBalance = wallet.coinsBalance + amount;
          final previousBalance = wallet.coinsBalance;

          // Update wallet
          transaction.update(walletDoc, {
            'coinsBalance': newBalance,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          // Record transaction
          final transactionId = _firestore.collection('coin_transactions').doc().id;
          transaction.set(
            _firestore.collection('coin_transactions').doc(transactionId),
            {
              'userId': userId,
              'amount': amount,
              'type': reason,
              'previousBalance': previousBalance,
              'newBalance': newBalance,
              'timestamp': FieldValue.serverTimestamp(),
              'status': 'success',
            },
          );
        }
      });
    } catch (e) {
      print('Error adding coins: $e');
      rethrow;
    }
  }

  Future<void> deductCoins(String userId, int amount, String reason) async {
    if (amount <= 0) throw Exception('Amount must be positive');

    try {
      await _firestore.runTransaction((transaction) async {
        final walletDoc = _firestore.collection('wallets').doc(userId);
        final snapshot = await transaction.get(walletDoc);

        if (snapshot.exists) {
          final wallet = WalletModel.fromFirestore(snapshot);
          if (wallet.coinsBalance < amount) {
            throw Exception('Insufficient coins balance');
          }

          final newBalance = wallet.coinsBalance - amount;
          final previousBalance = wallet.coinsBalance;

          // Update wallet
          transaction.update(walletDoc, {
            'coinsBalance': newBalance,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          // Record transaction
          final transactionId = _firestore.collection('coin_transactions').doc().id;
          transaction.set(
            _firestore.collection('coin_transactions').doc(transactionId),
            {
              'userId': userId,
              'amount': -amount,
              'type': reason,
              'previousBalance': previousBalance,
              'newBalance': newBalance,
              'timestamp': FieldValue.serverTimestamp(),
              'status': 'success',
            },
          );
        }
      });
    } catch (e) {
      print('Error deducting coins: $e');
      rethrow;
    }
  }

  Future<void> addDiamonds(String userId, int amount, String reason) async {
    if (amount <= 0) throw Exception('Amount must be positive');

    try {
      await _firestore.runTransaction((transaction) async {
        final walletDoc = _firestore.collection('wallets').doc(userId);
        final snapshot = await transaction.get(walletDoc);

        if (snapshot.exists) {
          final wallet = WalletModel.fromFirestore(snapshot);
          final newBalance = wallet.diamondsBalance + amount;

          transaction.update(walletDoc, {
            'diamondsBalance': newBalance,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error adding diamonds: $e');
      rethrow;
    }
  }

  Future<List<CoinTransactionModel>> getCoinTransactions(String userId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('coin_transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => CoinTransactionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting coin transactions: $e');
      rethrow;
    }
  }

  Future<void> requestWithdrawal(String userId, int amount, String paymentMethod, String accountDetails) async {
    if (amount < MIN_WITHDRAWAL) {
      throw Exception('Minimum withdrawal amount is $MIN_WITHDRAWAL diamonds');
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final walletDoc = _firestore.collection('wallets').doc(userId);
        final snapshot = await transaction.get(walletDoc);

        if (snapshot.exists) {
          final wallet = WalletModel.fromFirestore(snapshot);
          if (wallet.diamondsBalance < amount) {
            throw Exception('Insufficient diamonds balance');
          }

          // Create withdrawal record
          final withdrawalDoc = _firestore.collection('withdrawals').doc();
          transaction.set(withdrawalDoc, {
            'userId': userId,
            'amount': amount,
            'paymentMethod': paymentMethod,
            'accountDetails': accountDetails,
            'status': 'pending',
            'requestedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error requesting withdrawal: $e');
      rethrow;
    }
  }

  Future<List<WithdrawalModel>> getWithdrawals(String userId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('withdrawals')
          .where('userId', isEqualTo: userId)
          .orderBy('requestedAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => WithdrawalModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting withdrawals: $e');
      rethrow;
    }
  }
}
