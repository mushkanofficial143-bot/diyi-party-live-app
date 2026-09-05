import 'package:cloud_firestore/cloud_firestore.dart';

class GiftModel {
  final String giftId;
  final String giftName;
  final String giftIcon;
  final int coinPrice;
  final int diamondValue;
  final String? animation;
  final bool isActive;

  GiftModel({
    required this.giftId,
    required this.giftName,
    required this.giftIcon,
    required this.coinPrice,
    required this.diamondValue,
    this.animation,
    this.isActive = true,
  });

  factory GiftModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return GiftModel(
      giftId: doc.id,
      giftName: data['giftName'] ?? '',
      giftIcon: data['giftIcon'] ?? '',
      coinPrice: data['coinPrice'] ?? 0,
      diamondValue: data['diamondValue'] ?? 0,
      animation: data['animation'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'giftName': giftName,
      'giftIcon': giftIcon,
      'coinPrice': coinPrice,
      'diamondValue': diamondValue,
      'animation': animation,
      'isActive': isActive,
    };
  }
}

class GiftTransactionModel {
  final String transactionId;
  final String senderId;
  final String receiverId;
  final String giftId;
  final String roomId;
  final int coinAmount;
  final int diamondAmount;
  final int quantity;
  final DateTime sentAt;
  final String status; // 'success', 'pending', 'failed'

  GiftTransactionModel({
    required this.transactionId,
    required this.senderId,
    required this.receiverId,
    required this.giftId,
    required this.roomId,
    required this.coinAmount,
    required this.diamondAmount,
    required this.quantity,
    required this.sentAt,
    this.status = 'success',
  });

  factory GiftTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return GiftTransactionModel(
      transactionId: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      giftId: data['giftId'] ?? '',
      roomId: data['roomId'] ?? '',
      coinAmount: data['coinAmount'] ?? 0,
      diamondAmount: data['diamondAmount'] ?? 0,
      quantity: data['quantity'] ?? 1,
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'success',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'giftId': giftId,
      'roomId': roomId,
      'coinAmount': coinAmount,
      'diamondAmount': diamondAmount,
      'quantity': quantity,
      'sentAt': Timestamp.fromDate(sentAt),
      'status': status,
    };
  }
}
