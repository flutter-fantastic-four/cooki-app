import 'dart:typed_data';
import '../data_source/image_download_data_source.dart';

abstract class ImageDownloadRepository {
  Future<Uint8List> downloadImage(String url);
}

class ImageDownloadRepositoryImpl implements ImageDownloadRepository {
  final ImageDownloadDataSource _dataSource;

  ImageDownloadRepositoryImpl(this._dataSource);

  @override
  Future<Uint8List> downloadImage(String url) {
    return _dataSource.downloadImage(url);
  }
}
