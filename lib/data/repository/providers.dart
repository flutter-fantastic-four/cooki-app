import 'package:cooki/data/repository/recipe_generation_repository.dart';
import 'package:cooki/data/repository/recipe_repository.dart';
import 'package:cooki/data/repository/report_repository.dart';
import 'package:cooki/data/repository/review_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/auth_repository.dart';
import '../../data/repository/user_repository.dart';
import '../data_source/providers.dart';
import '../data_source/recipe_data_source.dart';
import 'image_download_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.read(googleSignInDataSourceProvider),
    ref.read(kakaoSignInDataSourceProvider),
    ref.read(appleSignInDataSourceProvider),
    ref.read(firebaseAuthDataSourceProvider),
    ref.read(userFirestoreDataSourceProvider),
  ),
);

final authStateChangesProvider = StreamProvider<String?>(
  (ref) => ref.read(authRepositoryProvider).authStateChanges(),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    ref.read(userFirestoreDataSourceProvider),
    ref.read(imageStorageDataSourceProvider),
  ),
);

final recipeGenerationRepositoryProvider = Provider<RecipeGenerationRepository>(
  (ref) {
    return RecipeGenerationRepositoryImpl(
      ref.read(recipeGenerationDataSourceProvider),
    );
  },
);

final imageDownloadRepositoryProvider = Provider<ImageDownloadRepository>(
  (ref) =>
      ImageDownloadRepositoryImpl(ref.read(imageDownloadDataSourceProvider)),
);

final recipeDataSourceProvider = Provider<RecipeDataSource>(
  (ref) => RecipeFirestoreDataSource(ref.read(firestoreProvider)),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => RecipeRepositoryImpl(
    ref.read(recipeDataSourceProvider),
    ref.read(imageStorageDataSourceProvider),
  ),
);

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(
    ref.read(reviewDataSourceProvider),
    ref.read(imageStorageDataSourceProvider),
    ref.read(translationDataSourceProvider), // Add this line
  );
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.read(reportDataSourceProvider));
});
