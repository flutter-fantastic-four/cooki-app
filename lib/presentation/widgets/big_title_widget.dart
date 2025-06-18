import 'package:flutter/material.dart';

class BigTitleWidget extends StatelessWidget {
  final String title;

  const BigTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E1E1E),
      ),
    );
  }
}
