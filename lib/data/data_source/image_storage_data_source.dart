import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

abstract class ImageStorageDataSource {
  Future<String> uploadImage(File imageFile, String uid, String folder);
}

class FirebaseImageStorageDataSource implements ImageStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseImageStorageDataSource(this._storage);

  @override
  Future<String> uploadImage(File imageFile, String uid, String folder) async {
    final ref = _storage.ref().child('$folder/$uid/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}');

    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}
