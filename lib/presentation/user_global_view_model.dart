import 'package:cooki/data/repository/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entity/app_user.dart';

class UserGlobalViewModel extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void setUser(AppUser user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  Future<void> saveUserToDatabase() async {
    if (state == null) return;
    await ref.read(userRepositoryProvider).saveUserToDatabase(state!);
  }

  void setName(String name) {
    state = state!.copyWith(name: name);
  }

  void setProfileImage(String profileImage) {
    state = state!.copyWith(profileImage: profileImage);
  }
}

final userGlobalViewModelProvider =
    NotifierProvider<UserGlobalViewModel, AppUser?>(UserGlobalViewModel.new);
