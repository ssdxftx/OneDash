import 'website_ssl_dto.dart';

class WebsiteHttpsDto {
  const WebsiteHttpsDto({
    required this.enable,
    required this.httpConfig,
    this.ssl,
    this.sslProtocol,
    required this.algorithm,
    required this.hsts,
    required this.hstsIncludeSubDomains,
    required this.httpsPort,
    this.httpsPorts = const [],
    required this.http3,
  });

  final bool enable;
  final String httpConfig;
  final WebsiteSslDto? ssl;
  final List<String>? sslProtocol;
  final String algorithm;
  final bool hsts;
  final bool hstsIncludeSubDomains;
  final String httpsPort;
  final List<int> httpsPorts;
  final bool http3;

  factory WebsiteHttpsDto.fromJson(Map<String, dynamic> json) {
    return WebsiteHttpsDto(
      enable: json['enable'] as bool? ?? false,
      httpConfig: json['httpConfig'] as String? ?? '',
      ssl: json['SSL'] != null
          ? WebsiteSslDto.fromJson(json['SSL'] as Map<String, dynamic>)
          : null,
      sslProtocol: (json['SSLProtocol'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      algorithm: json['algorithm'] as String? ?? '',
      hsts: json['hsts'] as bool? ?? false,
      hstsIncludeSubDomains: json['hstsIncludeSubDomains'] as bool? ?? false,
      httpsPort: json['httpsPort'] as String? ?? '',
      httpsPorts: _ports(json['httpsPorts'], json['httpsPort']),
      http3: json['http3'] as bool? ?? false,
    );
  }

  static List<int> _ports(Object? list, Object? joined) {
    final result = <int>{};
    if (list is List) {
      for (final item in list) {
        final value = item is num ? item.toInt() : int.tryParse('$item');
        if (value != null && value > 0) result.add(value);
      }
    }
    if (joined is String) {
      for (final item in joined.split(',')) {
        final value = int.tryParse(item.trim());
        if (value != null && value > 0) result.add(value);
      }
    }
    return result.toList(growable: false);
  }
}

/// 构造绑定证书时提交给面板的 HTTPS 配置请求体。
Map<String, dynamic> buildWebsiteHttpsPayload({
  required int websiteId,
  required int sslId,
  required int acmeAccountId,
  required String type,
  required WebsiteHttpsDto https,
}) {
  return {
    'acmeAccountID': acmeAccountId,
    'enable': true,
    'websiteId': websiteId,
    'websiteSSLId': sslId,
    'type': type,
    'importType': 'local',
    'privateKey': '',
    'certificate': '',
    'privateKeyPath': '',
    'certificatePath': '',
    'httpConfig': https.httpConfig.isEmpty ? 'HTTPToHTTPS' : https.httpConfig,
    'hsts': https.hsts,
    'hstsIncludeSubDomains': https.hstsIncludeSubDomains,
    'algorithm': https.algorithm,
    'SSLProtocol': https.sslProtocol ?? const ['TLSv1.2', 'TLSv1.3'],
    'httpsPorts': https.httpsPorts.isEmpty ? const [443] : https.httpsPorts,
    'http3': https.http3,
  };
}
