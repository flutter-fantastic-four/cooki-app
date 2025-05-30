import 'package:cooki/data/repository/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../../domain/entity/app_user.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;

  const LoginState({this.isLoading = false, this.errorMessage});

  LoginState copyWith({bool? isLoading, String? errorMessage}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LoginViewModel extends Notifier<LoginState> {
  static const String _agreementKey = 'user_agreed_to_terms';

  @override
  LoginState build() {
    return const LoginState();
  }

  Future<AppUser?> signIn() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return null;
      }
      state = state.copyWith(isLoading: false);
      return user;
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Login failed\n${e.toString()}",
      );
      rethrow;
    }
  }
}

final loginViewModelProvider = NotifierProvider<LoginViewModel, LoginState>(
  () => LoginViewModel(),
);
