class WebsiteSslDto {
  const WebsiteSslDto({
    required this.id,
    required this.primaryDomain,
    required this.provider,
    required this.type,
    required this.status,
    required this.expireDate,
    required this.acmeAccountId,
  });

  final int id;
  final String primaryDomain;
  final String provider;
  final String type;
  final String status;
  final String expireDate;
  final int acmeAccountId;

  String get displayName {
    final domain = primaryDomain.isEmpty ? '证书 #$id' : primaryDomain;
    final suffix = provider.isEmpty ? type : provider;
    return suffix.isEmpty ? domain : '$domain · $suffix';
  }

  factory WebsiteSslDto.fromJson(Map<String, dynamic> json) {
    return WebsiteSslDto(
      id: json['id'] as int? ?? 0,
      primaryDomain: json['primaryDomain'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      expireDate: json['expireDate'] as String? ?? '',
      acmeAccountId: json['acmeAccountId'] as int? ?? 0,
    );
  }
}
