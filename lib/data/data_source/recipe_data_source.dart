import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/recipe_firestore_dto.dart';

abstract class RecipeDataSource {
  Future<String> saveRecipe(RecipeFirestoreDto recipe);
}

class RecipeFirestoreDataSource implements RecipeDataSource {
  final FirebaseFirestore _firestore;

  RecipeFirestoreDataSource(this._firestore);

  @override
  Future<String> saveRecipe(RecipeFirestoreDto recipeDto) async {
    final docRef = await _firestore.collection('recipes').add(recipeDto.toMap());
    return docRef.id;
  }
}
