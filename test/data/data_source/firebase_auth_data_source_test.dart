import 'package:cloud_functions/cloud_functions.dart';
import 'package:cooki/data/data_source/firebase_auth_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFunction extends Mock implements FirebaseFunctions {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFunction mockFirebaseFunction;
  late FirebaseAuthDataSourceImpl firebaseAuthDataSource;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockGoogleSignInAuthentication mockGoogleAuth;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFunction = MockFirebaseFunction();
    firebaseAuthDataSource = FirebaseAuthDataSourceImpl(mockFirebaseAuth, mockFirebaseFunction);
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockGoogleAuth = MockGoogleSignInAuthentication();

    // Set up default mock behavior
    when(() => mockUserCredential.user).thenReturn(mockUser);
    when(() => mockGoogleAuth.accessToken).thenReturn('mock-access-token');
    when(() => mockGoogleAuth.idToken).thenReturn('mock-id-token');
  });

  group('FirebaseAuthDataSourceImpl', () {
    test('signInWithGoogle returns user when sign in succeeds', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithCredential(any())).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await firebaseAuthDataSource.signInWithGoogle(mockGoogleAuth);

      // Assert
      expect(result, equals(mockUser));
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('signOut calls Firebase signOut', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act
      await firebaseAuthDataSource.signOut();

      // Assert
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('authStateChanges returns the auth state stream', () async {
      // Arrange
      final testStream = Stream<User?>.fromIterable([mockUser, null]);
      when(() => mockFirebaseAuth.authStateChanges()).thenAnswer((_) => testStream);

      // Act
      final result = firebaseAuthDataSource.authStateChanges();

      // Assert
      expect(result, equals(testStream));
      verify(() => mockFirebaseAuth.authStateChanges()).called(1);
    });
  });
}
