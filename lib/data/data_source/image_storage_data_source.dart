import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

abstract class ImageStorageDataSource {
  Future<String> uploadImageFile(File imageFile, String uid, String folder);
  Future<String> uploadImageBytes(Uint8List imageBytes, String uid, String folder);
}

class FirebaseImageStorageDataSource implements ImageStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseImageStorageDataSource(this._storage);

  @override
  Future<String> uploadImageFile(File imageFile, String uid, String folder) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final ref = _storage.ref().child('$folder/$uid/$fileName');

    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  @override
  Future<String> uploadImageBytes(Uint8List imageBytes, String uid, String folder) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('$folder/$uid/$fileName');

    await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }
}
