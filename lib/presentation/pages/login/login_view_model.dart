import 'package:cooki/app/enum/sign_in_method.dart';
import 'package:cooki/data/data_source/providers.dart';
import 'package:cooki/data/repository/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../../data/dto/user_dto.dart';
import '../../../domain/entity/app_user.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;

  const LoginState({this.isLoading = false, this.errorMessage});

  LoginState copyWith({bool? isLoading, String? errorMessage}) {
    return LoginState(isLoading: isLoading ?? this.isLoading, errorMessage: errorMessage);
  }
}

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() {
    return const LoginState();
  }

  Future<AppUser?> signIn(SignInMethod signInMethod) async {
    if (kIsWeb && signInMethod == SignInMethod.google) {
      return await _debugSignInWithGoogleOnWeb(signInMethod);
    }

    state = state.copyWith(isLoading: true);
    try {
      final AppUser? user;

      user = await ref.read(authRepositoryProvider).signIn(signInMethod);

      state = state.copyWith(isLoading: false);
      return user;
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(isLoading: false, errorMessage: "Login failed\n${e.toString()}");
      rethrow;
    }
  }

  Future<AppUser?> _debugSignInWithGoogleOnWeb(SignInMethod signInMethod) async {
    state = state.copyWith(isLoading: true);
    try {
      final googleProvider = GoogleAuthProvider();
      final userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        state = state.copyWith(isLoading: false);
        return null;
      }

      final partialUser = AppUser(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        profileImage: firebaseUser.photoURL,
        email: firebaseUser.email ?? '',
        signInProvider: signInMethod,
      );

      final userDataSource = ref.read(userFirestoreDataSourceProvider);
      final existingUser = await userDataSource.getUserById(partialUser.id);

      late final AppUser resultUser;

      if (existingUser != null) {
        resultUser = existingUser.toEntity();
      } else {
        await userDataSource.saveUser(UserDto.fromEntity(partialUser));
        resultUser = partialUser;
      }

      state = state.copyWith(isLoading: false);
      return resultUser;
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(isLoading: false, errorMessage: "Login failed\n${e.toString()}");
      rethrow;
    }
  }

}

final loginViewModelProvider = NotifierProvider<LoginViewModel, LoginState>(() => LoginViewModel());
