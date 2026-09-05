import 'package:cloud_firestore/cloud_firestore.dart';

class PartyRoomModel {
  final String roomId;
  final String hostId;
  final String roomTitle;
  final String? roomCover;
  final String category;
  final int maxSeats;
  final List<String> coHosts;
  final List<String> audience;
  final int onlineCount;
  final bool isLive;
  final DateTime createdAt;
  final DateTime? endedAt;
  final String? announcement;
  final int totalGiftsReceived;
  final int totalCoinsEarned;
  final int totalDiamondsEarned;
  final Map<String, dynamic> roomSettings;

  PartyRoomModel({
    required this.roomId,
    required this.hostId,
    required this.roomTitle,
    this.roomCover,
    this.category = 'General',
    this.maxSeats = 8,
    this.coHosts = const [],
    this.audience = const [],
    this.onlineCount = 0,
    this.isLive = false,
    required this.createdAt,
    this.endedAt,
    this.announcement,
    this.totalGiftsReceived = 0,
    this.totalCoinsEarned = 0,
    this.totalDiamondsEarned = 0,
    this.roomSettings = const {},
  });

  factory PartyRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PartyRoomModel(
      roomId: doc.id,
      hostId: data['hostId'] ?? '',
      roomTitle: data['roomTitle'] ?? 'Untitled Room',
      roomCover: data['roomCover'],
      category: data['category'] ?? 'General',
      maxSeats: data['maxSeats'] ?? 8,
      coHosts: List<String>.from(data['coHosts'] ?? []),
      audience: List<String>.from(data['audience'] ?? []),
      onlineCount: data['onlineCount'] ?? 0,
      isLive: data['isLive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
      announcement: data['announcement'],
      totalGiftsReceived: data['totalGiftsReceived'] ?? 0,
      totalCoinsEarned: data['totalCoinsEarned'] ?? 0,
      totalDiamondsEarned: data['totalDiamondsEarned'] ?? 0,
      roomSettings: data['roomSettings'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hostId': hostId,
      'roomTitle': roomTitle,
      'roomCover': roomCover,
      'category': category,
      'maxSeats': maxSeats,
      'coHosts': coHosts,
      'audience': audience,
      'onlineCount': onlineCount,
      'isLive': isLive,
      'createdAt': Timestamp.fromDate(createdAt),
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'announcement': announcement,
      'totalGiftsReceived': totalGiftsReceived,
      'totalCoinsEarned': totalCoinsEarned,
      'totalDiamondsEarned': totalDiamondsEarned,
      'roomSettings': roomSettings,
    };
  }

  PartyRoomModel copyWith({
    String? roomTitle,
    String? roomCover,
    int? onlineCount,
    bool? isLive,
    DateTime? endedAt,
    String? announcement,
    int? totalGiftsReceived,
    int? totalCoinsEarned,
    int? totalDiamondsEarned,
    List<String>? coHosts,
    List<String>? audience,
  }) {
    return PartyRoomModel(
      roomId: roomId,
      hostId: hostId,
      roomTitle: roomTitle ?? this.roomTitle,
      roomCover: roomCover ?? this.roomCover,
      category: category,
      maxSeats: maxSeats,
      coHosts: coHosts ?? this.coHosts,
      audience: audience ?? this.audience,
      onlineCount: onlineCount ?? this.onlineCount,
      isLive: isLive ?? this.isLive,
      createdAt: createdAt,
      endedAt: endedAt ?? this.endedAt,
      announcement: announcement ?? this.announcement,
      totalGiftsReceived: totalGiftsReceived ?? this.totalGiftsReceived,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      totalDiamondsEarned: totalDiamondsEarned ?? this.totalDiamondsEarned,
      roomSettings: roomSettings,
    );
  }
}
