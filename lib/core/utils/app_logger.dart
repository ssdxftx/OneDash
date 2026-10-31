import 'package:flutter/foundation.dart';
import 'log_sanitizer.dart';

/// 日志级别。
enum LogLevel { debug, info, warn, error }

/// 统一日志入口。
///
/// - release 模式只保留 warn / error
/// - 所有消息自动过 [LogSanitizer]
/// - 通过 [tag] 标记模块来源，便于过滤
class AppLogger {
  const AppLogger._();

  static const _minLevelRelease = LogLevel.warn;

  static void d(String tag, Object? msg) => _log(LogLevel.debug, tag, msg);
  static void i(String tag, Object? msg) => _log(LogLevel.info, tag, msg);
  static void w(String tag, Object? msg) => _log(LogLevel.warn, tag, msg);
  static void e(
    String tag,
    Object? msg, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, tag, msg);
    if (error != null) _log(LogLevel.error, tag, 'error: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrint(stackTrace.toString());
    }
  }

  static void _log(LogLevel level, String tag, Object? msg) {
    if (!_shouldLog(level)) return;
    final prefix = _prefix(level);
    final safe = LogSanitizer.sanitize(msg);
    debugPrint('$prefix [$tag] $safe');
  }

  static bool _shouldLog(LogLevel level) {
    if (kReleaseMode) return level.index >= _minLevelRelease.index;
    return true;
  }

  static String _prefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warn:
        return 'W';
      case LogLevel.error:
        return 'E';
    }
  }
}
