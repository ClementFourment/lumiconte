import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumiconte/models/user_model.dart';
import 'firebase_service.dart';
import 'user_service.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService extends FirebaseService {
  final serverClientId =
      '211519231124-ln545r0eq2fhfj1no5ijdrpis9j7u8bj.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late UserService _userService;

  bool _initialized = false;

  AuthService() {
    _userService = UserService();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _googleSignIn.initialize(
      serverClientId: serverClientId, // requis sur Android
      // clientId: clientId, // utile pour iOS/Web si besoin
    );
    _initialized = true;
  }

  // 🔑 Google Sign In avec création du user Firestore
  Future<UserModel> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception("idToken null — vérifie serverClientId");
      }

      final credential =
          GoogleAuthProvider.credential(idToken: googleAuth.idToken);

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

  Future<UserModel> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) throw Exception("Erreur authentification");

      // Apple ne fournit le nom que lors de la toute première connexion
      String? displayName = firebaseUser.displayName;
      if (displayName == null &&
          (appleCredential.givenName != null ||
              appleCredential.familyName != null)) {
        displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await firebaseUser.updateDisplayName(displayName);
        }
      }

      // Si l'utilisateur existe déjà dans Firestore, on ne veut pas
      // écraser ses données avec des valeurs vides à la 2e connexion
      final existingUser = await _userService.getUser(firebaseUser.uid);

      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? existingUser?.email ?? '',
        displayName: displayName ?? existingUser?.displayName,
        photoUrl: existingUser?.photoUrl, // Apple ne fournit pas de photo
        subscribed: existingUser?.subscribed ?? false,
        createdAt: existingUser?.createdAt ?? DateTime.now(),
        authProvider: UserAuthProvider.apple,
      );

      await _userService.createOrUpdateUser(userModel);

      return userModel;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw Exception("Connexion Apple annulée");
      }
      print('Erreur Sign In with Apple: ${e.code} — ${e.message}');
      rethrow;
    } catch (e) {
      print('Erreur Sign In with Apple: $e');
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
      print('ok');
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

  getInstance() {
    return _googleSignIn;
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
