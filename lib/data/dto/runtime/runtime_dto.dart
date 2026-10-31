class RuntimeDto {
  const RuntimeDto({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.image,
    required this.version,
    required this.codeDir,
    required this.path,
    required this.port,
    required this.resource,
    required this.remark,
    required this.containerName,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.exposedPorts,
    required this.appID,
    required this.appDetailID,
    this.params,
  });

  final int id;
  final String name;
  final String type;
  final String status;
  final String image;
  final String version;
  final String codeDir;
  final String path;
  final String port;
  final String resource;
  final String remark;
  final String containerName;
  final String message;
  final String createdAt;
  final String updatedAt;
  final List<ExposedPort> exposedPorts;
  final int appID;
  final int appDetailID;
  final Map<String, dynamic>? params;

  factory RuntimeDto.fromJson(Map<String, dynamic> json) {
    return RuntimeDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      image: json['image'] as String? ?? '',
      version: json['version'] as String? ?? '',
      codeDir: json['codeDir'] as String? ?? '',
      path: json['path'] as String? ?? '',
      port: json['port'] as String? ?? '',
      resource: json['resource'] as String? ?? '',
      remark: json['remark'] as String? ?? '',
      containerName:
          (json['container'] ?? json['containerName']) as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      exposedPorts:
          (json['exposedPorts'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ExposedPort.fromJson)
              .toList() ??
          const [],
      appID: json['appID'] as int? ?? 0,
      appDetailID: json['appDetailID'] as int? ?? 0,
      params: json['params'] as Map<String, dynamic>?,
    );
  }
}

class RuntimeDetailDto extends RuntimeDto {
  const RuntimeDetailDto({
    required super.id,
    required super.name,
    required super.type,
    required super.status,
    required super.image,
    required super.version,
    required super.codeDir,
    required super.path,
    required super.port,
    required super.resource,
    required super.remark,
    required super.containerName,
    required super.message,
    required super.createdAt,
    required super.updatedAt,
    required super.exposedPorts,
    required super.appID,
    required super.appDetailID,
    super.params,
    required this.appParams,
    required this.source,
    required this.environments,
    required this.volumes,
    required this.extraHosts,
  });

  final List<Map<String, dynamic>> appParams;
  final String source;
  final List<EnvironmentVar> environments;
  final List<VolumeMount> volumes;
  final List<ExtraHost> extraHosts;

  factory RuntimeDetailDto.fromJson(Map<String, dynamic> json) {
    final base = RuntimeDto.fromJson(json);
    return RuntimeDetailDto(
      id: base.id,
      name: base.name,
      type: base.type,
      status: base.status,
      image: base.image,
      version: base.version,
      codeDir: base.codeDir,
      path: base.path,
      port: base.port,
      resource: base.resource,
      remark: base.remark,
      containerName: base.containerName,
      message: base.message,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      exposedPorts: base.exposedPorts,
      appID: base.appID,
      appDetailID: base.appDetailID,
      params: base.params,
      appParams:
          (json['appParams'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          const [],
      source: json['source'] as String? ?? '',
      environments:
          (json['environments'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(EnvironmentVar.fromJson)
              .toList() ??
          const [],
      volumes:
          (json['volumes'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(VolumeMount.fromJson)
              .toList() ??
          const [],
      extraHosts:
          (json['extraHosts'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ExtraHost.fromJson)
              .toList() ??
          const [],
    );
  }
}

class ExposedPort {
  const ExposedPort({
    required this.hostPort,
    required this.containerPort,
    required this.hostIP,
  });

  final int hostPort;
  final int containerPort;
  final String hostIP;

  factory ExposedPort.fromJson(Map<String, dynamic> json) {
    return ExposedPort(
      hostPort: json['hostPort'] as int? ?? 0,
      containerPort: json['containerPort'] as int? ?? 0,
      hostIP: json['hostIP'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'hostPort': hostPort,
    'containerPort': containerPort,
    'hostIP': hostIP,
  };
}

class EnvironmentVar {
  const EnvironmentVar({required this.key, required this.value});

  final String key;
  final String value;

  factory EnvironmentVar.fromJson(Map<String, dynamic> json) {
    return EnvironmentVar(
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}

class VolumeMount {
  const VolumeMount({required this.source, required this.target});

  final String source;
  final String target;

  factory VolumeMount.fromJson(Map<String, dynamic> json) {
    return VolumeMount(
      source: json['source'] as String? ?? '',
      target: json['target'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'source': source, 'target': target};
}

class ExtraHost {
  const ExtraHost({required this.hostname, required this.ip});

  final String hostname;
  final String ip;

  factory ExtraHost.fromJson(Map<String, dynamic> json) {
    return ExtraHost(
      hostname: json['hostname'] as String? ?? '',
      ip: json['ip'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'hostname': hostname, 'ip': ip};
}

class RuntimeCreateReq {
  const RuntimeCreateReq({
    required this.name,
    required this.appDetailID,
    required this.image,
    required this.params,
    required this.type,
    required this.resource,
    this.id,
    this.appID,
    this.version,
    this.rebuild,
    this.source,
    this.codeDir,
    this.port,
    this.install,
    this.clean,
    this.exposedPorts,
    this.environments,
    this.volumes,
    this.extraHosts,
    this.remark,
  });

  final int? id;
  final String name;
  final int appDetailID;
  final String image;
  final Map<String, dynamic> params;
  final String type;
  final String resource;
  final int? appID;
  final String? version;
  final bool? rebuild;
  final String? source;
  final String? codeDir;
  final int? port;
  final bool? install;
  final bool? clean;
  final List<ExposedPort>? exposedPorts;
  final List<EnvironmentVar>? environments;
  final List<VolumeMount>? volumes;
  final List<ExtraHost>? extraHosts;
  final String? remark;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'appDetailId': appDetailID,
    'image': image,
    'params': params,
    'type': type,
    'resource': resource,
    if (appID != null) 'appID': appID,
    if (version != null) 'version': version,
    if (rebuild != null) 'rebuild': rebuild,
    if (source != null) 'source': source,
    if (codeDir != null) 'codeDir': codeDir,
    if (port != null) 'port': port,
    if (install != null) 'install': install,
    if (clean != null) 'clean': clean,
    if (exposedPorts != null)
      'exposedPorts': exposedPorts!.map((e) => e.toJson()).toList(),
    if (environments != null)
      'environments': environments!.map((e) => e.toJson()).toList(),
    if (volumes != null) 'volumes': volumes!.map((e) => e.toJson()).toList(),
    if (extraHosts != null)
      'extraHosts': extraHosts!.map((e) => e.toJson()).toList(),
    if (remark != null) 'remark': remark,
  };
}
