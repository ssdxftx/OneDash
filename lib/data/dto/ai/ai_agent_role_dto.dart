class AiAgentRoleBindingDto {
  const AiAgentRoleBindingDto({required this.channel, required this.accountId});

  final String channel;
  final String accountId;

  factory AiAgentRoleBindingDto.fromJson(Map<String, dynamic> json) {
    return AiAgentRoleBindingDto(
      channel: json['channel'] as String? ?? '',
      accountId: '${json['accountId'] ?? ''}',
    );
  }
}

class AiAgentRoleDto {
  const AiAgentRoleDto({
    required this.id,
    required this.name,
    required this.workspace,
    required this.model,
    required this.agentDir,
    required this.bindings,
  });

  final String id;
  final String name;
  final String workspace;
  final String model;
  final String agentDir;
  final List<AiAgentRoleBindingDto> bindings;

  factory AiAgentRoleDto.fromJson(Map<String, dynamic> json) {
    return AiAgentRoleDto(
      id: '${json['id'] ?? ''}',
      name: json['name'] as String? ?? '',
      workspace: json['workspace'] as String? ?? '',
      model: json['model'] as String? ?? '',
      agentDir: json['agentDir'] as String? ?? '',
      bindings:
          (json['bindings'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(AiAgentRoleBindingDto.fromJson)
              .toList(growable: false) ??
          const [],
    );
  }
}

class AiAgentChannelDto {
  const AiAgentChannelDto({
    required this.name,
    required this.bound,
    required this.accountIds,
  });

  final String name;
  final bool bound;
  final List<String> accountIds;

  factory AiAgentChannelDto.fromJson(Map<String, dynamic> json) {
    return AiAgentChannelDto(
      name: json['name'] as String? ?? '',
      bound: json['bound'] == true,
      accountIds:
          (json['accountIds'] as List?)
              ?.map((item) => '$item')
              .toList(growable: false) ??
          const [],
    );
  }
}
