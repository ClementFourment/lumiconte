import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'user_service.dart';

class AuthService extends FirebaseService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late UserService _userService;

  AuthService() {
    _userService = UserService();
  }

  // 🔑 Google Sign In avec création du user Firestore
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception("Connexion Google annulée");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) throw Exception("Erreur authentification");

      // Créer ou mettre à jour le user dans Firestore
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        subscribed: false,
        createdAt: DateTime.now(),
        authProvider: UserAuthProvider.google,
      );

      await _userService.createOrUpdateUser(userModel);

      return userModel;
    } catch (e) {
      print('Erreur Google Sign In: $e');
      rethrow;
    }
  }

  // 📧 Email/Password Sign In
  Future<UserModel> signInWithEmail(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw Exception("Erreur authentification");
    }

    return await _userService.getUser(firebaseUser.uid) ??
        (throw Exception("User Firestore introuvable"));
  }

  // 📝 Email/Password Sign Up
  Future<UserModel> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception("Erreur création compte");

      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: email,
        displayName: null,
        photoUrl: null,
        subscribed: false,
        createdAt: DateTime.now(),
        authProvider: UserAuthProvider.email,
      );

      await _userService.createOrUpdateUser(userModel);

      return userModel;
    } catch (e) {
      print('Erreur Sign Up Email: $e');
      rethrow;
    }
  }

  // 🚪 Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Erreur Sign Out: $e');
      rethrow;
    }
  }

  // 👤 Récupérer l'utilisateur actuel
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      return await _userService.getUser(firebaseUser.uid);
    } catch (e) {
      print('Erreur récupération utilisateur: $e');
      return null;
    }
  }

  // Stream d'authentification
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
