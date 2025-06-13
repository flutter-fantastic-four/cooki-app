import 'dart:io';

import 'package:cooki/data/data_source/image_storage_data_source.dart';

import '../../domain/entity/app_user.dart';
import '../data_source/user_data_source.dart';
import '../dto/user_dto.dart';

abstract class UserRepository {
  Future<AppUser?> getUserById(String uid);

  Future<void> saveUserToDatabase(AppUser user);

  Future<String> changeProfileImage(AppUser user, File imageFile);
}

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _userDataSource;
  final ImageStorageDataSource _storageDataSource;

  UserRepositoryImpl(this._userDataSource, this._storageDataSource);

  @override
  Future<AppUser?> getUserById(String uid) async {
    final dto = await _userDataSource.getUserById(uid);
    return dto?.toEntity();
  }

  @override
  Future<void> saveUserToDatabase(AppUser user) async {
    await _userDataSource.saveUser(UserDto.fromEntity(user));
  }

  @override
  Future<String> changeProfileImage(AppUser user, File imageFile) async {
    return await _storageDataSource.uploadImage(imageFile, user.id, 'user');
  }
}
