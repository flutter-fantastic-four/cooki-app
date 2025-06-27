import 'package:cooki/gen/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

import '../../data/data_source/review_data_source.dart';

class SortOption {
  final ReviewSortType type;
  final String Function(AppLocalizations) labelGetter;

  const SortOption({
    required this.type,
    required this.labelGetter,
  });

  String getLabel(AppLocalizations strings) => labelGetter(strings);
}