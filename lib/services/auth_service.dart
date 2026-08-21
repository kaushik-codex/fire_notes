import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'secure_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final SecureStorageService _secureStorage;
  static const String webClientId = '158146329542-kfra5r1riiau3vupvuel05d25b32inrm.apps.googleusercontent.com';

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    SecureStorageService? secureStorage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _secureStorage = secureStorage ?? SecureStorageService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  /// Sign in using Google OAuth SSO
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger modern authentication flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // 2. Obtain OAuth authentication details (contains idToken)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3. Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the Google user credential
      final userCredential = await _auth.signInWithCredential(credential);

      // 5. Store session marker in secure hardware storage
      if (userCredential.user != null) {
        await _secureStorage.write('auth_provider', 'google');
      }

      return userCredential;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null; // User canceled the sign-in flow
      }
      throw Exception('Google Sign-In error (${e.code}): ${e.description}');
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase Google Auth error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Anonymous sign-in
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth error (${e.code}): ${e.message}');
    }
  }

  /// Sign in with email and password
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

  /// Register with email and password
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

  /// Securely signs out from both Firebase and Google session
  Future<void> signOut() async {
    await _secureStorage.deleteAll();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}