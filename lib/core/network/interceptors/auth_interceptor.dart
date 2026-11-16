import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../utils/app_logger.dart';
import '../panel_session.dart';

/// 1Panel MD5 鉴权拦截器，同时为面板登录会话附加 Cookie 与 CSRF 头。
///
/// API Key 规则：`MD5("1panel" + apiKey + unixSecondTimestamp)`
/// 注意：时间戳必须是**秒级**，毫秒级会 401。
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._apiKey, [this._session]);

  static const _tag = 'network.auth';
  static const _prefix = '1panel';
  static const _headerToken = '1Panel-Token';
  static const _headerTimestamp = '1Panel-Timestamp';
  static const _headerCookie = 'Cookie';
  static const _headerCsrf = 'X-CSRF-Token';

  String _apiKey;
  PanelSession? _session;

  PanelSession? get session => _session;

  String get apiKey => _apiKey;

  /// 切换 API Key（服务器切换时调用）。
  void updateApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  /// 更新或清除面板登录会话。
  void updateSession(PanelSession? session) {
    _session = session;
  }

  static bool _isSessionOnly(String path) {
    if (path.startsWith('/api/v2/core/auth/api/keys/')) return true;
    return switch (path) {
      '/api/v2/core/auth/api/generate' ||
      '/api/v2/core/auth/api/update' ||
      '/api/v2/core/auth/passkey/register/begin' ||
      '/api/v2/core/auth/passkey/register/finish' ||
      '/api/v2/core/auth/logout' => true,
      _ => false,
    };
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final skipAuth = options.extra['skipAuth'] == true;
    final skipSession = options.extra['skipSession'] == true;
    final session = _session;
    final unsafeMethod = !const [
      'GET',
      'HEAD',
      'OPTIONS',
      'TRACE',
    ].contains(options.method.toUpperCase());

    if (session != null && !skipSession) {
      options.headers[_headerCookie] = session.cookieHeader;
      if (unsafeMethod && session.csrfToken.isNotEmpty) {
        options.headers[_headerCsrf] = session.csrfToken;
      }
    }

    final sessionOnly =
        _isSessionOnly(options.path) ||
        (session != null && options.path.startsWith('/api/v2/core/auth/'));
    if (skipAuth || sessionOnly) {
      options.headers.remove(_headerToken);
      options.headers.remove(_headerTimestamp);
      if (!sessionOnly && skipAuth) {
        if (options.extra['logSkipAuth'] == true) {
          AppLogger.d(_tag, '跳过 API Key 鉴权：${options.path}');
        }
      }
      handler.next(options);
      return;
    }

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
