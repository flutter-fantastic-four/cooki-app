import '../../data/dto/report_dto.dart';

class Report {
  final String id;
  final String reporterId;
  final String reporterName;
  final String? reporterImageUrl;
  final String reviewerId;
  final String reviewerName;
  final Set<ReportReason> reasons;
  final String? additionalContext;
  final DateTime createdAt;
  final bool isDeleted;

  Report({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    this.reporterImageUrl,
    required this.reviewerId,
    required this.reviewerName,
    required this.reasons,
    this.additionalContext,
    DateTime? createdAt,
    this.isDeleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Report copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? reporterImageUrl,
    String? reviewerId,
    String? reviewerName,
    Set<ReportReason>? reasons,
    String? additionalContext,
    DateTime? createdAt,
    bool? isDeleted,
  }) {
    return Report(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reporterImageUrl: reporterImageUrl ?? this.reporterImageUrl,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reasons: reasons ?? this.reasons,
      additionalContext: additionalContext ?? this.additionalContext,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'Report(id: $id, reasons: ${reasons.map((r) => r.name).join(", ")})';
  }
}
