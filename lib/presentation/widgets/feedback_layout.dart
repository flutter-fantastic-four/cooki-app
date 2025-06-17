import 'package:flutter/material.dart';

class FeedbackLayout extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget illustration;

  const FeedbackLayout({
    super.key,
    required this.title,
    required this.illustration,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 500, child: illustration),
          SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 150),
        ],
      ),
    );
  }
}
