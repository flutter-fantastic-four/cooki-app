import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility function to calculate and add ratingAverage field to all recipes
/// based on existing ratingSum and ratingCount values.
Future<void> addRatingAverageToAllRecipes() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    log('Starting to add ratingAverage field to all recipes...');

    // Get all recipes
    final recipesSnapshot = await firestore.collection('recipes').get();

    log('Found ${recipesSnapshot.docs.length} recipes to update');

    int updatedCount = 0;
    int errorCount = 0;

    // Process each recipe
    for (final recipeDoc in recipesSnapshot.docs) {
      try {
        final recipeId = recipeDoc.id;
        final data = recipeDoc.data();

        // Get existing ratingSum and ratingCount
        final int ratingCount = data['ratingCount'] ?? 0;
        final double ratingSum = (data['ratingSum'] ?? 0).toDouble();

        // Calculate average
        final double ratingAverage = ratingCount > 0 ? ratingSum / ratingCount : 0.0;

        // Update the recipe document with ratingAverage field only
        await firestore.collection('recipes').doc(recipeId).update({
          'ratingAverage': ratingAverage,
        });

        updatedCount++;
        log('✅ Updated recipe $recipeId: count=$ratingCount, sum=$ratingSum, avg=$ratingAverage');

        // Add small delay to avoid overwhelming Firestore
        await Future.delayed(const Duration(milliseconds: 100));

      } catch (e) {
        errorCount++;
        log('❌ Error updating recipe ${recipeDoc.id}: $e');
      }
    }

    log('\n📊 Rating Average Update Summary:');
    log('✅ Successfully updated: $updatedCount recipes');
    log('❌ Errors: $errorCount recipes');
    log('🎉 Rating average field addition completed!');

  } catch (e) {
    log('💥 Fatal error during rating average update: $e');
    rethrow;
  }
}

Future<void> updateAllRecipeRatingStats() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    log('Starting rating stats update for all recipes...');

    // Get all recipes
    final recipesSnapshot = await firestore.collection('recipes').get();

    log('Found ${recipesSnapshot.docs.length} recipes to update');

    int updatedCount = 0;
    int errorCount = 0;

    // Process each recipe
    for (final recipeDoc in recipesSnapshot.docs) {
      try {
        final recipeId = recipeDoc.id;
        log('Processing recipe: $recipeId');

        // Get all non-deleted reviews for this recipe
        final reviewsSnapshot = await firestore
            .collection('recipes')
            .doc(recipeId)
            .collection('reviews')
            .where('isDeleted', isEqualTo: false)
            .get();

        final List<int> ratings = [];

        // Extract valid ratings
        for (final reviewDoc in reviewsSnapshot.docs) {
          final data = reviewDoc.data();
          final rating = data['rating'];

          if (rating is int && rating >= 1 && rating <= 5) {
            ratings.add(rating);
          }
        }

        // Calculate new stats
        final int ratingCount = ratings.length;
        final double ratingSum = ratings.isEmpty
            ? 0.0
            : ratings.reduce((a, b) => a + b).toDouble();

        // Update the recipe document
        await firestore.collection('recipes').doc(recipeId).update({
          'ratingCount': ratingCount,
          'ratingSum': ratingSum,
        });

        updatedCount++;
        log('✅ Updated recipe $recipeId: $ratingCount reviews, sum: $ratingSum');

        // Add small delay to avoid overwhelming Firestore
        await Future.delayed(const Duration(milliseconds: 100));

      } catch (e) {
        errorCount++;
        log('❌ Error updating recipe ${recipeDoc.id}: $e');
      }
    }

    log('\n📊 Update Summary:');
    log('✅ Successfully updated: $updatedCount recipes');
    log('❌ Errors: $errorCount recipes');
    log('🎉 Rating stats update completed!');

  } catch (e) {
    log('💥 Fatal error during rating stats update: $e');
    rethrow;
  }
}

/// Quick function to update rating stats for a single recipe
/// Useful for testing or fixing individual recipes
Future<void> updateSingleRecipeRatingStats({String recipeId = 'YWuYSZ2Jhq0aG5pQJEUp'}) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    log('Updating rating stats for recipe: $recipeId');

    final reviewsSnapshot = await firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .where('isDeleted', isEqualTo: false)
        .get();

    final List<int> ratings = [];

    for (final reviewDoc in reviewsSnapshot.docs) {
      final rating = reviewDoc.data()['rating'];
      if (rating is int && rating >= 1 && rating <= 5) {
        ratings.add(rating);
      }
    }

    final int ratingCount = ratings.length;
    final double ratingSum = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b).toDouble();

    await firestore.collection('recipes').doc(recipeId).update({
      'ratingCount': ratingCount,
      'ratingSum': ratingSum,
    });

    log('✅ Updated recipe $recipeId: $ratingCount reviews, sum: $ratingSum');

  } catch (e) {
    log('❌ Error updating recipe $recipeId: $e');
    rethrow;
  }
}