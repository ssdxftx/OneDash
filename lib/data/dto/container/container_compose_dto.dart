class ContainerComposeSearchDto {
  const ContainerComposeSearchDto({required this.total, required this.items});

  factory ContainerComposeSearchDto.fromJson(Map<String, dynamic> json) {
    return ContainerComposeSearchDto(
      total: _intValue(json['total']),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => ContainerComposeDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }

  final int total;
  final List<ContainerComposeDto> items;

  Map<String, dynamic> toJson() => {
    'total': total,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class ContainerComposeDto {
  const ContainerComposeDto({
    required this.name,
    required this.createdAt,
    required this.createdBy,
    required this.containerCount,
    required this.runningCount,
    required this.configFile,
    required this.workdir,
    this.composeFileExists,
    required this.path,
    this.containers,
    this.env,
  });

  factory ContainerComposeDto.fromJson(Map<String, dynamic> json) {
    final containers = (json['containers'] as List<dynamic>?)
        ?.map(
          (e) => ContainerComposeItemDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
    // Compatibility: 1Panel v2.0.0 returns `containerNumber` instead of
    // `containerCount`; newer versions may return `containerCount`.
    final containerCount = _intValue(
      json['containerCount'] ?? json['containerNumber'] ?? containers?.length,
    );
    final runningCount = _intValue(json['runningCount']);

    return ContainerComposeDto(
      name: _stringValue(json['name']),
      createdAt: _stringValue(json['createdAt']),
      createdBy: _stringValue(json['createdBy']),
      containerCount: containerCount,
      // Compatibility: 1Panel v2.0.0 does not return `runningCount`.
      // Derive it from the embedded container states when missing.
      runningCount: runningCount > 0
          ? runningCount
          : containers
                    ?.where((item) => item.state.toLowerCase() == 'running')
                    .length ??
                0,
      configFile: _stringValue(json['configFile']),
      workdir: _stringValue(json['workdir']),
      composeFileExists: json['composeFileExists'] as bool?,
      path: _stringValue(json['path']),
      containers: containers,
      env: _envValue(json['env']),
    );
  }

  final String name;
  final String createdAt;
  final String createdBy;
  final int containerCount;
  final int runningCount;
  final String configFile;
  final String workdir;
  final bool? composeFileExists;
  final String path;
  final List<ContainerComposeItemDto>? containers;
  final String? env;

  Map<String, dynamic> toJson() => {
    'name': name,
    'createdAt': createdAt,
    'createdBy': createdBy,
    'containerCount': containerCount,
    'runningCount': runningCount,
    'configFile': configFile,
    'workdir': workdir,
    'composeFileExists': composeFileExists,
    'path': path,
    'containers': containers?.map((e) => e.toJson()).toList(),
    'env': env,
  };
}

class ContainerComposeItemDto {
  const ContainerComposeItemDto({
    required this.containerID,
    required this.name,
    required this.createTime,
    required this.state,
    this.ports,
  });

  factory ContainerComposeItemDto.fromJson(Map<String, dynamic> json) {
    return ContainerComposeItemDto(
      containerID: _stringValue(json['containerID']),
      name: _stringValue(json['name']),
      createTime: _stringValue(json['createTime']),
      state: _stringValue(json['state']),
      ports: json['ports'],
    );
  }

  final String containerID;
  final String name;
  final String createTime;
  final String state;
  final dynamic ports;

  Map<String, dynamic> toJson() => {
    'containerID': containerID,
    'name': name,
    'createTime': createTime,
    'state': state,
    'ports': ports,
  };
}

int _intValue(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _stringValue(Object? value) => value?.toString() ?? '';

String? _envValue(Object? value) {
  // Compatibility: 1Panel v2.0.0 may return env as null for app-created
  // compose projects; keep null so the edit sheet can hide env editing.
  if (value == null) return null;
  if (value is String) return value;
  if (value is List) return value.map((e) => e.toString()).join('\n');
  if (value is Map) {
    return value.entries.map((e) => '${e.key}=${e.value}').join('\n');
  }
  return value.toString();
}
