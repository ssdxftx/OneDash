import 'website_dto.dart';
import 'website_ssl_dto.dart';

class WebsiteDomainDto {
  const WebsiteDomainDto({
    required this.id,
    required this.domain,
    required this.port,
    required this.ssl,
    this.createdAt = '',
    this.updatedAt = '',
  });

  final int id;
  final String domain;
  final int port;
  final bool ssl;
  final String createdAt;
  final String updatedAt;

  factory WebsiteDomainDto.fromJson(Map<String, dynamic> json) {
    return WebsiteDomainDto(
      id: json['id'] as int? ?? 0,
      domain: json['domain'] as String? ?? '',
      port: json['port'] as int? ?? 0,
      ssl: json['ssl'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}

class WebsiteDetailDto {
  const WebsiteDetailDto({
    required this.website,
    required this.alias,
    required this.errorLogPath,
    required this.accessLogPath,
    required this.webSiteGroupId,
    required this.webSiteSSLId,
    required this.ipv6,
    required this.accessLog,
    required this.errorLog,
    required this.defaultServer,
    required this.favorite,
    required this.domains,
    required this.ssl,
  });

  final WebsiteDto website;
  final String alias;
  final String errorLogPath;
  final String accessLogPath;
  final int webSiteGroupId;
  final int webSiteSSLId;
  final bool ipv6;
  final bool accessLog;
  final bool errorLog;
  final bool defaultServer;
  final bool favorite;
  final List<WebsiteDomainDto> domains;
  final WebsiteSslDto? ssl;

  factory WebsiteDetailDto.fromJson(Map<String, dynamic> json) {
    final domainsJson = json['domains'] as List?;
    final sslJson = json['webSiteSSL'];
    return WebsiteDetailDto(
      website: WebsiteDto.fromJson(json),
      alias: json['alias'] as String? ?? '',
      errorLogPath: json['errorLogPath'] as String? ?? '',
      accessLogPath: json['accessLogPath'] as String? ?? '',
      webSiteGroupId: json['webSiteGroupId'] as int? ?? 0,
      webSiteSSLId: json['webSiteSSLId'] as int? ?? 0,
      ipv6: json['IPV6'] as bool? ?? false,
      accessLog: json['accessLog'] as bool? ?? false,
      errorLog: json['errorLog'] as bool? ?? false,
      defaultServer: json['defaultServer'] as bool? ?? false,
      favorite: json['favorite'] as bool? ?? false,
      domains:
          domainsJson
              ?.whereType<Map<String, dynamic>>()
              .map(WebsiteDomainDto.fromJson)
              .toList(growable: false) ??
          const [],
      ssl: sslJson is Map<String, dynamic>
          ? WebsiteSslDto.fromJson(sslJson)
          : null,
    );
  }
}
