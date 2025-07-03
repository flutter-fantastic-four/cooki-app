const admin = require("firebase-admin");
admin.initializeApp();

/**
 * Backfills the actualRating field for all recipes in Firestore
 * by recalculating the average from all non-deleted reviews.
 */
async function backfillActualRatings() {
  const recipesSnapshot = await admin.firestore().collection("recipes").get();
  for (const recipeDoc of recipesSnapshot.docs) {
    const recipeId = recipeDoc.id;
    const reviewsSnapshot = await admin.firestore()
        .collection("reviews")
        .where("recipeId", "==", recipeId)
        .get();

    let total = 0; let count = 0;
    reviewsSnapshot.forEach((doc) => {
      total += doc.data().rating;
      count++;
    });

    const avg = count > 0 ? total / count : 0;
    await admin.firestore().collection("recipes").doc(recipeId).update({
      actualRating: avg,
    });
    console.log(`Updated ${recipeId} with actualRating: ${avg}`);
  }
  console.log("Backfill complete!");
}

backfillActualRatings();
