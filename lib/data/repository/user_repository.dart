import '../../domain/entity/app_user.dart';
import '../data_source/user_data_source.dart';
import '../dto/user_dto.dart';

abstract class UserRepository {
  Future<AppUser?> getUserById(String uid);

  Future<void> saveUserToDatabase(AppUser user);
}

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _userDataSource;

  UserRepositoryImpl(this._userDataSource);

  @override
  Future<AppUser?> getUserById(String uid) async {
    final dto = await _userDataSource.getUserById(uid);
    return dto?.toEntity();
  }

  @override
  Future<void> saveUserToDatabase(AppUser user) async {
    await _userDataSource.saveUser(UserDto.fromEntity(user));
  }
}
