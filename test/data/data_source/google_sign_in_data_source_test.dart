import 'package:cooki/data/data_source/google_sign_in_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late GoogleSignInDataSourceImpl googleSignInDataSource;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    googleSignInDataSource = GoogleSignInDataSourceImpl(mockGoogleSignIn);
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();

    // Set up default mock behavior
    when(() => mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuthentication);
  });

  group('GoogleSignInDataSourceImpl', () {
    test('signIn returns authentication when sign in succeeds', () async {
      // Arrange
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);

      // Act
      final result = await googleSignInDataSource.signIn();

      // Assert
      expect(result, equals(mockGoogleSignInAuthentication));
      verify(() => mockGoogleSignIn.signIn()).called(1);
      verify(() => mockGoogleSignInAccount.authentication).called(1);
    });

    test('signIn returns null when user cancels sign in', () async {
      // Arrange
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      // Act
      final result = await googleSignInDataSource.signIn();

      // Assert
      expect(result, isNull);
      verify(() => mockGoogleSignIn.signIn()).called(1);
      verifyNever(() => mockGoogleSignInAccount.authentication);
    });

    test('signOut calls Google signOut', () async {
      // Arrange
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => mockGoogleSignInAccount);

      // Act
      await googleSignInDataSource.signOut();

      // Assert
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });
  });
}