import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooki/data/data_source/recipe_generation_data_source.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/data_source/firebase_auth_data_source.dart';
import '../../data/data_source/google_sign_in_data_source.dart';
import '../../data/data_source/user_data_source.dart';
import 'image_storage_data_source.dart';

// GoogleSignInDataSource
final googleSignInProvider = Provider((ref) => GoogleSignIn());
final googleSignInDataSourceProvider = Provider<GoogleSignInDataSource>(
  (ref) => GoogleSignInDataSourceImpl(ref.read(googleSignInProvider)),
);

// FirebaseAuthDataSource
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>(
  (ref) => FirebaseAuthDataSourceImpl(ref.read(firebaseAuthProvider)),
);

// UserDataSource
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final userFirestoreDataSourceProvider = Provider<UserDataSource>(
  (ref) => UserFirestoreDataSource(ref.read(firestoreProvider)),
);

// ImageStorageDataSource
final imageStorageDataSourceProvider = Provider<ImageStorageDataSource>(
      (ref) => FirebaseImageStorageDataSource(FirebaseStorage.instance),
);

// RecipeGenerationDataSource
final firebaseAIProvider = Provider((ref) => FirebaseAI.googleAI());
final recipeGenerationDataSourceProvider = Provider<RecipeGenerationDataSource>(
      (ref) => GeminiRecipeGenerationDataSource(ref.read(firebaseAIProvider)),
);