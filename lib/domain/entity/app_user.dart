import 'package:cooki/app/enum/sign_in_method.dart';

class AppUser {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? email;
  final String? profileImage;
  final SignInMethod signInProvider;
  final String preferredLanguage;

  AppUser({
    required this.id,
    required this.name,
    DateTime? createdAt,
    this.email,
    this.profileImage,
    required this.signInProvider,
    this.preferredLanguage = 'en',
  }) : createdAt = createdAt ?? DateTime.now();

  AppUser copyWith({
    String? name,
    DateTime? createdAt,
    String? email,
    String? profileImage,
    String? preferredLanguage,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      signInProvider: signInProvider,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}
