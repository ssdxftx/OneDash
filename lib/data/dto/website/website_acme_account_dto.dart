class WebsiteAcmeAccountDto {
  const WebsiteAcmeAccountDto({
    required this.id,
    required this.email,
    required this.type,
    required this.url,
    required this.useProxy,
  });

  const WebsiteAcmeAccountDto.manual()
    : id = 0,
      email = '手动创建',
      type = 'manual',
      url = '',
      useProxy = false;

  final int id;
  final String email;
  final String type;
  final String url;
  final bool useProxy;

  String get displayName {
    if (id == 0) return email;
    if (email.isNotEmpty) return email;
    return 'ACME #$id';
  }

  factory WebsiteAcmeAccountDto.fromJson(Map<String, dynamic> json) {
    return WebsiteAcmeAccountDto(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      type: json['type'] as String? ?? '',
      url: json['url'] as String? ?? '',
      useProxy: json['useProxy'] as bool? ?? false,
    );
  }
}
