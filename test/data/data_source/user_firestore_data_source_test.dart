import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooki/data/data_source/user_data_source.dart';
import 'package:cooki/data/dto/user_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirestore mockFirestore;
  late UserFirestoreDataSource userDataSource;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirestore();
    userDataSource = UserFirestoreDataSource(mockFirestore);
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();

    // Set up default mock behavior
    when(
      () => mockFirestore.collection('users'),
    ).thenReturn(mockCollectionReference);
    when(
      () => mockCollectionReference.doc(any()),
    ).thenReturn(mockDocumentReference);
  });

  group('UserFirestoreDataSource', () {
    test('getUserById returns UserDto when document exists', () async {
      // Arrange
      final testUserId = 'test-user-id';
      final testUserData = {
        'name': 'Test User',
        'createdAt': Timestamp.now(),
        'email': 'test@example.com',
      };

      when(
        () => mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);
      when(() => mockDocumentSnapshot.exists).thenReturn(true);
      when(() => mockDocumentSnapshot.data()).thenReturn(testUserData);

      // Act
      final result = await userDataSource.getUserById(testUserId);

      // Assert
      expect(result, isA<UserDto>());
      expect(result?.id, equals(testUserId));
      expect(result?.name, equals('Test User'));
      expect(result?.email, equals('test@example.com'));

      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockCollectionReference.doc(testUserId)).called(1);
      verify(() => mockDocumentReference.get()).called(1);
    });

    test('getUserById returns null when document does not exist', () async {
      // Arrange
      final testUserId = 'test-user-id';

      when(
        () => mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);
      when(() => mockDocumentSnapshot.exists).thenReturn(false);

      // Act
      final result = await userDataSource.getUserById(testUserId);

      // Assert
      expect(result, isNull);

      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockCollectionReference.doc(testUserId)).called(1);
      verify(() => mockDocumentReference.get()).called(1);
    });

    test('saveUser calls set on document reference', () async {
      // Arrange
      final testUserDto = UserDto(
        id: 'test-user-id',
        name: 'Test User',
        createdAt: Timestamp.now(),
        email: 'test@example.com',
      );

      when(() => mockDocumentReference.set(any())).thenAnswer((_) async {});

      // Act
      await userDataSource.saveUser(testUserDto);

      // Assert
      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockCollectionReference.doc(testUserDto.id)).called(1);
      verify(() => mockDocumentReference.set(any())).called(1);
    });
  });
}
