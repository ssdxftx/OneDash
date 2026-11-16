class ApiKeyItemDto {
  const ApiKeyItemDto({
    required this.id,
    required this.kind,
    required this.name,
    required this.description,
    required this.keyHint,
    required this.status,
    required this.ipWhiteList,
    required this.apiTrustedProxies,
    required this.apiKeyValidityTime,
    required this.expiresAt,
    required this.allowAppBinding,
    required this.revision,
    required this.createdAt,
  });

  final String id;
  final String kind;
  final String name;
  final String description;
  final String keyHint;
  final String status;
  final String ipWhiteList;
  final String apiTrustedProxies;
  final int apiKeyValidityTime;
  final DateTime? expiresAt;
  final bool allowAppBinding;
  final int revision;
  final DateTime? createdAt;

  factory ApiKeyItemDto.fromJson(Map<String, dynamic> json) {
    return ApiKeyItemDto(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      keyHint: json['keyHint']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      ipWhiteList: json['ipWhiteList']?.toString() ?? '',
      apiTrustedProxies: json['apiTrustedProxies']?.toString() ?? '',
      apiKeyValidityTime: _int(json['apiKeyValidityTime']),
      expiresAt: _date(json['expiresAt']),
      allowAppBinding: json['allowAppBinding'] == true,
      revision: _int(json['revision']),
      createdAt: _date(json['createdAt']),
    );
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static DateTime? _date(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

class ApiKeyCreatedDto {
  const ApiKeyCreatedDto({
    required this.item,
    required this.apiKey,
    required this.alreadyCreated,
  });

  final ApiKeyItemDto item;
  final String apiKey;
  final bool alreadyCreated;

  factory ApiKeyCreatedDto.fromJson(Map<String, dynamic> json) {
    return ApiKeyCreatedDto(
      item: ApiKeyItemDto.fromJson(
        (json['item'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      apiKey: json['apiKey']?.toString() ?? '',
      alreadyCreated: json['alreadyCreated'] == true,
    );
  }
}
