import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/app_user.dart';

final userGlobalViewModelProvider =
    StateNotifierProvider<UserGlobalViewModel, AppUser?>((ref) {
      return UserGlobalViewModel();
    });

class UserGlobalViewModel extends StateNotifier<AppUser?> {
  UserGlobalViewModel() : super(null);

  void setUser(AppUser user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}
