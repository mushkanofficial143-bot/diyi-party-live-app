import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _firebaseUser != null && _userModel != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _firebaseUser = _firebaseAuth.currentUser;
    if (_firebaseUser != null) {
      await _loadUserModel();
    }
    notifyListeners();
  }

  Future<void> _loadUserModel() async {
    try {
      if (_firebaseUser != null) {
        _userModel = await _userService.getUserById(_firebaseUser!.uid);
      }
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> signUpWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement Google Sign In
      // final result = await GoogleSignIn().signIn();
      // final auth = await result?.authentication;
      // final credential = GoogleAuthProvider.credential(
      //   accessToken: auth?.accessToken,
      //   idToken: auth?.idToken,
      // );
      // final userCredential = await _firebaseAuth.signInWithCredential(credential);
      // _firebaseUser = userCredential.user;
      // await _createUserProfile();
      
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

  Future<bool> signUpWithPhone(String phone, Function(String) onCodeSent) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
          _firebaseUser = _firebaseAuth.currentUser;
          await _createUserProfile();
        },
        verificationFailed: (FirebaseAuthException e) {
          _error = e.message;
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyPhoneOTP(String verificationId, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      _firebaseUser = userCredential.user;
      await _createUserProfile();
      await _loadUserModel();
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

  Future<void> _createUserProfile() async {
    if (_firebaseUser != null) {
      final existingUser = await _userService.getUserById(_firebaseUser!.uid);
      if (existingUser == null) {
        final newUser = UserModel(
          userId: _firebaseUser!.uid,
          email: _firebaseUser!.email ?? '',
          phone: _firebaseUser!.phoneNumber,
          nickname: _firebaseUser!.displayName ?? 'User',
          profileImage: _firebaseUser!.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _userService.createUser(newUser);
        _userModel = newUser;
      }
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.signOut();
      _firebaseUser = null;
      _userModel = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
