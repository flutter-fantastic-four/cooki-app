import 'dart:io';
import 'dart:typed_data';
import '../data_source/image_storage_data_source.dart';

abstract class ImageRepository {
  Future<String> uploadImageFile(File imageFile, String uid, String folder);
  Future<String> uploadImageBytes(Uint8List imageBytes, String uid, String folder);
}

class ImageRepositoryImpl implements ImageRepository {
  final ImageStorageDataSource _dataSource;

  ImageRepositoryImpl(this._dataSource);

  @override
  Future<String> uploadImageFile(File imageFile, String uid, String folder) {
    return _dataSource.uploadImageFile(imageFile, uid, folder);
  }

  @override
  Future<String> uploadImageBytes(Uint8List imageBytes, String uid, String folder) {
    return _dataSource.uploadImageBytes(imageBytes, uid, folder);
  }
}
