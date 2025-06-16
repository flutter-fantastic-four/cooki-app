import 'dart:typed_data';

import '../../domain/entity/recipe.dart';
import '../data_source/image_storage_data_source.dart';
import '../data_source/recipe_data_source.dart';
import '../dto/recipe_firestore_dto.dart';

abstract class RecipeRepository {
  Future<String> saveRecipe(Recipe recipe);

  Future<void> editRecipe(Recipe recipe);

  Future<String> uploadImageBytes(Uint8List imageBytes, String uid);

  Future<List<Recipe>> getAllRecipes();
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
  Future<void> editRecipe(Recipe recipe) async {
    await _recipeDataSource.editRecipe(RecipeFirestoreDto.fromEntity(recipe));
  }

  @override
  Future<String> uploadImageBytes(Uint8List imageBytes, String uid) {
    return _imageStorageDataSource.uploadImageBytes(
      imageBytes,
      uid,
      'recipe_images',
    );
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    final recipeDtoList = await _recipeDataSource.getAllRecipes();
    return recipeDtoList.map((dto) => dto.toEntity()).toList();
  }
}
