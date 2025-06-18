import '../../domain/entity/report.dart';
import '../data_source/review_report_data_source.dart';
import '../dto/report_dto.dart';

abstract class ReportRepository {
  Future<String> createReport({
    required String recipeId,
    required String reviewId,
    required Report report,
  });
}

class ReportRepositoryImpl implements ReportRepository {
  final ReviewReportDataSource _dataSource;

  ReportRepositoryImpl(this._dataSource);

  @override
  Future<String> createReport({
    required String recipeId,
    required String reviewId,
    required Report report,
  }) async {
    final reportDto = ReportDto.fromEntity(report);
    return await _dataSource.createReport(
      recipeId: recipeId,
      reviewId: reviewId,
      reportDto: reportDto,
    );
  }
}
