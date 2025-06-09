import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooki/app/enum/sign_in_method.dart';

import '../../domain/entity/app_user.dart';

class UserDto {
  final String id;
  final String name;
  final Timestamp createdAt;
  final String? email;
  final String? profileImage;
  final String signInProvider;

  UserDto({required this.id, required this.name, required this.createdAt, this.email, this.profileImage, required this.signInProvider});

  factory UserDto.fromMap(String id, Map<String, dynamic> map) {
    return UserDto(
      id: id,
      name: map['name'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      email: map['email'],
      profileImage: map['profileImage'],
      signInProvider: map['signInProvider'],
    );
  }
  factory UserDto.fromEntity(AppUser user) {
    return UserDto(
      id: user.id,
      name: user.name,
      createdAt: Timestamp.fromDate(user.createdAt),
      email: user.email,
      profileImage: user.profileImage,
      signInProvider: user.signInProvider.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'createdAt': createdAt, 'email': email, 'profileImage': profileImage, 'signInProvider': signInProvider};
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      name: name,
      createdAt: createdAt.toDate(),
      email: email,
      profileImage: profileImage,
      signInProvider: SignInMethod.values.byName(signInProvider),
    );
  }
}
