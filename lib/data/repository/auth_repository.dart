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
  Future<void> deleteAccount();
  Stream<String?> authStateChanges();
}

class AuthRepositoryImpl implements AuthRepository {
  final OAuthSignInDataSource _googleDataSource;
  final OAuthSignInDataSource _kakaoDataSource;
  final FirebaseAuthDataSource _firebaseAuth;
  final UserDataSource _userDataSource;

  AuthRepositoryImpl(this._googleDataSource, this._kakaoDataSource, this._firebaseAuth, this._userDataSource);

  @override
  Future<AppUser?> signIn(SignInMethod signInmethod) async {
    final auth = switch (signInmethod) {
      SignInMethod.google => await _googleDataSource.signIn(),
      SignInMethod.kakao => await _kakaoDataSource.signIn(),
      SignInMethod.apple => null,
    };

    if (auth == null) return null;

    final firebaseUser = switch (signInmethod) {
      SignInMethod.google => await _firebaseAuth.signInWithGoogle(auth),
      SignInMethod.kakao => await _firebaseAuth.signInWithKakao(auth),
      SignInMethod.apple => null,
    };

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

    await _signOutFromSocialProvider(user.signInProvider);
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final currentUser = _firebaseAuth.currentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final user = await _userDataSource.getUserById(currentUser.uid);
      if (user == null) {
        throw Exception('User data not found');
      }

      await _userDataSource.deleteUser(user);

      await _firebaseAuth.deleteUser();

      await _signOutFromSocialProvider(user.signInProvider);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> _signOutFromSocialProvider(String signInProvider) async {
    try {
      switch (signInProvider) {
        case "google":
          await _googleDataSource.signOut();
          break;
        case "kakao":
          await _kakaoDataSource.signOut();
          break;
        // case "apple":
        //   await _appleDataSource.signOut();
        //   break;
      }
    } catch (e) {
      throw Exception('Failed to sign out from social provider: $e');
    }
  }

  @override
  Stream<String?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }
}
