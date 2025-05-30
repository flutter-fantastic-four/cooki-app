import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class FirebaseAuthDataSource {
  Future<User?> signInWithGoogle(GoogleSignInAuthentication auth);

  Future<void> signOut();

  Stream<User?> authStateChanges();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth;

  FirebaseAuthDataSourceImpl(this._auth);

  @override
  Future<User?> signInWithGoogle(GoogleSignInAuthentication googleAuth) async {
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
