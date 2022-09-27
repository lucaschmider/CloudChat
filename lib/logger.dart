import 'package:flutter/material.dart';

@immutable
abstract class Logger {
  const Logger();
  void info(String message);
  void warn(String message, {Error? error, Exception? exception});
  void error(String message, {Error? error, Exception? exception});
}
