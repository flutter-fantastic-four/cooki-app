import 'package:cooki/domain/entity/app_user.dart';
import 'package:cooki/domain/entity/review/review.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../../data/dto/report_dto.dart';
import '../../../data/repository/providers.dart';
import '../../../domain/entity/report.dart';

class ReportState {
  final bool isLoading;
  final ReportReason? selectedReason;
  final String additionalContext;
  final bool isError;

  const ReportState({
    this.isLoading = false,
    this.selectedReason,
    this.additionalContext = '',
    this.isError = false,
  });

  ReportState copyWith({
    bool? isLoading,
    ReportReason? selectedReason,
    String? additionalContext,
    bool? isError,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      selectedReason: selectedReason ?? this.selectedReason,
      additionalContext: additionalContext ?? this.additionalContext,
      isError: isError ?? this.isError,
    );
  }

  bool get canSubmit => selectedReason != null && !isLoading;
}

class ReviewReportViewModel extends AutoDisposeNotifier<ReportState> {
  @override
  ReportState build() {
    return const ReportState();
  }

  void setSelectedReason(ReportReason reason) {
    state = state.copyWith(selectedReason: reason);
  }

  void setAdditionalContext(String context) {
    state = state.copyWith(additionalContext: context);
  }

  Future<void> submitReport({
    required String recipeId,
    required Review review,
    required AppUser currentUser,
  }) async {
    if (!state.canSubmit) return;

    state = state.copyWith(isLoading: true);
    final report = Report(
      id: '',
      // Will be set by Firestore
      reporterId: currentUser.id,
      reporterName: currentUser.name,
      reporterImageUrl: currentUser.profileImage,
      reviewerId: review.userId,
      reviewerName: review.userName,
      reason: state.selectedReason!,
      additionalContext:
      state.additionalContext.trim().isEmpty
          ? null
          : state.additionalContext.trim(),
    );
    try {
      await ref
          .read(reportRepositoryProvider)
          .createReport(
            recipeId: recipeId,
            reviewId: review.id,
            report: report,
          );
    } catch (e, stack) {
      logError(e, stack);
      state = state.copyWith(isError: true);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(isError: false);
  }
}

final reviewReportViewModelProvider =
    NotifierProvider.autoDispose<ReviewReportViewModel, ReportState>(
      ReviewReportViewModel.new,
    );
