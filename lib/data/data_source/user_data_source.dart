import 'package:cloud_firestore/cloud_firestore.dart';

import '../dto/user_dto.dart';

abstract class UserDataSource {
  Future<UserDto?> getUserById(String uid);

  Future<void> saveUser(UserDto user);

  Future<void> deleteUser(UserDto user);

  Future<void> updateUserFcmToken(String userId, String fcmToken);
}

class UserFirestoreDataSource implements UserDataSource {
  final FirebaseFirestore _firestore;

  UserFirestoreDataSource(this._firestore);

  @override
  Future<UserDto?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserDto.fromMap(uid, doc.data()!);
  }

  @override
  Future<void> saveUser(UserDto user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  @override
  Future<void> deleteUser(UserDto user) async {
    await _firestore.collection('users').doc(user.id).delete();
  }

  @override
  Future<void> updateUserFcmToken(String userId, String fcmToken) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': fcmToken,
    });
  }
}
