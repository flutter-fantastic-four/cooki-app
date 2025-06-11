import '../../domain/entity/recipe.dart';
import '../data_source/recipe_data_source.dart';
import '../dto/recipe_firestore_dto.dart';

abstract class RecipeRepository {
  Future<String> saveRecipe(Recipe recipe);
}

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeDataSource _recipeDataSource;

  RecipeRepositoryImpl(this._recipeDataSource);

  @override
  Future<String> saveRecipe(Recipe recipe) async {
    return await _recipeDataSource.saveRecipe(
      RecipeFirestoreDto.fromEntity(recipe),
    );
  }
}
