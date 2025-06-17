import 'package:flutter/cupertino.dart';

import '../../data/data_source/review_data_source.dart';

class SortOption {
  final ReviewSortType type;
  final String Function(BuildContext) labelGetter;

  const SortOption({
    required this.type,
    required this.labelGetter,
  });

  String getLabel(BuildContext context) => labelGetter(context);
}