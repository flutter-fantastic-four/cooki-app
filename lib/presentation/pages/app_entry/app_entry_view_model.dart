import 'package:cooki/data/repository/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entity/app_user.dart';

class AppEntryViewModel extends Notifier<void> {
  @override
  void build() {}

  Future<AppUser?> loadUser(String uid) {
    return ref.read(userRepositoryProvider).getUserById(uid);
  }

  Future<void> signOut() async {
    return ref.read(authRepositoryProvider).signOut();
  }
}

final appEntryViewModelProvider = NotifierProvider<AppEntryViewModel, void>(
  () => AppEntryViewModel(),
);
