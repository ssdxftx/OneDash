class McpDomainDto {
  const McpDomainDto({
    required this.domain,
    required this.sslID,
    required this.acmeAccountID,
    required this.allowIPs,
    required this.websiteID,
    required this.connUrl,
  });

  final String domain;
  final int sslID;
  final int acmeAccountID;
  final List<String> allowIPs;
  final int websiteID;
  final String connUrl;

  factory McpDomainDto.fromJson(Map<String, dynamic> json) {
    return McpDomainDto(
      domain: json['domain'] as String? ?? '',
      sslID: (json['sslID'] as num?)?.toInt() ?? 0,
      acmeAccountID: (json['acmeAccountID'] as num?)?.toInt() ?? 0,
      allowIPs:
          (json['allowIPs'] as List?)
              ?.map((item) => '$item')
              .toList(growable: false) ??
          const [],
      websiteID: (json['websiteID'] as num?)?.toInt() ?? 0,
      connUrl: json['connUrl'] as String? ?? '',
    );
  }
}
