import 'dart:typed_data';
import 'package:dio/dio.dart';

abstract class ImageDownloadDataSource {
  Future<Uint8List> downloadImage(String url);
}

class DioImageDownloadDataSource implements ImageDownloadDataSource {
  final Dio _dio;

  DioImageDownloadDataSource(this._dio);

  @override
  Future<Uint8List> downloadImage(String url) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }
}
