import 'package:cooki/data/repository/recipe_generation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/auth_repository.dart';
import '../../data/repository/user_repository.dart';
import '../data_source/providers.dart';
import 'image_download_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.read(googleSignInDataSourceProvider),
    ref.read(kakaoSignInDataSourceProvider),
    ref.read(firebaseAuthDataSourceProvider),
    ref.read(userFirestoreDataSourceProvider),
  ),
);

final authStateChangesProvider = StreamProvider<String?>((ref) => ref.read(authRepositoryProvider).authStateChanges());

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.read(userFirestoreDataSourceProvider), ref.read(imageStorageDataSourceProvider)),
);

final recipeGenerationRepositoryProvider = Provider<RecipeGenerationRepository>((ref) {
  return RecipeGenerationRepositoryImpl(ref.read(recipeGenerationDataSourceProvider));
});

final imageDownloadRepositoryProvider = Provider<ImageDownloadRepository>(
  (ref) => ImageDownloadRepositoryImpl(ref.read(imageDownloadDataSourceProvider)),
);
