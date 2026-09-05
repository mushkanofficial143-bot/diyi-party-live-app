import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String? phone;
  final String nickname;
  final String? profileImage;
  final String? bio;
  final String country;
  final int level;
  final int vipLevel;
  final int followers;
  final int following;
  final int coinsBalance;
  final int diamondsBalance;
  final bool isHost;
  final bool isAdmin;
  final bool isBanned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> blockedUsers;
  final String? authProvider; // 'google', 'phone', 'facebook'

  UserModel({
    required this.userId,
    required this.email,
    this.phone,
    required this.nickname,
    this.profileImage,
    this.bio,
    this.country = 'Unknown',
    this.level = 1,
    this.vipLevel = 0,
    this.followers = 0,
    this.following = 0,
    this.coinsBalance = 0,
    this.diamondsBalance = 0,
    this.isHost = false,
    this.isAdmin = false,
    this.isBanned = false,
    required this.createdAt,
    required this.updatedAt,
    this.blockedUsers = const [],
    this.authProvider,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      userId: doc.id,
      email: data['email'] ?? '',
      phone: data['phone'],
      nickname: data['nickname'] ?? 'User',
      profileImage: data['profileImage'],
      bio: data['bio'],
      country: data['country'] ?? 'Unknown',
      level: data['level'] ?? 1,
      vipLevel: data['vipLevel'] ?? 0,
      followers: data['followers'] ?? 0,
      following: data['following'] ?? 0,
      coinsBalance: data['coinsBalance'] ?? 0,
      diamondsBalance: data['diamondsBalance'] ?? 0,
      isHost: data['isHost'] ?? false,
      isAdmin: data['isAdmin'] ?? false,
      isBanned: data['isBanned'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      blockedUsers: List<String>.from(data['blockedUsers'] ?? []),
      authProvider: data['authProvider'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phone': phone,
      'nickname': nickname,
      'profileImage': profileImage,
      'bio': bio,
      'country': country,
      'level': level,
      'vipLevel': vipLevel,
      'followers': followers,
      'following': following,
      'coinsBalance': coinsBalance,
      'diamondsBalance': diamondsBalance,
      'isHost': isHost,
      'isAdmin': isAdmin,
      'isBanned': isBanned,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'blockedUsers': blockedUsers,
      'authProvider': authProvider,
    };
  }

  UserModel copyWith({
    String? nickname,
    String? profileImage,
    String? bio,
    String? country,
    int? level,
    int? vipLevel,
    int? followers,
    int? following,
    int? coinsBalance,
    int? diamondsBalance,
    bool? isHost,
    bool? isAdmin,
    bool? isBanned,
    List<String>? blockedUsers,
  }) {
    return UserModel(
      userId: userId,
      email: email,
      phone: phone,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      level: level ?? this.level,
      vipLevel: vipLevel ?? this.vipLevel,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      coinsBalance: coinsBalance ?? this.coinsBalance,
      diamondsBalance: diamondsBalance ?? this.diamondsBalance,
      isHost: isHost ?? this.isHost,
      isAdmin: isAdmin ?? this.isAdmin,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      blockedUsers: blockedUsers ?? this.blockedUsers,
      authProvider: authProvider,
    );
  }
}
