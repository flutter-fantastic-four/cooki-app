import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooki/data/data_source/recipe_generation_data_source.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'firebase_auth_data_source.dart';
import 'oauth_sign_in_data_source.dart';
import '../../data/data_source/user_data_source.dart';
import 'image_storage_data_source.dart';

// firebase_providers
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final firebaseFunctionsProvider = Provider((ref) => FirebaseFunctions.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final firebaseAIProvider = Provider((ref) => FirebaseAI.googleAI());

// oauth_providers
final googleSignInProvider = Provider((ref) => GoogleSignIn());
final kakaoSignInProvider = Provider((ref) => UserApi.instance);

// data_source_providers
final googleSignInDataSourceProvider = Provider<OAuthSignInDataSource>((ref) => GoogleOAuthDataSourceImpl(ref.read(googleSignInProvider)));

final kakaoSignInDataSourceProvider = Provider<OAuthSignInDataSource>((ref) => KakaoOAuthDataSourceImpl(ref.read(kakaoSignInProvider)));

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>(
  (ref) => FirebaseAuthDataSourceImpl(ref.read(firebaseAuthProvider), ref.read(firebaseFunctionsProvider)),
);

final userFirestoreDataSourceProvider = Provider<UserDataSource>((ref) => UserFirestoreDataSource(ref.read(firestoreProvider)));

final imageStorageDataSourceProvider = Provider<ImageStorageDataSource>((ref) => FirebaseImageStorageDataSource(FirebaseStorage.instance));

final recipeGenerationDataSourceProvider = Provider<RecipeGenerationDataSource>(
  (ref) => GeminiRecipeGenerationDataSource(ref.read(firebaseAIProvider)),
);
