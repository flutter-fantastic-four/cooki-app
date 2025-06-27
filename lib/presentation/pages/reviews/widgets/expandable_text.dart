import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../core/utils/general_util.dart';

class ExpandableText extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final double fontSize;
  final VoidCallback onToggle;

  const ExpandableText({
    super.key,
    required this.text,
    required this.isExpanded,
    this.fontSize = 15,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const maxLines = 3;

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.black,
        height: 1.4,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    final isOverflowing = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
            height: 1.4,
          ),
          maxLines: isExpanded ? null : maxLines,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
        if (isOverflowing) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              isExpanded ? strings(context).less : strings(context).more,
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.greyScale400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
