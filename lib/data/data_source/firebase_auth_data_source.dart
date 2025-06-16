import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class FirebaseAuthDataSource {
  Future<User?> signInWithGoogle(GoogleSignInAuthentication auth);

  Future<User?> signInWithKakao(String kakaoToken);

  Future<User?> signInWithApple(AuthorizationCredentialAppleID appleCredential);

  Future<void> signOut();

  Stream<User?> authStateChanges();

  User? currentUser();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  FirebaseAuthDataSourceImpl(this._auth, this._functions);

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
  Future<User?> signInWithApple(
    AuthorizationCredentialAppleID appleCredential,
  ) async {
    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }
}
