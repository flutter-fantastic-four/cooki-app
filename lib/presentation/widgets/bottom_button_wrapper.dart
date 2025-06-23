import 'package:flutter/material.dart';

class BottomButtonWrapper extends StatelessWidget {
  final Widget child;

  const BottomButtonWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 41),
      child: child,
    );
  }
}
