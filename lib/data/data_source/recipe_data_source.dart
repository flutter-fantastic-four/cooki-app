import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/recipe_firestore_dto.dart';

enum RecipeSortType {
  createdAtDescending, // default
  ratingDescending, // most stars
  cookTimeAscending, // fastest first
}

abstract class RecipeDataSource {
  Future<List<RecipeFirestoreDto>> getMyRecipes(
    String userId, {
    bool? isPublic,
    RecipeSortType sortType = RecipeSortType.ratingDescending,
  });

  Future<List<String>> getUserSavedRecipeIds(String userId);

  Future<List<RecipeFirestoreDto>> getUserSavedRecipes(
    String userId, {
    RecipeSortType sortType = RecipeSortType.ratingDescending,
  });

  Future<List<RecipeFirestoreDto>> getCommunityRecipes(
    String? userId, {
    RecipeSortType sortType = RecipeSortType.ratingDescending,
  });

  Future<void> addToSavedRecipes(String userId, String recipeId);
  Future<void> removeFromSavedRecipes(String userId, String recipeId);

  Future<String> saveRecipe(RecipeFirestoreDto recipe);

  Future<void> editRecipe(RecipeFirestoreDto recipeDto);

  Future<List<RecipeFirestoreDto>> getAllRecipes();

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

  Query<Map<String, dynamic>> _applySort(
    Query<Map<String, dynamic>> query,
    RecipeSortType sortType,
  ) {
    switch (sortType) {
      case RecipeSortType.ratingDescending:
        return query.orderBy('ratingAverage', descending: true);
      case RecipeSortType.cookTimeAscending:
        return query.orderBy('cookTime', descending: false);
      case RecipeSortType.createdAtDescending:
        return query.orderBy('createdAt', descending: true);
    }
  }

  @override
  Future<List<RecipeFirestoreDto>> getMyRecipes(
    String userId, {
    bool? isPublic,
    RecipeSortType sortType = RecipeSortType.createdAtDescending,
  }) async {
    var query = _firestore
        .collection('recipes')
        .where('userId', isEqualTo: userId);

    if (isPublic != null) {
      query = query.where('isPublic', isEqualTo: isPublic);
    }

    query = _applySort(query, sortType);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => RecipeFirestoreDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<String>> getUserSavedRecipeIds(String userId) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('savedRecipes')
            .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  @override
  Future<List<RecipeFirestoreDto>> getUserSavedRecipes(
    String userId, {
    RecipeSortType sortType = RecipeSortType.createdAtDescending,
  }) async {
    final savedRecipeIds = await getUserSavedRecipeIds(userId);
    if (savedRecipeIds.isEmpty) return [];

    var query = _firestore
        .collection('recipes')
        .where(FieldPath.documentId, whereIn: savedRecipeIds);
    query = _applySort(query, sortType);

    final recipeSnapshot = await query.get();
    return recipeSnapshot.docs
        .map((doc) => RecipeFirestoreDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<RecipeFirestoreDto>> getCommunityRecipes(
    String? userId, {
    RecipeSortType sortType = RecipeSortType.createdAtDescending,
  }) async {
    var query = _firestore
        .collection('recipes')
        .where('isPublic', isEqualTo: true);

    // 로그인 되어있을 때
    if (userId != null) {
      query = query.where('userId', isNotEqualTo: userId);
    }
    query = _applySort(query, sortType);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => RecipeFirestoreDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> addToSavedRecipes(String userId, String recipeId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedRecipes')
        .doc(recipeId)
        .set({'savedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> removeFromSavedRecipes(String userId, String recipeId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedRecipes')
        .doc(recipeId)
        .delete();
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
