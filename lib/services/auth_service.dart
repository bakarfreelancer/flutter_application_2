import 'dart:convert'; // jsonEncode, jsonDecode
import 'package:http/http.dart' as http;

// AuthService handles all network calls related to authentication.
// We use reqres.in — a free fake API that behaves like a real auth server.
// Great for learning without needing to build a backend.
class AuthService {
  // Base URL for all requests
  static const String _baseUrl = 'https://reqres.in/api';

  // ─── LOGIN ────────────────────────────────────────────────────────────────
  // Sends email + password to the server.
  // Returns a Map with either { 'success': true, 'token': '...' }
  //                        or  { 'success': false, 'error': '...' }
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        // Tell the server we are sending JSON data
        headers: {'Content-Type': 'application/json'},
        // Convert the Dart map to a JSON string
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Decode the JSON response back into a Dart map
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login successful — server returns a token
        return {'success': true, 'token': data['token']};
      } else {
        // Login failed — server returns an error message
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      // Network error (no internet, timeout, etc.)
      return {'success': false, 'error': 'Network error. Check your connection.'};
    }
  }

  // ─── REGISTER ─────────────────────────────────────────────────────────────
  // Registers a new account with email + password.
  // Returns same format as login.
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Register successful — server returns id + token
        return {'success': true, 'token': data['token']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error. Check your connection.'};
    }
  }
}
