import 'package:cloud_chat/logger.dart';

class ConsoleLogger extends Logger {
  @override
  void error(String message, {Error? error, Exception? exception}) =>
      print("[ERROR] $message {error: $error, exception: $exception}");

  @override
  void info(String message) => print("[INFO] $message");

  @override
  void warn(String message, {Error? error, Exception? exception}) =>
      print("[WARN] $message {error: $error, exception: $exception}");
}
