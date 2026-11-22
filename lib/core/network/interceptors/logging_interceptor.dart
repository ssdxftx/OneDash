import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../utils/app_logger.dart';
import '../../utils/log_sanitizer.dart';

/// HTTP 请求/响应日志拦截器。
///
/// 仅在 debug 模式生效，避免 release 包日志膨胀。
/// 输出前由 [AppLogger] 自动脱敏。
class LoggingInterceptor extends Interceptor {
  static const _tag = 'network.http';

  /// 是否展示成功的响应数据。
  static bool showResponseData = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.d(
        _tag,
        '🚀 ${options.method} ${LogSanitizer.sanitize(options.uri)}',
      );
      if (options.data != null) {
        AppLogger.d(_tag, '   body: ${LogSanitizer.sanitize(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final status = response.statusCode ?? 0;
      final isOk = status == 200;
      final icon = isOk ? '✅' : '❌';

      AppLogger.d(
        _tag,
        '$icon $status ${LogSanitizer.sanitize(response.requestOptions.uri)}',
      );

      if ((showResponseData || !isOk) && response.data != null) {
        AppLogger.d(_tag, '   body: ${LogSanitizer.sanitize(response.data)}');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    if (!kDebugMode) {
      AppLogger.w(
        _tag,
        '${err.requestOptions.method} '
        '${LogSanitizer.sanitize(err.requestOptions.uri)} -> $status',
      );
      return handler.next(err);
    }
    AppLogger.w(
      _tag,
      '🚨 xxx ${err.requestOptions.method} '
      '${LogSanitizer.sanitize(err.requestOptions.uri)} -> '
      '$status ${LogSanitizer.sanitize(err.message)}',
    );
    if (err.response?.data != null) {
      AppLogger.w(
        _tag,
        '   body: ${LogSanitizer.sanitize(err.response?.data)}',
      );
    }
    handler.next(err);
  }
}
