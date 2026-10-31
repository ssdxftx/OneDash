class WebsiteCorsDto {
  const WebsiteCorsDto({
    required this.websiteID,
    this.cors = false,
    this.allowOrigins = '',
    this.allowMethods = '',
    this.allowHeaders = '',
    this.allowCredentials = false,
    this.preflight = false,
  });

  final int websiteID;
  final bool cors;
  final String allowOrigins;
  final String allowMethods;
  final String allowHeaders;
  final bool allowCredentials;
  final bool preflight;

  factory WebsiteCorsDto.fromJson(Map<String, dynamic> json) {
    return WebsiteCorsDto(
      websiteID: json['websiteID'] as int? ?? 0,
      cors: json['cors'] as bool? ?? false,
      allowOrigins: json['allowOrigins'] as String? ?? '',
      allowMethods: json['allowMethods'] as String? ?? '',
      allowHeaders: json['allowHeaders'] as String? ?? '',
      allowCredentials: json['allowCredentials'] as bool? ?? false,
      preflight: json['preflight'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'websiteID': websiteID,
      'cors': cors,
      'allowOrigins': allowOrigins,
      'allowMethods': allowMethods,
      'allowHeaders': allowHeaders,
      'allowCredentials': allowCredentials,
      'preflight': preflight,
    };
  }
}
