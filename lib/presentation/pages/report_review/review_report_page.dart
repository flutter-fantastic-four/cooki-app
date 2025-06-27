import 'package:cooki/presentation/pages/report_review/review_report_view_model.dart';
import 'package:cooki/presentation/widgets/input_decorations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/utils/dialogue_util.dart';
import '../../../core/utils/general_util.dart';
import '../../../core/utils/snackbar_util.dart';
import '../../../data/dto/report_dto.dart';
import '../../../domain/entity/review.dart';
import '../../user_global_view_model.dart';
import '../../widgets/selectable_option_row.dart';

class ReviewReportPage extends ConsumerStatefulWidget {
  final String recipeId;
  final Review review;

  const ReviewReportPage({
    super.key,
    required this.recipeId,
    required this.review,
  });

  @override
  ConsumerState<ReviewReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReviewReportPage> {
  final TextEditingController _contextController = TextEditingController();

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    await ref
        .read(reviewReportViewModelProvider.notifier)
        .submitReport(
          recipeId: widget.recipeId,
          review: widget.review,
          currentUser: ref.read(userGlobalViewModelProvider)!,
        );

    final state = ref.read(reviewReportViewModelProvider);
    if (mounted && state.isError) {
      DialogueUtil.showAppDialog(
        context: context,
        title: strings(context).genericErrorTitle,
        content: strings(context).reportError,
      );
      ref.read(reviewReportViewModelProvider.notifier).clearError();
    }

    if (mounted) {
      SnackbarUtil.showSnackBar(
        context,
        strings(context).reportSubmitted,
        showIcon: true,
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewReportViewModelProvider);

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings(context).reportReviewTitle),
          // elevation: 1,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionSection(),
                  SizedBox(height: 10),
                  _buildReasonSelection(state),
                  const SizedBox(height: 16.0),
                  _buildAdditionalContextField(),
                ],
              ),
            ),
            if (state.isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 20),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _buildSubmitButton(state),
      ),
    );
  }

  Widget _buildInstructionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings(context).selectReportReason,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: AppColors.greyScale800,
          ),
        ),
        SizedBox(height: 2),
        Text(
          strings(context).reportReasonWarning,
          style: const TextStyle(fontSize: 13, color: AppColors.greyScale600),
          maxLines: 2,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildReasonSelection(ReportState state) {
    return Column(
      children:
          ReportReason.values.map((reason) {
            return SelectableOptionRow(
              text: reason.getDisplayName(context),
              isSelected: state.selectedReason == reason,
              onTap: () => ref
                  .read(reviewReportViewModelProvider.notifier)
                  .setSelectedReason(reason),
            );
          }).toList(),
    );
  }

  Widget _buildAdditionalContextField() {
    return TextField(
      controller: _contextController,
      onChanged:
          (value) => ref
              .read(reviewReportViewModelProvider.notifier)
              .setAdditionalContext(value),
      maxLines: 6,
      maxLength: 600,
      decoration: getInputDecoration(strings(context).additionalContextHint),
    );
  }

  Widget _buildSubmitButton(ReportState state) {
    final canSubmit = state.canSubmit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 33),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: canSubmit ? _submitReport : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(
            strings(context).submitReport,
          ),
        ),
      ),
    );
  }
}
