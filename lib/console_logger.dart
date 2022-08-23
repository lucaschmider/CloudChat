import 'package:cloud_chat/logger.dart';
import 'package:flutter/foundation.dart';

class ConsoleLogger extends Logger {
  @override
  void error(String message, {Error? error, Exception? exception}) {
    if (kDebugMode) {
      print("[ERROR] $message {error: $error, exception: $exception}");
    }
  }

  @override
  void info(String message) {
    if (kDebugMode) {
      print("[INFO] $message");
    }
  }

  @override
  void warn(String message, {Error? error, Exception? exception}) {
    if (kDebugMode) {
      print("[WARN] $message {error: $error, exception: $exception}");
    }
  }
}
