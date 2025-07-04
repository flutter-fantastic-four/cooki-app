import 'dart:developer';
import 'dart:io';

import 'package:cooki/core/utils/logger.dart';
import 'package:cooki/data/repository/providers.dart';
import 'package:cooki/presentation/settings_global_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/fcm_service.dart';
import '../domain/entity/app_user.dart';

class UserGlobalViewModel extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void setUser(AppUser user) {
    state = user;
    final currentLanguage =
        ref.read(settingsGlobalViewModelProvider).selectedLanguage.code;
    updateLanguage(currentLanguage);

    // Update FCM token when user is set
    _updateFcmToken(user.id);
  }

  void clearUser() {
    state = null;
  }

  Future<void> updateLanguage(String languageCode) async {
    if (state == null) return;
    state = state!.copyWith(preferredLanguage: languageCode);
    await saveUserToDatabase();
  }

  Future<void> saveUserToDatabase() async {
    if (state == null) return;
    await ref.read(userRepositoryProvider).saveUserToDatabase(state!);
  }

  void setName(String name) {
    state = state!.copyWith(name: name);
  }

  Future<void> setProfileImage(File profileImage) async {
    final url = await ref
        .read(userRepositoryProvider)
        .changeProfileImage(state!, profileImage);
    state = state!.copyWith(profileImage: url);
  }

  Future<void> _updateFcmToken(String userId) async {
    try {
      await FCMService.updateTokenInFirestore(userId);
    } catch (e, stack) {
      // Handle error silently - FCM token update is not critical
      logError(e, stack, reason: 'Error updating FCM token');
    }
  }
}

final userGlobalViewModelProvider =
    NotifierProvider<UserGlobalViewModel, AppUser?>(UserGlobalViewModel.new);
