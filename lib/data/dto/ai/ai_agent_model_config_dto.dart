class AiAgentModelConfigDto {
  const AiAgentModelConfigDto({
    required this.accountId,
    required this.model,
    required this.fallbacks,
  });

  final int accountId;
  final String model;
  final List<String> fallbacks;

  factory AiAgentModelConfigDto.fromJson(Map<String, dynamic> json) {
    return AiAgentModelConfigDto(
      accountId: (json['accountId'] as num?)?.toInt() ?? 0,
      model: json['model'] as String? ?? '',
      fallbacks:
          (json['fallbacks'] as List?)
              ?.map((item) => '$item')
              .toList(growable: false) ??
          const [],
    );
  }
}
