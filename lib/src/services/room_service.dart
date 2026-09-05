import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/party_room_model.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PartyRoomModel>> getLiveRooms({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('party_rooms')
          .where('isLive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => PartyRoomModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting live rooms: $e');
      rethrow;
    }
  }

  Future<PartyRoomModel?> getRoomById(String roomId) async {
    try {
      final doc = await _firestore.collection('party_rooms').doc(roomId).get();
      if (doc.exists) {
        return PartyRoomModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting room: $e');
      rethrow;
    }
  }

  Future<PartyRoomModel> createRoom(String hostId, String title, String? cover) async {
    try {
      final roomRef = _firestore.collection('party_rooms').doc();
      final room = PartyRoomModel(
        roomId: roomRef.id,
        hostId: hostId,
        roomTitle: title,
        roomCover: cover,
        isLive: true,
        createdAt: DateTime.now(),
      );

      await roomRef.set(room.toFirestore());
      return room;
    } catch (e) {
      print('Error creating room: $e');
      rethrow;
    }
  }

  Future<void> endRoom(String roomId) async {
    try {
      await _firestore.collection('party_rooms').doc(roomId).update({
        'isLive': false,
        'endedAt': FieldValue.serverTimestamp(),
        'audience': [],
        'onlineCount': 0,
      });
    } catch (e) {
      print('Error ending room: $e');
      rethrow;
    }
  }

  Future<void> joinRoom(String roomId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final roomDoc = _firestore.collection('party_rooms').doc(roomId);
        final snapshot = await transaction.get(roomDoc);

        if (snapshot.exists) {
          final room = PartyRoomModel.fromFirestore(snapshot);
          final audience = List<String>.from(room.audience);
          if (!audience.contains(userId)) {
            audience.add(userId);
            transaction.update(roomDoc, {
              'audience': audience,
              'onlineCount': audience.length,
            });
          }
        }
      });
    } catch (e) {
      print('Error joining room: $e');
      rethrow;
    }
  }

  Future<void> leaveRoom(String roomId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final roomDoc = _firestore.collection('party_rooms').doc(roomId);
        final snapshot = await transaction.get(roomDoc);

        if (snapshot.exists) {
          final room = PartyRoomModel.fromFirestore(snapshot);
          final audience = List<String>.from(room.audience);
          audience.remove(userId);
          transaction.update(roomDoc, {
            'audience': audience,
            'onlineCount': audience.length,
          });
        }
      });
    } catch (e) {
      print('Error leaving room: $e');
      rethrow;
    }
  }

  Future<void> addCoHost(String roomId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final roomDoc = _firestore.collection('party_rooms').doc(roomId);
        final snapshot = await transaction.get(roomDoc);

        if (snapshot.exists) {
          final room = PartyRoomModel.fromFirestore(snapshot);
          final coHosts = List<String>.from(room.coHosts);
          if (!coHosts.contains(userId) && coHosts.length < room.maxSeats) {
            coHosts.add(userId);
            transaction.update(roomDoc, {'coHosts': coHosts});
          }
        }
      });
    } catch (e) {
      print('Error adding co-host: $e');
      rethrow;
    }
  }

  Future<void> removeCoHost(String roomId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final roomDoc = _firestore.collection('party_rooms').doc(roomId);
        final snapshot = await transaction.get(roomDoc);

        if (snapshot.exists) {
          final room = PartyRoomModel.fromFirestore(snapshot);
          final coHosts = List<String>.from(room.coHosts);
          coHosts.remove(userId);
          transaction.update(roomDoc, {'coHosts': coHosts});
        }
      });
    } catch (e) {
      print('Error removing co-host: $e');
      rethrow;
    }
  }

  Future<void> kickUser(String roomId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final roomDoc = _firestore.collection('party_rooms').doc(roomId);
        final snapshot = await transaction.get(roomDoc);

        if (snapshot.exists) {
          final room = PartyRoomModel.fromFirestore(snapshot);
          final audience = List<String>.from(room.audience);
          audience.remove(userId);
          transaction.update(roomDoc, {
            'audience': audience,
            'onlineCount': audience.length,
          });
        }
      });
    } catch (e) {
      print('Error kicking user: $e');
      rethrow;
    }
  }

  Future<void> updateRoomAnnouncement(String roomId, String announcement) async {
    try {
      await _firestore.collection('party_rooms').doc(roomId).update({
        'announcement': announcement,
      });
    } catch (e) {
      print('Error updating announcement: $e');
      rethrow;
    }
  }

  Future<void> recordGiftReceived(String roomId, int coinsAmount, int diamondsAmount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final roomDoc = _firestore.collection('party_rooms').doc(roomId);
        final snapshot = await transaction.get(roomDoc);

        if (snapshot.exists) {
          final room = PartyRoomModel.fromFirestore(snapshot);
          transaction.update(roomDoc, {
            'totalGiftsReceived': room.totalGiftsReceived + 1,
            'totalCoinsEarned': room.totalCoinsEarned + coinsAmount,
            'totalDiamondsEarned': room.totalDiamondsEarned + diamondsAmount,
          });
        }
      });
    } catch (e) {
      print('Error recording gift: $e');
      rethrow;
    }
  }
}
