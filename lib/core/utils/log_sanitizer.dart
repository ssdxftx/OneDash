/// 日志脱敏工具：在输出敏感信息前对常见敏感字段做替换。
///
/// 覆盖场景：
/// - HTTP Header 中的 `1Panel-Token`、`Authorization`
/// - JSON 体中的 `token / password / apiKey / cookie / phone`
/// - Cookie 字符串中的 `session / authorization_token`
class LogSanitizer {
  const LogSanitizer._();

  static final List<RegExp> _patterns = [
    RegExp(r'(authorization_token=)[^;,\s]+', caseSensitive: false),
    RegExp(r'(session=)[^;,\s]+', caseSensitive: false),
    RegExp(r'("token"\s*:\s*")[^"]+(")', caseSensitive: false),
    RegExp(r'("apiKey"\s*:\s*")[^"]+(")', caseSensitive: false),
    RegExp(r'("cookie"\s*:\s*")[^"]+(")', caseSensitive: false),
    RegExp(r'("password"\s*:\s*")[^"]+(")', caseSensitive: false),
    RegExp(r'("phone"\s*:\s*")[^"]+(")', caseSensitive: false),
    RegExp(r'(1Panel-Token:\s*)\S+', caseSensitive: false),
  ];

  /// 替换敏感字段为 `***`，非字符串输入直接转 `toString`。
  static String sanitize(Object? input) {
    if (input == null) return '';
    var text = input.toString();
    for (final pattern in _patterns) {
      text = text.replaceAllMapped(pattern, (m) {
        final prefix = m.group(1) ?? '';
        final suffix = m.groupCount >= 2 ? (m.group(2) ?? '') : '';
        return '$prefix***$suffix';
      });
    }
    return text;
  }
}
