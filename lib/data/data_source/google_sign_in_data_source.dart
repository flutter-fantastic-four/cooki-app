import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleSignInDataSource {
  Future<GoogleSignInAuthentication?> signIn();
  Future<void> signOut();
}

class GoogleSignInDataSourceImpl implements GoogleSignInDataSource {
  final GoogleSignIn _googleSignIn;

  GoogleSignInDataSourceImpl(this._googleSignIn);

  @override
  Future<GoogleSignInAuthentication?> signIn() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    return googleUser.authentication;
  }

  @override
  Future<void> signOut() => _googleSignIn.signOut();
}
