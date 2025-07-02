/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.updateRecipeActualRating = functions.firestore
  .document('reviews/{reviewId}')
  .onWrite(async (change, context) => {
    // Get the recipeId from the review (either before or after)
    const review = change.after.exists ? change.after.data() : null;
    const prevReview = change.before.exists ? change.before.data() : null;
    const recipeId = review ? review.recipeId : prevReview.recipeId;

    if (!recipeId) return null;

    // Get all reviews for this recipe
    const reviewsSnapshot = await admin.firestore()
      .collection('reviews')
      .where('recipeId', '==', recipeId)
      .get();

    let total = 0, count = 0;
    reviewsSnapshot.forEach(doc => {
      total += doc.data().rating;
      count++;
    });

    const avg = count > 0 ? total / count : 0;

    // Update the recipe document
    await admin.firestore().collection('recipes').doc(recipeId).update({
      actualRating: avg
    });

    return null;
  });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
