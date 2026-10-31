class WebsiteProxyDto {
  const WebsiteProxyDto({
    required this.id,
    required this.enable,
    required this.cache,
    required this.cacheTime,
    required this.cacheUnit,
    required this.serverCacheTime,
    required this.serverCacheUnit,
    required this.name,
    required this.modifier,
    required this.match,
    required this.proxyPass,
    required this.proxyHost,
    required this.content,
    required this.filePath,
    required this.replaces,
    required this.sni,
    required this.proxySSLName,
    required this.sslVerify,
    required this.cors,
    required this.allowOrigins,
    required this.allowMethods,
    required this.allowHeaders,
    required this.allowCredentials,
    required this.preflight,
  });

  final int id;
  final bool enable;
  final bool cache;
  final int cacheTime;
  final String cacheUnit;
  final int serverCacheTime;
  final String serverCacheUnit;
  final String name;
  final String modifier;
  final String match;
  final String proxyPass;
  final String proxyHost;
  final String content;
  final String filePath;
  final Map<String, String> replaces;
  final bool sni;
  final String proxySSLName;
  final bool sslVerify;
  final bool cors;
  final String allowOrigins;
  final String allowMethods;
  final String allowHeaders;
  final bool allowCredentials;
  final bool preflight;

  factory WebsiteProxyDto.fromJson(Map<String, dynamic> json) {
    final replacesJson = json['replaces'];
    final replaces = <String, String>{};
    if (replacesJson is Map) {
      for (final entry in replacesJson.entries) {
        replaces[entry.key.toString()] = entry.value?.toString() ?? '';
      }
    }
    return WebsiteProxyDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      enable: json['enable'] as bool? ?? false,
      cache: json['cache'] as bool? ?? false,
      cacheTime: (json['cacheTime'] as num?)?.toInt() ?? 0,
      cacheUnit: json['cacheUnit']?.toString() ?? '',
      serverCacheTime: (json['serverCacheTime'] as num?)?.toInt() ?? 0,
      serverCacheUnit: json['serverCacheUnit']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      modifier: json['modifier']?.toString() ?? '',
      match: json['match']?.toString() ?? '',
      proxyPass: json['proxyPass']?.toString() ?? '',
      proxyHost: json['proxyHost']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      filePath: json['filePath']?.toString() ?? '',
      replaces: replaces,
      sni: json['sni'] as bool? ?? false,
      proxySSLName: json['proxySSLName']?.toString() ?? '',
      sslVerify: json['sslVerify'] as bool? ?? false,
      cors: json['cors'] as bool? ?? false,
      allowOrigins: json['allowOrigins']?.toString() ?? '',
      allowMethods: json['allowMethods']?.toString() ?? '',
      allowHeaders: json['allowHeaders']?.toString() ?? '',
      allowCredentials: json['allowCredentials'] as bool? ?? false,
      preflight: json['preflight'] as bool? ?? false,
    );
  }
}
