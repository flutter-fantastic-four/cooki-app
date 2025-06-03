import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../domain/entity/app_user.dart';
import '../data_source/firebase_auth_data_source.dart';
import '../data_source/sign_in_data_source.dart';
import '../data_source/user_data_source.dart';
import '../dto/user_dto.dart';

abstract class AuthRepository {
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInWithKakao();

  Future<void> signOut();

  Stream<String?> authStateChanges(); // returns user ID or null
}

class AuthRepositoryImpl implements AuthRepository {
  final SignInDataSource _googleSignIn;
  final SignInDataSource _kakaoSignIn;
  final FirebaseAuthDataSource _firebaseAuth;
  final UserDataSource _userDataSource;

  AuthRepositoryImpl(
    this._googleSignIn,
    this._kakaoSignIn,
    this._firebaseAuth,
    this._userDataSource,
  );

  @override
  Future<AppUser?> signInWithGoogle() async {
    final googleAuth = await _googleSignIn.signIn();
    if (googleAuth == null) return null;

    final firebaseUser = await _firebaseAuth.signInWithGoogle(googleAuth);
    if (firebaseUser == null) return null;

    final partialUser = AppUser(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      profileImage: firebaseUser.photoURL,
      email: firebaseUser.email,
    );

    final fullUserDto = await _userDataSource.getUserById(partialUser.id);
    if (fullUserDto != null) {
      // User exists in backend
      return fullUserDto.toEntity(); // Return existing user in backend
    } else {
      // User is new sign up. Add to backend
      await _userDataSource.saveUser(UserDto.fromEntity(partialUser));
      return partialUser; // Return newly added user
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Stream<String?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<AppUser?> signInWithKakao() async {
    final OAuthToken? kakaoAuth = await _kakaoSignIn.signIn();
    if (kakaoAuth == null) return null;

    final firebaseUser = await _firebaseAuth.signInWithKakao(kakaoAuth);
    if (firebaseUser == null) return null;

    final partialUser = AppUser(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      profileImage: firebaseUser.photoURL,
      email: firebaseUser.email,
    );

    final fullUserDto = await _userDataSource.getUserById(partialUser.id);
    if (fullUserDto != null) {
      // User exists in backend
      return fullUserDto.toEntity(); // Return existing user in backend
    } else {
      // User is new sign up. Add to backend
      await _userDataSource.saveUser(UserDto.fromEntity(partialUser));
      return partialUser; // Return newly added user
    }
  }
}
