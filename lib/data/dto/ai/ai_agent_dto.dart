class AiAgentDto {
  const AiAgentDto({
    required this.id,
    required this.name,
    required this.remark,
    required this.status,
    required this.message,
    required this.providerName,
    required this.model,
    required this.websiteId,
    required this.websitePrimaryDomain,
    required this.containerName,
    required this.webUIPort,
    required this.appVersion,
    required this.upgradable,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String remark;
  final String status;
  final String message;
  final String providerName;
  final String model;
  final int websiteId;
  final String websitePrimaryDomain;
  final String containerName;
  final int webUIPort;
  final String appVersion;
  final bool upgradable;
  final String createdAt;

  factory AiAgentDto.fromJson(Map<String, dynamic> json) {
    return AiAgentDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      remark: json['remark'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      providerName: json['providerName'] as String? ?? '',
      model: json['model'] as String? ?? '',
      websiteId: (json['websiteId'] as num?)?.toInt() ?? 0,
      websitePrimaryDomain: json['websitePrimaryDomain'] as String? ?? '',
      containerName: json['containerName'] as String? ?? '',
      webUIPort: (json['webUIPort'] as num?)?.toInt() ?? 0,
      appVersion: json['appVersion'] as String? ?? '',
      upgradable: json['upgradable'] == true,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
