import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../data/data_source/firebase_auth_data_source.dart';
import 'sign_in_data_source.dart';
import '../../data/data_source/user_data_source.dart';
import 'image_storage_data_source.dart';

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final googleSignInProvider = Provider((ref) => GoogleSignIn());
final kakaoSignInProvider = Provider((ref) => UserApi.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final googleSignInDataSourceProvider = Provider<SignInDataSource>(
  (ref) => GoogleSignInDataSourceImpl(ref.read(googleSignInProvider)),
);

final kakaoSignInDataSourceProvider = Provider<SignInDataSource>(
  (ref) => KakaoSignInDataSourceImpl(ref.read(kakaoSignInProvider)),
);

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>(
  (ref) => FirebaseAuthDataSourceImpl(ref.read(firebaseAuthProvider)),
);

final userFirestoreDataSourceProvider = Provider<UserFirestoreDataSource>(
  (ref) => UserFirestoreDataSource(ref.read(firestoreProvider)),
);

final imageStorageDataSourceProvider = Provider<ImageStorageDataSource>(
  (ref) => FirebaseImageStorageDataSource(FirebaseStorage.instance),
);
