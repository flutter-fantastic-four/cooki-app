import 'package:intl/intl.dart';

class DateTimeUtil {
  /// Formats [dateTime] relative to [now], returning a human-readable "time ago" string.
  ///
  /// 1시간 미만이면 'n분'.
  ///
  /// 24시간 미만이면 'n시간'.
  ///
  /// 24시간 이상이면:
  /// - Same year: returns `'M월 d일'`.
  /// - Different year: returns `'yyyy년 M월 d일'`.
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();

    final diffSec = now.difference(dateTime).inSeconds;
    final diffMin = now.difference(dateTime).inMinutes;
    final diffHour = now.difference(dateTime).inHours;

    if (diffSec <= 0) {
      return '0초';
    } else if (diffSec >= 1 && diffSec < 60) {
      return '$diffSec초';
    } else if (diffSec >= 60 && diffSec < 60 * 60) {
      return '$diffMin분';
    } else if (diffSec >= 60 * 60 && diffSec < 60 * 60 * 24) {
      return '$diffHour시간';
    } else if (diffSec >= 60 * 60 * 24 && dateTime.year == now.year) {
      return '${dateTime.month}월 ${dateTime.day}일';
    } else {
      return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일';
    }
  }

  /// Formats [dateTime] into a short timestamp-style string:
  ///
  /// - If today: returns time in `'오전/오후 h:mm'` format.
  /// - If yesterday: returns `'어제'`.
  /// - Same year: returns `'M월 d일'`.
  /// - Different year: returns `'yyyy.MM.dd'`.
  static String formatCompactDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      // Today: 오전 11:23
      return DateFormat('a h:mm', 'ko').format(dateTime);
    } else if (date == yesterday) {
      // Yesterday
      return '어제';
    } else if (dateTime.year == now.year) {
      // Same year: 2월 23일
      return DateFormat('M월 d일').format(dateTime);
    } else {
      // Different year: 2023.04.24
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }
  }
}
