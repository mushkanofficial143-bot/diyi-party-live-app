import 'package:flutter/material.dart';
import '../models/party_room_model.dart';
import '../services/room_service.dart';

class RoomProvider extends ChangeNotifier {
  final RoomService _roomService = RoomService();

  List<PartyRoomModel> _liveRooms = [];
  PartyRoomModel? _currentRoom;
  bool _isLoading = false;
  String? _error;

  List<PartyRoomModel> get liveRooms => _liveRooms;
  PartyRoomModel? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLiveRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _liveRooms = await _roomService.getLiveRooms();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRoomById(String roomId) async {
    try {
      _currentRoom = await _roomService.getRoomById(roomId);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createRoom(String hostId, String title, String? cover) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentRoom = await _roomService.createRoom(hostId, title, cover);
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

  Future<bool> endRoom(String roomId) async {
    try {
      await _roomService.endRoom(roomId);
      _currentRoom = null;
      await loadLiveRooms();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinRoom(String roomId, String userId) async {
    try {
      await _roomService.joinRoom(roomId, userId);
      await loadRoomById(roomId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveRoom(String roomId, String userId) async {
    try {
      await _roomService.leaveRoom(roomId, userId);
      _currentRoom = null;
      await loadLiveRooms();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
