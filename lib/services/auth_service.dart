import 'package:firebase_auth/firebase_auth.dart';
import 'secure_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final SecureStorageService _secureStorage;

  AuthService({
    FirebaseAuth? auth,
    SecureStorageService? secureStorage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _secureStorage = secureStorage ?? SecureStorageService();

  /// Stream of user authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the currently authenticated user.
  User? get currentUser => _auth.currentUser;

  /// Gets the current user's UID.
  String? get currentUid => _auth.currentUser?.uid;

  /// Anonymous sign-in for fast guest access and rapid testing.
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth error (${e.code}): ${e.message}');
    }
  }

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign in error (${e.code}): ${e.message}');
    }
  }

  /// Register a new account with email and password.
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Registration error (${e.code}): ${e.message}');
    }
  }

  /// Securely signs out the user and wipes local credentials.
  Future<void> signOut() async {
    // 1. Wipe all sensitive local secure storage keys/tokens
    await _secureStorage.deleteAll();

    // 2. Terminate Firebase Auth session
    await _auth.signOut();
  }
}