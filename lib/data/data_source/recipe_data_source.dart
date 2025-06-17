import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/recipe_firestore_dto.dart';

abstract class RecipeDataSource {
  Future<String> saveRecipe(RecipeFirestoreDto recipe);

  Future<void> editRecipe(RecipeFirestoreDto recipeDto);

  Future<List<RecipeFirestoreDto>> getAllRecipes();

  Future<List<RecipeFirestoreDto>> getSharedRecipes();

  Future<List<RecipeFirestoreDto>> getCommunityRecipes();

  Future<void> toggleRecipeShare(String recipeId, bool isPublic);

  Future<void> deleteRecipe(String recipeId);
}

class RecipeFirestoreDataSource implements RecipeDataSource {
  final FirebaseFirestore _firestore;

  RecipeFirestoreDataSource(this._firestore);

  @override
  Future<String> saveRecipe(RecipeFirestoreDto recipeDto) async {
    final docRef = await _firestore
        .collection('recipes')
        .add(recipeDto.toMap());
    return docRef.id;
  }

  @override
  Future<void> editRecipe(RecipeFirestoreDto recipeDto) async {
    await _firestore
        .collection('recipes')
        .doc(recipeDto.id)
        .set(recipeDto.toMap());
  }

  @override
  Future<List<RecipeFirestoreDto>> getAllRecipes() async {
    final querySnapshot =
        await _firestore
            .collection('recipes')
            .orderBy('createdAt', descending: true)
            .get();

    return querySnapshot.docs
        .map((doc) => RecipeFirestoreDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<RecipeFirestoreDto>> getSharedRecipes() async {
    final querySnapshot =
        await _firestore
            .collection('recipes')
            .where('isPublic', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .get();

    return querySnapshot.docs
        .map((doc) => RecipeFirestoreDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<RecipeFirestoreDto>> getCommunityRecipes() async {
    final querySnapshot =
        await _firestore
            .collection('recipes')
            .where('isPublic', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .get();

    return querySnapshot.docs
        .map((doc) => RecipeFirestoreDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> toggleRecipeShare(String recipeId, bool isPublic) async {
    await _firestore.collection('recipes').doc(recipeId).update({
      'isPublic': isPublic,
    });
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    await _firestore.collection('recipes').doc(recipeId).delete();
  }
}
