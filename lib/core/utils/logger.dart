import 'dart:developer';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Logs an error (e.g., exception + stack trace) to both local and Crashlytics.
void logError(
  dynamic error,
  StackTrace stack, {
  String? reason,
  bool fatal = false,
}) {
  final message =
      reason != null ? '[EXCEPTION] $reason\n$error' : '[EXCEPTION] $error';
  log(message, stackTrace: stack);

  FirebaseCrashlytics.instance.recordError(
    error,
    stack,
    reason: reason,
    fatal: fatal,
  );
}
