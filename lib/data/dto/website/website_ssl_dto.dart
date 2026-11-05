import 'dart:convert';

class WebsiteSslDto {
  const WebsiteSslDto({
    required this.id,
    required this.primaryDomain,
    required this.provider,
    required this.type,
    required this.status,
    required this.expireDate,
    required this.acmeAccountId,
    this.domains = const [],
  });

  final int id;
  final String primaryDomain;
  final String provider;
  final String type;
  final String status;
  final String expireDate;
  final int acmeAccountId;
  final List<String> domains;

  bool get isBound => id > 0;

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
      domains: _parseDomains(json['domains']),
    );
  }
}

List<String> _parseDomains(Object? raw) {
  if (raw == null) return const [];
  if (raw is List) {
    return raw
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  if (raw is String) {
    final text = raw.trim();
    if (text.isEmpty) return const [];
    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        return decoded
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }
    } on FormatException {
      // Some panels return a comma separated list instead of JSON.
    }
    return text
        .split(RegExp(r'[,\s]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  return const [];
}
