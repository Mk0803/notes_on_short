import 'package:logger/logger.dart';

// Create a singleton logger instance
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(), // Use PrettyPrinter for well-formatted logs
  );

  static void d(String message) => _logger.d(message); // Debug
  static void i(String message) => _logger.i(message); // Info
  static void w(String message) => _logger.w(message); // Warning
  static void e(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
