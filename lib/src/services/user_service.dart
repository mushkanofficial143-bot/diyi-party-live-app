import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.userId).set(user.toFirestore());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.userId).update(user.toFirestore());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('nickname', isGreaterThanOrEqualTo: query)
          .where('nickname', isLessThan: query + 'z')
          .limit(10)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error searching users: $e');
      rethrow;
    }
  }

  Future<void> followUser(String userId, String targetUserId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(_firestore.collection('users').doc(userId));
        final targetDoc = await transaction.get(_firestore.collection('users').doc(targetUserId));

        if (userDoc.exists && targetDoc.exists) {
          final following = List<String>.from(userDoc['following'] ?? []);
          if (!following.contains(targetUserId)) {
            following.add(targetUserId);
            transaction.update(
              _firestore.collection('users').doc(userId),
              {'following': following, 'updatedAt': FieldValue.serverTimestamp()},
            );

            final followers = List<String>.from(targetDoc['followers'] ?? []);
            followers.add(userId);
            transaction.update(
              _firestore.collection('users').doc(targetUserId),
              {'followers': followers, 'updatedAt': FieldValue.serverTimestamp()},
            );
          }
        }
      });
    } catch (e) {
      print('Error following user: $e');
      rethrow;
    }
  }

  Future<void> unfollowUser(String userId, String targetUserId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(_firestore.collection('users').doc(userId));
        final targetDoc = await transaction.get(_firestore.collection('users').doc(targetUserId));

        if (userDoc.exists && targetDoc.exists) {
          final following = List<String>.from(userDoc['following'] ?? []);
          following.remove(targetUserId);
          transaction.update(
            _firestore.collection('users').doc(userId),
            {'following': following, 'updatedAt': FieldValue.serverTimestamp()},
          );

          final followers = List<String>.from(targetDoc['followers'] ?? []);
          followers.remove(userId);
          transaction.update(
            _firestore.collection('users').doc(targetUserId),
            {'followers': followers, 'updatedAt': FieldValue.serverTimestamp()},
          );
        }
      });
    } catch (e) {
      print('Error unfollowing user: $e');
      rethrow;
    }
  }

  Future<void> blockUser(String userId, String blockedUserId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(_firestore.collection('users').doc(userId));
        if (userDoc.exists) {
          final blockedUsers = List<String>.from(userDoc['blockedUsers'] ?? []);
          if (!blockedUsers.contains(blockedUserId)) {
            blockedUsers.add(blockedUserId);
            transaction.update(
              _firestore.collection('users').doc(userId),
              {'blockedUsers': blockedUsers, 'updatedAt': FieldValue.serverTimestamp()},
            );
          }
        }
      });
    } catch (e) {
      print('Error blocking user: $e');
      rethrow;
    }
  }

  Future<void> unblockUser(String userId, String unblockedUserId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(_firestore.collection('users').doc(userId));
        if (userDoc.exists) {
          final blockedUsers = List<String>.from(userDoc['blockedUsers'] ?? []);
          blockedUsers.remove(unblockedUserId);
          transaction.update(
            _firestore.collection('users').doc(userId),
            {'blockedUsers': blockedUsers, 'updatedAt': FieldValue.serverTimestamp()},
          );
        }
      });
    } catch (e) {
      print('Error unblocking user: $e');
      rethrow;
    }
  }
}
