import 'dart:convert';

/// 1Panel 面板登录会话。
///
/// `psession` 是 HttpOnly 会话 Cookie，`pcsrftoken` 用于同步写请求的
/// `X-CSRF-Token` 头。两者仅在当前服务器内有效。
class PanelSession {
  const PanelSession({required this.sessionId, required this.csrfToken});

  final String sessionId;
  final String csrfToken;

  String get cookieHeader => csrfToken.isEmpty
      ? 'psession=$sessionId'
      : 'psession=$sessionId; pcsrftoken=$csrfToken';

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'csrfToken': csrfToken,
  };

  factory PanelSession.fromJson(Map<String, dynamic> json) {
    return PanelSession(
      sessionId: json['sessionId']?.toString() ?? '',
      csrfToken: json['csrfToken']?.toString() ?? '',
    );
  }

  static PanelSession? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return null;
      final session = PanelSession.fromJson(Map<String, dynamic>.from(data));
      return session.sessionId.isEmpty ? null : session;
    } catch (_) {
      return null;
    }
  }

  String encode() => jsonEncode(toJson());
}

class PanelLoginResult {
  const PanelLoginResult({
    required this.session,
    required this.mfaStatus,
    required this.mfaSession,
  });

  final PanelSession? session;
  final String mfaStatus;
  final String mfaSession;

  bool get needsMfa =>
      mfaStatus.toLowerCase() == 'enable' && mfaSession.isNotEmpty;
}
