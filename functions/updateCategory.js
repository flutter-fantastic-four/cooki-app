const admin = require('firebase-admin');
admin.initializeApp();

async function updateCategory() {
  const recipesRef = admin.firestore().collection('recipes');

  // English update
  const snapshotEn = await recipesRef.where('category', '==', 'Indian').get();
  for (const doc of snapshotEn.docs) {
    await doc.ref.update({ category: 'Desi/Indian' });
    console.log(`Updated recipe ${doc.id} (en)`);
  }

  // Korean update
  const snapshotKo = await recipesRef.where('category', '==', '인도식').get();
  for (const doc of snapshotKo.docs) {
    await doc.ref.update({ category: '인도/남아시아식' });
    console.log(`Updated recipe ${doc.id} (ko)`);
  }

  console.log('Category update complete!');
}

updateCategory();
