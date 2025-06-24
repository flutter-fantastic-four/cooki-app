import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/recipe_firestore_dto.dart';

abstract class RecipeDataSource {
  Future<String> saveRecipe(RecipeFirestoreDto recipe);

  Future<void> editRecipe(RecipeFirestoreDto recipeDto);

  Future<List<RecipeFirestoreDto>> getAllRecipes();

  Future<List<RecipeFirestoreDto>> getUserRecipes(String userId);

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
    final recipeData =
        recipeDto.toMap()..['createdAt'] = FieldValue.serverTimestamp();
    final docRef = await _firestore.collection('recipes').add(recipeData);
    return docRef.id;
  }

  @override
  Future<void> editRecipe(RecipeFirestoreDto recipeDto) async {
    final recipeData =
        recipeDto.toMap()..['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('recipes').doc(recipeDto.id).set(recipeData);
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
  Future<List<RecipeFirestoreDto>> getUserRecipes(String userId) async {
    final querySnapshot =
        await _firestore
            .collection('recipes')
            .where('userId', isEqualTo: userId)
            .get();

    // Sort by createdAt in memory instead of using Firestore orderBy
    final docs = querySnapshot.docs;
    docs.sort((a, b) {
      final aTimestamp = a.data()['createdAt'] as Timestamp?;
      final bTimestamp = b.data()['createdAt'] as Timestamp?;

      if (aTimestamp == null && bTimestamp == null) return 0;
      if (aTimestamp == null) return 1;
      if (bTimestamp == null) return -1;

      return bTimestamp.compareTo(aTimestamp); // Descending order
    });

    return docs
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
