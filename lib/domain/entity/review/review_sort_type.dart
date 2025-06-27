import 'package:cooki/gen/l10n/app_localizations.dart';

enum ReviewSortType {
  dateDescending,
  ratingAscending,
  ratingDescending;

  String getLabel(AppLocalizations strings) {
    switch (this) {
      case ReviewSortType.dateDescending:
        return strings.newestFirst;
      case ReviewSortType.ratingAscending:
        return strings.lowestRating;
      case ReviewSortType.ratingDescending:
        return strings.highestRating;
    }
  }
}