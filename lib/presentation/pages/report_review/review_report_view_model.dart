import 'package:cooki/domain/entity/app_user.dart';
import 'package:cooki/domain/entity/review/review.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../../data/dto/report_dto.dart';
import '../../../data/repository/providers.dart';
import '../../../domain/entity/report.dart';

class ReportState {
  final bool isLoading;
  final Set<ReportReason> selectedReasons;
  final String additionalContext;
  final bool isError;

  const ReportState({
    this.isLoading = false,
    this.selectedReasons = const {},
    this.additionalContext = '',
    this.isError = false,
  });

  ReportState copyWith({
    bool? isLoading,
    Set<ReportReason>? selectedReasons,
    String? additionalContext,
    bool? isError,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      selectedReasons: selectedReasons ?? this.selectedReasons,
      additionalContext: additionalContext ?? this.additionalContext,
      isError: isError ?? this.isError,
    );
  }

  bool get canSubmit => selectedReasons.isNotEmpty && !isLoading;
}

class ReviewReportViewModel extends AutoDisposeNotifier<ReportState> {
  @override
  ReportState build() {
    return const ReportState();
  }

  void toggleReason(ReportReason reason) {
    final currentReasons = Set<ReportReason>.from(state.selectedReasons);
    if (currentReasons.contains(reason)) {
      currentReasons.remove(reason);
    } else {
      currentReasons.add(reason);
    }
    state = state.copyWith(selectedReasons: currentReasons);
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
      reasons: state.selectedReasons,
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

  bool hasSelectedOther() {
    return state.selectedReasons.contains(ReportReason.other);
  }

  void clearError() {
    state = state.copyWith(isError: false);
  }
}

final reviewReportViewModelProvider =
    NotifierProvider.autoDispose<ReviewReportViewModel, ReportState>(
      ReviewReportViewModel.new,
    );
