import 'package:cooki/data/repository/providers.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountActionState {
  final bool isLoading;
  final String? error;

  const AccountActionState({this.isLoading = false, this.error});

  AccountActionState copyWith({bool? isLoading, String? error}) {
    return AccountActionState(isLoading: isLoading ?? this.isLoading, error: error);
  }
}

class AccountActionViewModel extends StateNotifier<AccountActionState> {
  final Ref ref;

  AccountActionViewModel(this.ref) : super(const AccountActionState());

  Future<bool> logout() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await ref.read(authRepositoryProvider).signOut();
      ref.read(userGlobalViewModelProvider.notifier).clearUser();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await ref.read(authRepositoryProvider).deleteAccount();

      ref.read(userGlobalViewModelProvider.notifier).clearUser();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final accountActionViewModelProvider = StateNotifierProvider<AccountActionViewModel, AccountActionState>((ref) {
  return AccountActionViewModel(ref);
});
