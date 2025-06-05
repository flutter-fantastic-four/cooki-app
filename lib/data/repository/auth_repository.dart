import 'package:cooki/app/enum/sign_in_method.dart';
import 'package:cooki/data/dto/user_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entity/app_user.dart';
import '../data_source/firebase_auth_data_source.dart';
import '../data_source/oauth_sign_in_data_source.dart';
import '../data_source/user_data_source.dart';

abstract class AuthRepository {
  Future<AppUser?> signIn(SignInMethod signInmethod);

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
  Future<AppUser?> signIn(SignInMethod signInmethod) async {
    dynamic auth;
    User? firebaseUser;
    switch (signInmethod) {
      case SignInMethod.google:
        auth = await _googleDataSource.signIn();
        firebaseUser = await _firebaseAuth.signInWithGoogle(auth);
        break;
      case SignInMethod.kakao:
        auth = await _kakaoDataSource.signIn();
        firebaseUser = await _firebaseAuth.signInWithKakao(auth);
        break;
      case SignInMethod.apple:
      // auth = await _appleDataSource.signIn();
      // break;
    }

    if (auth == null) return null;
    if (firebaseUser == null) return null;

    final partialUser = AppUser(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      profileImage: firebaseUser.photoURL,
      email: firebaseUser.email ?? '',
      signInProvider: signInmethod,
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
    if (_firebaseAuth.currentUser() == null) return;

    final user = await _userDataSource.getUserById(_firebaseAuth.currentUser()!.uid);

    if (user == null) return;
    switch (user.signInProvider) {
      case "google":
        await _googleDataSource.signOut();
        break;
      case "kakao":
        await _kakaoDataSource.signOut();
        break;
      // case "apple":
      //   await _googleDataSource.signOut();
      //   break;
    }
    await _firebaseAuth.signOut();
  }

  @override
  Stream<String?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }
}
