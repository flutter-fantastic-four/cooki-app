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

  Future<List<Recipe>> getMyRecipes(
    String userId, {
    bool? isPublic,
    RecipeSortType sortType,
  });

  Future<List<Recipe>> getUserSavedRecipes(
    String userId, {
    RecipeSortType sortType,
  });

  Future<List<String>> getUserSavedRecipeIds(String userId);

  Future<List<Recipe>> getCommunityRecipes(
    String userId, {
    RecipeSortType sortType,
  });

  Future<void> addToSavedRecipes(String userId, String recipeId);

  Future<void> removeFromSavedRecipes(String userId, String recipeId);

  Future<void> toggleRecipeShare(String recipeId, bool isPublic);

  Future<void> deleteRecipe(String recipeId);
}

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeDataSource _recipeDataSource;
  final ImageStorageDataSource _imageStorageDataSource;

  RecipeRepositoryImpl(this._recipeDataSource, this._imageStorageDataSource);

  @override
  Future<String> saveRecipe(Recipe recipe) async {
    return _recipeDataSource.saveRecipe(RecipeFirestoreDto.fromEntity(recipe));
  }

  @override
  Future<void> editRecipe(Recipe recipe) {
    return _recipeDataSource.editRecipe(RecipeFirestoreDto.fromEntity(recipe));
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
  Future<List<Recipe>> getMyRecipes(
    String userId, {
    bool? isPublic,
    RecipeSortType sortType = RecipeSortType.createdAtDescending,
  }) async {
    final dtoList = await _recipeDataSource.getMyRecipes(
      userId,
      isPublic: isPublic,
      sortType: sortType,
    );
    return dtoList.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<Recipe>> getUserSavedRecipes(
    String userId, {
    RecipeSortType sortType = RecipeSortType.createdAtDescending,
  }) async {
    final dtoList = await _recipeDataSource.getUserSavedRecipes(
      userId,
      sortType: sortType,
    );
    return dtoList.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<String>> getUserSavedRecipeIds(String userId) {
    return _recipeDataSource.getUserSavedRecipeIds(userId);
  }

  @override
  Future<List<Recipe>> getCommunityRecipes(
    String userId, {
    RecipeSortType sortType = RecipeSortType.createdAtDescending,
  }) async {
    final dtoList = await _recipeDataSource.getCommunityRecipes(
      userId,
      sortType: sortType,
    );
    return dtoList.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> addToSavedRecipes(String userId, String recipeId) {
    return _recipeDataSource.addToSavedRecipes(userId, recipeId);
  }

  @override
  Future<void> removeFromSavedRecipes(String userId, String recipeId) {
    return _recipeDataSource.removeFromSavedRecipes(userId, recipeId);
  }

  @override
  Future<void> toggleRecipeShare(String recipeId, bool isPublic) {
    return _recipeDataSource.toggleRecipeShare(recipeId, isPublic);
  }

  @override
  Future<void> deleteRecipe(String recipeId) {
    return _recipeDataSource.deleteRecipe(recipeId);
  }
}
