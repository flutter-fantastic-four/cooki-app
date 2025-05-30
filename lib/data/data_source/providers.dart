import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/data_source/firebase_auth_data_source.dart';
import '../../data/data_source/google_sign_in_data_source.dart';
import '../../data/data_source/user_data_source.dart';
import 'image_storage_data_source.dart';

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final googleSignInProvider = Provider((ref) => GoogleSignIn());
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final googleSignInDataSourceProvider = Provider<GoogleSignInDataSource>(
  (ref) => GoogleSignInDataSourceImpl(ref.read(googleSignInProvider)),
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