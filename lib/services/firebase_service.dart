import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  FirebaseService — Lecture 23
//
//  A singleton that wraps two Firebase products:
//    1. Firebase Auth    — sign in, register, sign out
//    2. Cloud Firestore  — save and load user profile data
//
//  Singleton pattern: same as CartDatabase (Lecture 19) and
//  NotificationService (Lecture 20). One shared instance for the whole app.
// ─────────────────────────────────────────────────────────────────────────────
class FirebaseService {
  FirebaseService._internal();
  static final FirebaseService instance = FirebaseService._internal();

  // Firebase SDK handles authentication state persistence automatically.
  // You never have to save a token to SharedPreferences — Firebase does it.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore is a cloud NoSQL database.
  // Data is organised as: Collection → Document → Fields
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Auth ───────────────────────────────────────────────────────────────────

  // A stream that fires whenever the auth state changes:
  //   → null  : user signed out
  //   → User  : user signed in
  // Used in AuthProvider to keep the app in sync automatically.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // The currently signed-in user (null if logged out)
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password.
  // Returns null on success, or a readable error message on failure.
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  // Create a new account with email and password.
  // Returns null on success, or a readable error message on failure.
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  // Sign out the current user.
  // After this, authStateChanges emits null and the app shows the login screen.
  Future<void> signOut() => _auth.signOut();

  // ── Firestore — User Profile ───────────────────────────────────────────────
  //
  // Firestore structure for our app:
  //
  //   users (collection)
  //   └── {uid} (document — one per user, uid comes from Firebase Auth)
  //       ├── name:      "John Doe"
  //       ├── contact:   "+1 555 0100"
  //       ├── address:   "123 Main St"
  //       └── updatedAt: <server timestamp>

  // Save (or update) a user's profile in Firestore.
  // SetOptions(merge: true) means we only overwrite the fields we provide,
  // leaving any other fields in the document untouched.
  Future<void> saveProfile({
    required String uid,
    required String name,
    required String contact,
    required String address,
  }) async {
    await _db.collection('users').doc(uid).set(
      {
        'name': name,
        'contact': contact,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(), // Firebase fills this in
      },
      SetOptions(merge: true),
    );
  }

  // Load a user's profile from Firestore.
  // Returns empty strings if the document does not exist yet.
  Future<Map<String, String>> loadProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return {'name': '', 'contact': '', 'address': ''};
    final data = doc.data()!;
    return {
      'name': (data['name'] as String?) ?? '',
      'contact': (data['contact'] as String?) ?? '',
      'address': (data['address'] as String?) ?? '',
    };
  }

  // ── Error messages ─────────────────────────────────────────────────────────
  // Firebase throws FirebaseAuthException with a code string.
  // We convert these codes into messages students can understand.
  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Something went wrong ($code). Please try again.';
    }
  }
}
