import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class FirebaseAuthDataSource {
  Future<User?> signInWithGoogle(GoogleSignInAuthentication auth);

  Future<User?> signInWithKakao(String kakaoToken);

  Future<void> signOut();

  Stream<User?> authStateChanges();

  User? currentUser();
  Future<void> deleteUser();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  FirebaseAuthDataSourceImpl(this._auth, this._functions);

  @override
  Future<User?> signInWithGoogle(GoogleSignInAuthentication googleAuth) async {
    final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  Future<User?> signInWithKakao(String kakaoToken) async {
    final callable = _functions.httpsCallable('kakaoCustomAuth');

    final result = await callable.call({'token': kakaoToken});
    final customToken = result.data['custom_token'];

    final userCredential = await _auth.signInWithCustomToken(customToken);
    return userCredential.user;
  }

  @override
  User? currentUser() {
    return _auth.currentUser;
  }

  @override
  Future<void> deleteUser() async {
    _auth.currentUser!.delete();
  }
}
