class AiFeishuBotDto {
  const AiFeishuBotDto({
    required this.accountId,
    required this.name,
    required this.enabled,
    required this.isDefault,
    required this.appId,
    this.appSecret = '',
    this.dmPolicy = 'pairing',
    this.allowFrom = const [],
  });

  final String accountId;
  final String name;
  final bool enabled;
  final bool isDefault;
  final String appId;
  final String appSecret;
  final String dmPolicy;
  final List<String> allowFrom;

  factory AiFeishuBotDto.fromJson(Map<String, dynamic> json) {
    return AiFeishuBotDto(
      accountId: '${json['accountId'] ?? ''}',
      name: json['name'] as String? ?? '',
      enabled: json['enabled'] == true,
      isDefault: json['isDefault'] == true,
      appId: json['appId'] as String? ?? '',
      appSecret: json['appSecret'] as String? ?? '',
      dmPolicy: json['dmPolicy'] as String? ?? 'pairing',
      allowFrom:
          (json['allowFrom'] as List?)
              ?.map((item) => '$item')
              .toList(growable: false) ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'name': name,
    'enabled': enabled,
    'isDefault': isDefault,
    'appId': appId,
    'appSecret': appSecret,
    'dmPolicy': dmPolicy,
    'allowFrom': allowFrom,
  };
}

class AiFeishuConfigDto {
  const AiFeishuConfigDto({
    required this.enabled,
    required this.threadSession,
    required this.replyMode,
    required this.streaming,
    required this.requireMention,
    required this.groupPolicy,
    required this.groupAllowFrom,
    required this.domain,
    required this.connectionMode,
    required this.bots,
    required this.installed,
    this.groupSessionScope = 'group',
  });

  final bool enabled;
  final bool threadSession;
  final String replyMode;
  final bool streaming;
  final String requireMention;
  final String groupPolicy;
  final List<String> groupAllowFrom;
  final String domain;
  final String connectionMode;
  final List<AiFeishuBotDto> bots;
  final bool installed;
  final String groupSessionScope;

  factory AiFeishuConfigDto.fromJson(Map<String, dynamic> json) {
    return AiFeishuConfigDto(
      enabled: json['enabled'] == true,
      threadSession: json['threadSession'] == true,
      replyMode: json['replyMode'] as String? ?? '',
      streaming: json['streaming'] == true,
      requireMention: json['requireMention'] as String? ?? 'true',
      groupPolicy: json['groupPolicy'] as String? ?? 'disabled',
      groupAllowFrom:
          (json['groupAllowFrom'] as List?)
              ?.map((item) => '$item')
              .toList(growable: false) ??
          const [],
      domain: json['domain'] as String? ?? '',
      connectionMode: json['connectionMode'] as String? ?? 'websocket',
      bots:
          (json['bots'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(AiFeishuBotDto.fromJson)
              .toList(growable: false) ??
          const [],
      installed: json['installed'] == true,
      groupSessionScope: json['groupSessionScope'] as String? ?? 'group',
    );
  }
}
