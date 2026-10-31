import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../utils/app_logger.dart';

/// 1Panel MD5 鉴权拦截器。
///
/// 规则：`MD5("1panel" + apiKey + unixSecondTimestamp)`
/// 注意：时间戳必须是**秒级**，毫秒级会 401。
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._apiKey);

  static const _tag = 'network.auth';
  static const _prefix = '1panel';
  static const _headerToken = '1Panel-Token';
  static const _headerTimestamp = '1Panel-Timestamp';

  String _apiKey;

  /// 切换 API Key（服务器切换时调用）。
  void updateApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_apiKey.isEmpty) {
      AppLogger.w(_tag, 'API Key 为空，跳过鉴权');
      return handler.next(options);
    }

    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final token = _sign(_apiKey, timestamp);

    options.headers[_headerToken] = token;
    options.headers[_headerTimestamp] = timestamp;
    handler.next(options);
  }

  static String _sign(String apiKey, String timestamp) {
    final raw = '$_prefix$apiKey$timestamp';
    return md5.convert(utf8.encode(raw)).toString();
  }
}
