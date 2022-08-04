abstract class Logger {
  void info(String message);
  void warn(String message, {Error? error, Exception? exception});
  void error(String message, {Error? error, Exception? exception});
}
