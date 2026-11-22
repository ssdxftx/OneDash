import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 移动端终端身份头。
///
/// 服务端要求 WebSocket 与终端会话接口携带一致的用户 ID 与会话 ID。
/// 这里基于 API Key 派生稳定身份，避免在请求中暴露密钥本身。
class TerminalIdentity {
  const TerminalIdentity._();

  static const headerUserId = 'X-Panel-User-ID';
  static const headerAuthSessionId = 'X-Panel-Auth-Session-ID';

  static Map<String, String> headers({required String apiKey}) {
    final digest = sha256.convert(utf8.encode('onedash:$apiKey')).toString();
    final userId = 'onedash-${digest.substring(0, 16)}';
    return {headerUserId: userId, headerAuthSessionId: 'mobile:$digest'};
  }
}
