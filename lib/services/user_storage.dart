import 'package:shared_preferences/shared_preferences.dart';

// UserStorage is a helper class that handles all read/write
// operations for user data using SharedPreferences.
// We keep all storage logic here so screens stay clean.
class UserStorage {
  // Keys used to store/retrieve values — kept as constants to avoid typos
  static const String _keyName = 'user_name';
  static const String _keyContact = 'user_contact';
  static const String _keyAddress = 'user_address';

  // Save user data to local storage
  static Future<void> saveUser({
    required String name,
    required String contact,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyContact, contact);
    await prefs.setString(_keyAddress, address);
  }

  // Read user data from local storage
  // Returns a Map with keys: 'name', 'contact', 'address'
  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? '',
      'contact': prefs.getString(_keyContact) ?? '',
      'address': prefs.getString(_keyAddress) ?? '',
    };
  }

  // Returns true if the user has already filled in their info
  static Future<bool> hasUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyName) ?? '';
    return name.isNotEmpty;
  }
}
