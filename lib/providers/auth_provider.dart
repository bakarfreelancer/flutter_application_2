import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/user_storage.dart';

// AuthProvider is the "brain" of authentication.
// It keeps track of whether the user is logged in or not,
// and makes that information available to any screen in the app.
// Just like CartProvider manages the cart, AuthProvider manages auth state.
class AuthProvider extends ChangeNotifier {
  // Private fields — only this class can modify them
  bool _isLoggedIn = false;
  String _email = '';
  String _token = '';

  // Public getters — any widget can read these
  bool get isLoggedIn => _isLoggedIn;
  String get email => _email;
  String get token => _token;

  // ─── CHECK SAVED TOKEN ────────────────────────────────────────────────────
  // Called from SplashScreen on app startup.
  // Looks for a previously saved token in SharedPreferences.
  // If found, the user is considered already logged in.
  Future<void> checkAuthStatus() async {
    final token = await UserStorage.getToken();
    final email = await UserStorage.getEmail();

    if (token.isNotEmpty) {
      // Token exists → user was logged in before → restore their session
      _token = token;
      _email = email;
      _isLoggedIn = true;
      notifyListeners(); // update any listening widgets
    }
  }

  // ─── LOGIN ────────────────────────────────────────────────────────────────
  // Called after a successful API login response.
  // Saves the token to storage and updates the state.
  Future<void> login(String email, String token) async {
    // Save to SharedPreferences so it persists after app restart
    await UserStorage.saveToken(token: token, email: email);

    // Update in-memory state
    _token = token;
    _email = email;
    _isLoggedIn = true;

    notifyListeners(); // 🔔 tell all listeners the user is now logged in
  }

  // ─── LOGOUT ───────────────────────────────────────────────────────────────
  // Called from the ProfileScreen logout button.
  // Clears the token from storage and resets the state.
  Future<void> logout() async {
    // Remove token from SharedPreferences
    await UserStorage.clearAuth();

    // Reset in-memory state
    _token = '';
    _email = '';
    _isLoggedIn = false;

    notifyListeners(); // 🔔 tell all listeners the user is now logged out
  }
}
