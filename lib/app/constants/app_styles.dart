import 'package:flutter/material.dart';

abstract class AppStyles {
  //dimensions
  static const double mediumDimension = 24;

  static const mediumText = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold
  );

  static const cupertinoSheetTitle = TextStyle(fontSize: 17, color: Colors.black87);
  static const cupertinoSheetActionText = TextStyle(color: Colors.blueAccent);
}
