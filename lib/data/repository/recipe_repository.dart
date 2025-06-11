import 'dart:typed_data';

import '../../domain/entity/recipe.dart';
import '../data_source/image_storage_data_source.dart';
import '../data_source/recipe_data_source.dart';
import '../dto/recipe_firestore_dto.dart';

abstract class RecipeRepository {
  Future<String> saveRecipe(Recipe recipe);

  Future<String> uploadImageBytes(
    Uint8List imageBytes,
    String uid,
    String folder,
  );
}

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeDataSource _recipeDataSource;
  final ImageStorageDataSource _imageStorageDataSource;

  RecipeRepositoryImpl(this._recipeDataSource, this._imageStorageDataSource);

  @override
  Future<String> saveRecipe(Recipe recipe) async {
    return await _recipeDataSource.saveRecipe(
      RecipeFirestoreDto.fromEntity(recipe),
    );
  }

  @override
  Future<String> uploadImageBytes(
    Uint8List imageBytes,
    String uid,
    String folder,
  ) {
    return _imageStorageDataSource.uploadImageBytes(imageBytes, uid, folder);
  }
}
