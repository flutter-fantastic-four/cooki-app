class AppUser {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? email;
  final String? profileImage;

  AppUser({
    required this.id,
    required this.name,
    DateTime? createdAt,
    this.email,
    this.profileImage,
  }) : createdAt = createdAt ?? DateTime.now();

  AppUser copyWith({
    String? name,
    DateTime? createdAt,
    String? email,
    String? profileImage,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
