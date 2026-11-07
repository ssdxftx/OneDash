class AiAccountModelDto {
  const AiAccountModelDto({
    required this.id,
    required this.name,
    required this.isVerifyModel,
  });

  final String id;
  final String name;
  final bool isVerifyModel;

  factory AiAccountModelDto.fromJson(Map<String, dynamic> json) {
    return AiAccountModelDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isVerifyModel: json['isVerifyModel'] == true,
    );
  }
}

class AiAccountDto {
  const AiAccountDto({
    required this.id,
    required this.provider,
    required this.providerName,
    required this.name,
    required this.apiKey,
    required this.rememberApiKey,
    required this.baseUrl,
    required this.apiType,
    required this.authMode,
    required this.verified,
    required this.verifyModel,
    required this.validateAvailability,
    required this.remark,
    required this.models,
  });

  final int id;
  final String provider;
  final String providerName;
  final String name;
  final String apiKey;
  final bool rememberApiKey;
  final String baseUrl;
  final String apiType;
  final String authMode;
  final bool verified;
  final String verifyModel;
  final bool validateAvailability;
  final String remark;
  final List<AiAccountModelDto> models;

  factory AiAccountDto.fromJson(Map<String, dynamic> json) {
    return AiAccountDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      provider: json['provider'] as String? ?? '',
      providerName: json['providerName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      rememberApiKey: json['rememberApiKey'] == true,
      baseUrl: json['baseUrl'] as String? ?? '',
      apiType: json['apiType'] as String? ?? '',
      authMode: json['authMode'] as String? ?? '',
      verified: json['verified'] == true,
      verifyModel: json['verifyModel'] as String? ?? '',
      validateAvailability: json['validateAvailability'] == true,
      remark: json['remark'] as String? ?? '',
      models:
          (json['models'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(AiAccountModelDto.fromJson)
              .toList(growable: false) ??
          const [],
    );
  }
}
