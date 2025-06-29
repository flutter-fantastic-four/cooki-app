import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/utils/general_util.dart';
import '../../domain/entity/report.dart';

enum ReportReason {
  unrelatedDefamation,
  inappropriateContent,
  inappropriateAds,
  unrelatedPhoto,
  privacyViolation,
  offTopicContent,
  copyrightViolation,
  other;

  String getDisplayName(BuildContext context) {
    switch (this) {
      case ReportReason.unrelatedDefamation:
        return strings(context).reportReasonUnrelatedDefamation;
      case ReportReason.inappropriateContent:
        return strings(context).reportReasonInappropriateContent;
      case ReportReason.inappropriateAds:
        return strings(context).reportReasonInappropriateAds;
      case ReportReason.unrelatedPhoto:
        return strings(context).reportReasonUnrelatedPhoto;
      case ReportReason.privacyViolation:
        return strings(context).reportReasonPrivacyViolation;
      case ReportReason.offTopicContent:
        return strings(context).reportReasonOffTopicContent;
      case ReportReason.copyrightViolation:
        return strings(context).reportReasonCopyrightViolation;
      case ReportReason.other:
        return strings(context).reportReasonOther;
    }
  }
}

class ReportDto {
  final String id;
  final String reporterId;
  final String reporterName;
  final String? reporterImageUrl;
  final String reviewerId;
  final String reviewerName;
  final List<String> reasons;
  final String? additionalContext;
  final Timestamp createdAt;
  final bool isDeleted;

  const ReportDto({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    this.reporterImageUrl,
    required this.reviewerId,
    required this.reviewerName,
    required this.reasons,
    this.additionalContext,
    required this.createdAt,
    this.isDeleted = false,
  });

  factory ReportDto.fromMap(String id, Map<String, dynamic> map) {
    final rawReasons = map['reasons'] as List<dynamic>? ?? [];
    return ReportDto(
      id: id,
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      reporterImageUrl: map['reporterImageUrl'],
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      reasons: rawReasons.cast<String>(),
      additionalContext: map['additionalContext'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterImageUrl': reporterImageUrl,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reasons': reasons,
      'additionalContext': additionalContext,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
    };
  }

  factory ReportDto.fromEntity(Report report) {
    return ReportDto(
      id: report.id,
      reporterId: report.reporterId,
      reporterName: report.reporterName,
      reporterImageUrl: report.reporterImageUrl,
      reviewerId: report.reviewerId,
      reviewerName: report.reviewerName,
      reasons: report.reasons.map((r) => r.name).toList(),
      additionalContext: report.additionalContext,
      createdAt: Timestamp.fromDate(report.createdAt),
      isDeleted: report.isDeleted,
    );
  }

  Report toEntity() {
    return Report(
      id: id,
      reporterId: reporterId,
      reporterName: reporterName,
      reporterImageUrl: reporterImageUrl,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      reasons:
          reasons
              .map(
                (s) => ReportReason.values.firstWhere(
                  (r) => r.name == s,
                  orElse: () => ReportReason.other,
                ),
              )
              .toSet(),
      additionalContext: additionalContext,
      createdAt: createdAt.toDate(),
      isDeleted: isDeleted,
    );
  }
}
