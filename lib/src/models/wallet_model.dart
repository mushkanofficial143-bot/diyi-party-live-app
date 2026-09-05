import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String userId;
  final int coinsBalance;
  final int diamondsBalance;
  final DateTime lastUpdated;

  WalletModel({
    required this.userId,
    required this.coinsBalance,
    required this.diamondsBalance,
    required this.lastUpdated,
  });

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return WalletModel(
      userId: doc.id,
      coinsBalance: data['coinsBalance'] ?? 0,
      diamondsBalance: data['diamondsBalance'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'coinsBalance': coinsBalance,
      'diamondsBalance': diamondsBalance,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

class CoinTransactionModel {
  final String transactionId;
  final String userId;
  final int amount;
  final String type; // 'recharge', 'gift', 'admin', 'refund'
  final String? relatedId; // gift_id, withdrawal_id, etc.
  final int previousBalance;
  final int newBalance;
  final DateTime timestamp;
  final String status; // 'success', 'pending', 'failed'

  CoinTransactionModel({
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.type,
    this.relatedId,
    required this.previousBalance,
    required this.newBalance,
    required this.timestamp,
    this.status = 'success',
  });

  factory CoinTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CoinTransactionModel(
      transactionId: doc.id,
      userId: data['userId'] ?? '',
      amount: data['amount'] ?? 0,
      type: data['type'] ?? 'unknown',
      relatedId: data['relatedId'],
      previousBalance: data['previousBalance'] ?? 0,
      newBalance: data['newBalance'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'success',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'type': type,
      'relatedId': relatedId,
      'previousBalance': previousBalance,
      'newBalance': newBalance,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }
}

class WithdrawalModel {
  final String withdrawalId;
  final String userId;
  final int amount;
  final String paymentMethod;
  final String accountDetails;
  final String status; // 'pending', 'approved', 'rejected', 'paid'
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? rejectionReason;
  final String? adminNotes;

  WithdrawalModel({
    required this.withdrawalId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.accountDetails,
    this.status = 'pending',
    required this.requestedAt,
    this.processedAt,
    this.rejectionReason,
    this.adminNotes,
  });

  factory WithdrawalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return WithdrawalModel(
      withdrawalId: doc.id,
      userId: data['userId'] ?? '',
      amount: data['amount'] ?? 0,
      paymentMethod: data['paymentMethod'] ?? 'bank',
      accountDetails: data['accountDetails'] ?? '',
      status: data['status'] ?? 'pending',
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processedAt: (data['processedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason'],
      adminNotes: data['adminNotes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'accountDetails': accountDetails,
      'status': status,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'rejectionReason': rejectionReason,
      'adminNotes': adminNotes,
    };
  }
}
