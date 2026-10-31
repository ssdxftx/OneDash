class AppInstalledParamsDto {
  const AppInstalledParamsDto({
    required this.params,
    required this.dockerCompose,
    required this.containerName,
    required this.allowPort,
    required this.restartPolicy,
    required this.cpuQuota,
    required this.memoryLimit,
    required this.memoryUnit,
    required this.editCompose,
    this.specifyIP,
  });

  final List<AppInstalledFieldDto> params;
  final String dockerCompose;
  final String containerName;
  final bool allowPort;
  final String restartPolicy;
  final double cpuQuota;
  final double memoryLimit;
  final String memoryUnit;
  final bool editCompose;
  final String? specifyIP;

  factory AppInstalledParamsDto.fromJson(Map<String, dynamic> json) {
    final rawParams = json['params'] as List?;
    return AppInstalledParamsDto(
      params:
          rawParams
              ?.map(
                (e) => AppInstalledFieldDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      dockerCompose: json['dockerCompose'] as String? ?? '',
      containerName: json['containerName'] as String? ?? '',
      allowPort: json['allowPort'] as bool? ?? false,
      restartPolicy: json['restartPolicy'] as String? ?? 'always',
      cpuQuota: (json['cpuQuota'] as num? ?? 0).toDouble(),
      memoryLimit: (json['memoryLimit'] as num? ?? 0).toDouble(),
      memoryUnit: json['memoryUnit'] as String? ?? 'MB',
      editCompose: json['editCompose'] as bool? ?? false,
      specifyIP: json['specifyIP'] as String?,
    );
  }
}

class AppInstalledFieldDto {
  const AppInstalledFieldDto({
    required this.key,
    required this.value,
    required this.labelZh,
    required this.labelEn,
    required this.type,
    required this.required,
    required this.edit,
    this.rule,
  });

  final String key;
  final dynamic value;
  final String labelZh;
  final String labelEn;
  final String type;
  final bool required;
  final bool edit;
  final String? rule;

  factory AppInstalledFieldDto.fromJson(Map<String, dynamic> json) {
    return AppInstalledFieldDto(
      key: json['key'] as String? ?? '',
      value: json['value'],
      labelZh: json['labelZh'] as String? ?? '',
      labelEn: json['labelEn'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      required: json['required'] as bool? ?? false,
      edit: json['edit'] as bool? ?? true,
      rule: json['rule'] as String?,
    );
  }
}

class AppInstalledParamsUpdateReq {
  const AppInstalledParamsUpdateReq({
    required this.installId,
    required this.params,
    required this.advanced,
    required this.containerName,
    required this.allowPort,
    required this.restartPolicy,
    required this.cpuQuota,
    required this.memoryLimit,
    required this.memoryUnit,
    required this.editCompose,
    required this.dockerCompose,
    this.webUI = '',
    this.specifyIP,
  });

  final int installId;
  final Map<String, dynamic> params;
  final bool advanced;
  final String containerName;
  final bool allowPort;
  final String restartPolicy;
  final double cpuQuota;
  final double memoryLimit;
  final String memoryUnit;
  final bool editCompose;
  final String dockerCompose;
  final String webUI;
  final String? specifyIP;

  Map<String, dynamic> toJson() {
    return {
      'installId': installId,
      'params': params,
      'advanced': advanced,
      'containerName': containerName,
      'allowPort': allowPort,
      'restartPolicy': restartPolicy,
      'cpuQuota': cpuQuota,
      'memoryLimit': memoryLimit,
      'memoryUnit': memoryUnit,
      'editCompose': editCompose,
      'dockerCompose': dockerCompose,
      'webUI': webUI,
      if (specifyIP != null) 'specifyIP': specifyIP,
    };
  }
}
