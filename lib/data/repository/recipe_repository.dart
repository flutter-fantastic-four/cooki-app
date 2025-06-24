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

  Future<List<Recipe>> getUserRecipes(String userId);

  Future<List<Recipe>> getSharedRecipes();

  Future<List<Recipe>> getCommunityRecipes();

  Future<void> toggleRecipeShare(String recipeId, bool isPublic);

  Future<void> deleteRecipe(String recipeId);
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

  @override
  Future<List<Recipe>> getUserRecipes(String userId) async {
    final recipeDtoList = await _recipeDataSource.getUserRecipes(userId);
    return recipeDtoList.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<Recipe>> getSharedRecipes() async {
    final recipeDtoList = await _recipeDataSource.getSharedRecipes();
    return recipeDtoList.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<Recipe>> getCommunityRecipes() async {
    final recipeDtoList = await _recipeDataSource.getCommunityRecipes();
    return recipeDtoList.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> toggleRecipeShare(String recipeId, bool isPublic) async {
    await _recipeDataSource.toggleRecipeShare(recipeId, isPublic);
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    await _recipeDataSource.deleteRecipe(recipeId);
  }
}
