import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/services/firebase_service.dart';

// AuthProvider — Lecture 23 (Firebase Auth)
//
// Previously (Lectures 05–13): stored a token string from the reqres.in API.
// Now: listens to Firebase Auth's authStateChanges stream.
//
// The key difference:
//   Before → we manually saved/loaded a token from SharedPreferences.
//   Now    → Firebase handles token persistence automatically.
//            We just listen to the stream and react to changes.
class AuthProvider extends ChangeNotifier {
  // The Firebase User object — null when logged out, non-null when logged in.
  // All user info (email, uid) comes from here.
  User? _firebaseUser;

  bool get isLoggedIn => _firebaseUser != null;
  String get email => _firebaseUser?.email ?? '';

  // uid (unique ID) is the key used to identify this user in Firestore.
  // Every Firebase user gets a unique uid automatically.
  String get uid => _firebaseUser?.uid ?? '';

  AuthProvider() {
    // authStateChanges is a stream — it fires:
    //   - immediately with the current user (or null) on app start
    //   - whenever the user signs in or out
    // This replaces the old checkAuthStatus() + SharedPreferences approach.
    FirebaseService.instance.authStateChanges.listen((user) {
      _firebaseUser = user;
      notifyListeners(); // rebuild any listening widgets
    });
  }

  // Sign in with email and password.
  // Returns null on success, or an error message string on failure.
  // The caller (LoginScreen) shows the error in a SnackBar if non-null.
  Future<String?> login(String email, String password) {
    return FirebaseService.instance.signIn(email, password);
  }

  // Register a new account.
  Future<String?> register(String email, String password) {
    return FirebaseService.instance.register(email, password);
  }

  // Sign out. Firebase clears the cached token.
  // authStateChanges will fire with null → isLoggedIn becomes false.
  Future<void> logout() => FirebaseService.instance.signOut();
}
