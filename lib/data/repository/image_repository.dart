import 'dart:io';
import '../data_source/image_storage_data_source.dart';

abstract class ImageRepository {
  Future<String> uploadImage(File imageFile, String uid, String folder);
}

class ImageRepositoryImpl implements ImageRepository {
  final ImageStorageDataSource _dataSource;

  ImageRepositoryImpl(this._dataSource);

  @override
  Future<String> uploadImage(File imageFile, String uid, String folder) {
    return _dataSource.uploadImage(imageFile, uid, folder);
  }
}
