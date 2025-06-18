import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'general_util.dart';

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
  static String formatRelativeTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();

    final diffSec = now.difference(dateTime).inSeconds;
    final diffMin = now.difference(dateTime).inMinutes;
    final diffHour = now.difference(dateTime).inHours;

    if (diffSec <= 0) {
      return strings(context).timeSeconds(0);
    } else if (diffSec >= 1 && diffSec < 60) {
      return strings(context).timeSeconds(diffSec);
    } else if (diffSec >= 60 && diffSec < 60 * 60) {
      return strings(context).timeMinutes(diffMin);
    } else if (diffSec >= 60 * 60 && diffSec < 60 * 60 * 24) {
      return strings(context).timeHours(diffHour);
    } else if (diffSec >= 60 * 60 * 24 && dateTime.year == now.year) {
      return strings(context).timeMonthDay(dateTime.month, dateTime.day);
    } else {
      return strings(context).timeYearMonthDay(dateTime.year, dateTime.month, dateTime.day);
    }
  }

  /// Formats [dateTime] into a short timestamp-style string:
  ///
  /// - If today: returns time in `'오전/오후 h:mm'` format.
  /// - If yesterday: returns `'어제'`.
  /// - Same year: returns `'M월 d일'`.
  /// - Different year: returns `'yyyy.MM.dd'`.
  static String formatCompactDateTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      // Today: 오전 11:23
      return DateFormat('a h:mm', 'ko').format(dateTime);
    } else if (date == yesterday) {
      // Yesterday
      return strings(context).yesterday;
    } else if (dateTime.year == now.year) {
      // Same year: 2월 23일
      return strings(context).timeMonthDay(dateTime.month, dateTime.day);
    } else {
      // Different year: 2023.04.24
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }
  }
}