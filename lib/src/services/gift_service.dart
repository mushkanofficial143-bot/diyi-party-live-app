import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift_model.dart';

class GiftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<GiftModel>> getAvailableGifts() async {
    try {
      final snapshot = await _firestore
          .collection('gifts')
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => GiftModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting gifts: $e');
      rethrow;
    }
  }

  Future<void> sendGift({
    required String senderId,
    required String receiverId,
    required String giftId,
    required String roomId,
    required int quantity,
    required int coinCost,
    required int diamondValue,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Get sender wallet
        final senderWalletDoc = _firestore.collection('wallets').doc(senderId);
        final senderSnapshot = await transaction.get(senderWalletDoc);

        if (senderSnapshot.exists) {
          final senderBalance = senderSnapshot.get('coinsBalance') as int? ?? 0;
          final totalCost = coinCost * quantity;

          if (senderBalance < totalCost) {
            throw Exception('Insufficient coins');
          }

          // 2. Deduct from sender
          transaction.update(senderWalletDoc, {
            'coinsBalance': senderBalance - totalCost,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          // 3. Add to receiver
          final receiverWalletDoc = _firestore.collection('wallets').doc(receiverId);
          final receiverSnapshot = await transaction.get(receiverWalletDoc);
          if (receiverSnapshot.exists) {
            final receiverBalance = receiverSnapshot.get('diamondsBalance') as int? ?? 0;
            final totalDiamonds = diamondValue * quantity;
            transaction.update(receiverWalletDoc, {
              'diamondsBalance': receiverBalance + totalDiamonds,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }

          // 4. Record transaction
          final transactionId = _firestore.collection('gift_transactions').doc().id;
          transaction.set(
            _firestore.collection('gift_transactions').doc(transactionId),
            {
              'senderId': senderId,
              'receiverId': receiverId,
              'giftId': giftId,
              'roomId': roomId,
              'coinAmount': totalCost,
              'diamondAmount': totalDiamonds,
              'quantity': quantity,
              'sentAt': FieldValue.serverTimestamp(),
              'status': 'success',
            },
          );
        }
      });
    } catch (e) {
      print('Error sending gift: $e');
      rethrow;
    }
  }

  Future<List<GiftTransactionModel>> getReceivedGifts(String userId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('gift_transactions')
          .where('receiverId', isEqualTo: userId)
          .orderBy('sentAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => GiftTransactionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting received gifts: $e');
      rethrow;
    }
  }

  Future<List<GiftTransactionModel>> getSentGifts(String userId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('gift_transactions')
          .where('senderId', isEqualTo: userId)
          .orderBy('sentAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => GiftTransactionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting sent gifts: $e');
      rethrow;
    }
  }
}
