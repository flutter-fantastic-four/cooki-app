import 'package:cooki/data/dto/user_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entity/app_user.dart';
import '../data_source/firebase_auth_data_source.dart';
import '../data_source/oauth_sign_in_data_source.dart';
import '../data_source/user_data_source.dart';

abstract class AuthRepository {
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInWithKakao();

  Future<void> signOut();

  Stream<String?> authStateChanges(); // returns user ID or null
}

class AuthRepositoryImpl implements AuthRepository {
  final OAuthSignInDataSource _googleDataSource;
  final OAuthSignInDataSource _kakaoDataSource;
  final FirebaseAuthDataSource _firebaseAuth;
  final UserDataSource _userDataSource;

  AuthRepositoryImpl(this._googleDataSource, this._kakaoDataSource, this._firebaseAuth, this._userDataSource);

  @override
  Future<AppUser?> signInWithGoogle() async {
    final googleAuth = await _googleDataSource.signIn();
    if (googleAuth == null) return null;

    return _handleSignIn(() => _firebaseAuth.signInWithGoogle(googleAuth));
  }

  @override
  Future<AppUser?> signInWithKakao() async {
    final kakaoToken = await _kakaoDataSource.signIn();
    if (kakaoToken == null) return null;

    return _handleSignIn(() => _firebaseAuth.signInWithKakao(kakaoToken));
  }

  Future<AppUser?> _handleSignIn(Future<User?> Function() firebaseSignIn) async {
    final User? firebaseUser = await firebaseSignIn();
    if (firebaseUser == null) return null;

    final partialUser = AppUser(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      profileImage: firebaseUser.photoURL,
      email: firebaseUser.email ?? '',
    );

    final existingUser = await _userDataSource.getUserById(partialUser.id);
    if (existingUser != null) {
      return existingUser.toEntity();
    } else {
      await _userDataSource.saveUser(UserDto.fromEntity(partialUser));
      return partialUser;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleDataSource.signOut();
    await _kakaoDataSource.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Stream<String?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }
}
