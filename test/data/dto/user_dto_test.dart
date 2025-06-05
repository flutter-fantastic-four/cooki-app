import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooki/app/enum/sign_in_method.dart';
import 'package:cooki/data/dto/user_dto.dart';
import 'package:cooki/domain/entity/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime testDate = DateTime(2025, 05, 17);
  final Timestamp testTimestamp = Timestamp.fromDate(testDate);

  group('UserDto', () {
    test('fromMap converts map data to UserDto correctly', () {
      // Arrange
      final String id = 'test-user-id';
      final Map<String, dynamic> userData = {
        'name': 'Test User',
        'createdAt': testTimestamp,
        'email': 'test@example.com',
        'profileImage': 'https://example.com/profile.jpg',
      };

      // Act
      final userDto = UserDto.fromMap(id, userData);

      // Assert
      expect(userDto.id, equals(id));
      expect(userDto.name, equals('Test User'));
      expect(userDto.createdAt, equals(testTimestamp));
      expect(userDto.email, equals('test@example.com'));
      expect(userDto.profileImage, equals('https://example.com/profile.jpg'));
    });

    test('fromMap handles missing optional fields', () {
      // Arrange
      final String id = 'test-user-id';
      final Map<String, dynamic> userData = {'name': 'Test User', 'createdAt': testTimestamp};

      // Act
      final userDto = UserDto.fromMap(id, userData);

      // Assert
      expect(userDto.id, equals(id));
      expect(userDto.name, equals('Test User'));
      expect(userDto.createdAt, equals(testTimestamp));
      expect(userDto.email, isNull);
      expect(userDto.profileImage, isNull);
    });

    test('fromEntity converts AppUser to UserDto correctly', () {
      // Arrange
      final appUser = AppUser(
        id: 'test-user-id',
        name: 'Test User',
        createdAt: testDate,
        email: 'test@example.com',
        profileImage: 'https://example.com/profile.jpg',
        signInProvider: SignInMethod.google,
      );

      // Act
      final userDto = UserDto.fromEntity(appUser);

      // Assert
      expect(userDto.id, equals(appUser.id));
      expect(userDto.name, equals(appUser.name));
      expect(userDto.createdAt, equals(Timestamp.fromDate(appUser.createdAt)));
      expect(userDto.email, equals(appUser.email));
      expect(userDto.profileImage, equals(appUser.profileImage));
    });

    test('toMap converts UserDto to map correctly', () {
      // Arrange
      final userDto = UserDto(
        id: 'test-user-id',
        name: 'Test User',
        createdAt: testTimestamp,
        email: 'test@example.com',
        profileImage: 'https://example.com/profile.jpg',
        signInProvider: 'google',
      );

      // Act
      final map = userDto.toMap();

      // Assert
      expect(map['name'], equals('Test User'));
      expect(map['createdAt'], equals(testTimestamp));
      expect(map['email'], equals('test@example.com'));
      expect(map['profileImage'], equals('https://example.com/profile.jpg'));
      expect(map['nativeLanguage'], equals('English'));
      expect(map['targetLanguage'], equals('Korean'));
      expect(map['bio'], equals('Test bio'));
      expect(map['birthdate'], equals(testTimestamp));
      expect(map['hobbies'], equals('Casual'));
      expect(map['languageLearningGoal'], equals('Fluency'));
      // id should not be in the map as it's the document ID
      expect(map.containsKey('id'), isFalse);
    });

    test('toEntity converts UserDto to AppUser correctly', () {
      // Arrange
      final userDto = UserDto(
        id: 'test-user-id',
        name: 'Test User',
        createdAt: testTimestamp,
        email: 'test@example.com',
        profileImage: 'https://example.com/profile.jpg',
        signInProvider: 'google',
      );

      // Act
      final appUser = userDto.toEntity();

      // Assert
      expect(appUser.id, equals(userDto.id));
      expect(appUser.name, equals(userDto.name));
      expect(appUser.createdAt, equals(userDto.createdAt.toDate()));
      expect(appUser.email, equals(userDto.email));
      expect(appUser.profileImage, equals(userDto.profileImage));
    });
  });
}
