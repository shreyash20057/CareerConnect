import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();
    } catch (_) {}

    final googleUser = await _googleSignIn.authenticate();
    if (googleUser == null) return null;

    final googleAuth = googleUser.authentication;

    // Request an access token for client-authorized scopes if available.
    String? accessToken;
    try {
      final clientAuth = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);
      accessToken = clientAuth?.accessToken;
    } catch (_) {
      accessToken = null;
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: accessToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Create user doc if new user
    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userCredential.user!.uid)
        .get();

    if (!userDoc.exists) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email ?? '',
        'fullName': userCredential.user!.displayName ?? '',
        'photoUrl': userCredential.user!.photoURL,
        'skills': [],
        'projects': [],
        'certifications': [],
        'experiences': [],
        'achievements': [],
        'isProfileComplete': false,
        'preferences': UserPreferences().toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmail(
      String email, String password, String fullName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(fullName);

    // Create user document in Firestore
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(credential.user!.uid)
        .set({
      'email': email,
      'fullName': fullName,
      'skills': [],
      'projects': [],
      'certifications': [],
      'experiences': [],
      'achievements': [],
      'isProfileComplete': false,
      'preferences': UserPreferences().toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<UserCredential> signInWithEmail(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<bool> checkProfileComplete(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return false;
    return doc.data()?['isProfileComplete'] ?? false;
  }
}