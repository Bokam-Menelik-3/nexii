import 'package:flutter/material.dart';
import '../core/services/i_firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final IFirebaseService _firebaseService;

  AuthProvider(this._firebaseService);

  Future<void> initialize() async {
    await _firebaseService.waitForInitialization();
    notifyListeners();
  }

  bool get isLoggedIn => _firebaseService.isLoggedIn;
  String? get uid => _firebaseService.uid;
  String? get email => _firebaseService.email;

  Future<bool> loginWithEmail(String email, String password) async {
    final success = await _firebaseService.signIn(email, password);
    notifyListeners();
    return success;
  }

  Future<bool> registerWithEmail(String email, String password) async {
    final success = await _firebaseService.signUp(email, password);
    notifyListeners();
    return success;
  }

  Future<bool> continueAsGuest() async {
    final success = await _firebaseService.signInAnonymously();
    notifyListeners();
    return success;
  }

  void logout() {
    _firebaseService.signOut();
    notifyListeners();
  }
}
