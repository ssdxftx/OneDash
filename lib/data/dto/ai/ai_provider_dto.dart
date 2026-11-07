class AiProviderModelDto {
  const AiProviderModelDto({required this.id, required this.name});

  final String id;
  final String name;

  factory AiProviderModelDto.fromJson(Map<String, dynamic> json) {
    return AiProviderModelDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class AiProviderApiDto {
  const AiProviderApiDto({
    required this.apiType,
    required this.baseUrl,
    required this.defaultAuthMode,
    required this.authModes,
    required this.models,
  });

  final String apiType;
  final String baseUrl;
  final String defaultAuthMode;
  final List<String> authModes;
  final List<AiProviderModelDto> models;

  factory AiProviderApiDto.fromJson(Map<String, dynamic> json) {
    return AiProviderApiDto(
      apiType: json['apiType'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? '',
      defaultAuthMode: json['defaultAuthMode'] as String? ?? '',
      authModes:
          (json['authModes'] as List?)
              ?.map((item) => '$item')
              .toList(growable: false) ??
          const [],
      models:
          (json['models'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(AiProviderModelDto.fromJson)
              .toList(growable: false) ??
          const [],
    );
  }
}

class AiProviderDto {
  const AiProviderDto({
    required this.provider,
    required this.displayName,
    required this.baseUrl,
    required this.defaultApiType,
    required this.apiTypes,
    required this.models,
  });

  final String provider;
  final String displayName;
  final String baseUrl;
  final String defaultApiType;
  final List<AiProviderApiDto> apiTypes;
  final List<AiProviderModelDto> models;

  factory AiProviderDto.fromJson(Map<String, dynamic> json) {
    return AiProviderDto(
      provider: json['provider'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? '',
      defaultApiType: json['defaultApiType'] as String? ?? '',
      apiTypes:
          (json['apiTypes'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(AiProviderApiDto.fromJson)
              .toList(growable: false) ??
          const [],
      models:
          (json['models'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(AiProviderModelDto.fromJson)
              .toList(growable: false) ??
          const [],
    );
  }
}
