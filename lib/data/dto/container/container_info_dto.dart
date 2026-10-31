class ContainerInfoDto {
  const ContainerInfoDto({
    required this.taskID,
    required this.forcePull,
    required this.name,
    required this.image,
    required this.hostname,
    required this.domainName,
    this.dns,
    required this.networks,
    required this.publishAllPorts,
    required this.exposedPorts,
    required this.tty,
    required this.openStdin,
    required this.workingDir,
    required this.user,
    this.cmd,
    this.entrypoint,
    required this.cpuShares,
    required this.nanoCPUs,
    required this.memory,
    required this.privileged,
    required this.autoRemove,
    required this.volumes,
    this.extraHosts,
    required this.labels,
    required this.env,
    required this.restartPolicy,
  });

  final String taskID;
  final bool forcePull;
  final String name;
  final String image;
  final String hostname;
  final String domainName;
  final List<String>? dns;
  final List<ContainerNetworkDto> networks;
  final bool publishAllPorts;
  final List<ContainerPortDto> exposedPorts;
  final bool tty;
  final bool openStdin;
  final String workingDir;
  final String user;
  final List<String>? cmd;
  final List<String>? entrypoint;
  final int cpuShares;
  final int nanoCPUs;
  final int memory;
  final bool privileged;
  final bool autoRemove;
  final List<ContainerVolumeDto> volumes;
  final List<String>? extraHosts;
  final List<String> labels;
  final List<String> env;
  final String restartPolicy;

  factory ContainerInfoDto.fromJson(Map<String, dynamic> json) {
    return ContainerInfoDto(
      taskID: json['taskID'] as String? ?? '',
      forcePull: json['forcePull'] as bool? ?? false,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      hostname: json['hostname'] as String? ?? '',
      domainName: json['domainName'] as String? ?? '',
      dns: (json['dns'] as List<dynamic>?)?.map((e) => e as String).toList(),
      networks:
          (json['networks'] as List<dynamic>?)
              ?.map(
                (e) => ContainerNetworkDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      publishAllPorts: json['publishAllPorts'] as bool? ?? false,
      exposedPorts:
          (json['exposedPorts'] as List<dynamic>?)
              ?.map((e) => ContainerPortDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tty: json['tty'] as bool? ?? false,
      openStdin: json['openStdin'] as bool? ?? false,
      workingDir: json['workingDir'] as String? ?? '',
      user: json['user'] as String? ?? '',
      cmd: (json['cmd'] as List<dynamic>?)?.map((e) => e as String).toList(),
      entrypoint: (json['entrypoint'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      cpuShares: json['cpuShares'] as int? ?? 0,
      nanoCPUs: json['nanoCPUs'] as int? ?? 0,
      memory: json['memory'] as int? ?? 0,
      privileged: json['privileged'] as bool? ?? false,
      autoRemove: json['autoRemove'] as bool? ?? false,
      volumes:
          (json['volumes'] as List<dynamic>?)
              ?.map(
                (e) => ContainerVolumeDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      extraHosts: (json['extraHosts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      labels:
          (json['labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      env:
          (json['env'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      restartPolicy: json['restartPolicy'] as String? ?? 'always',
    );
  }
}

class ContainerNetworkDto {
  const ContainerNetworkDto({
    required this.network,
    required this.ipv4,
    required this.ipv6,
    required this.macAddr,
  });

  final String network;
  final String ipv4;
  final String ipv6;
  final String macAddr;

  factory ContainerNetworkDto.fromJson(Map<String, dynamic> json) {
    return ContainerNetworkDto(
      network: json['network'] as String? ?? '',
      ipv4: json['ipv4'] as String? ?? '',
      ipv6: json['ipv6'] as String? ?? '',
      macAddr: json['macAddr'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'network': network,
    'ipv4': ipv4,
    'ipv6': ipv6,
    'macAddr': macAddr,
  };
}

class ContainerPortDto {
  const ContainerPortDto({
    required this.hostIP,
    required this.hostPort,
    required this.containerPort,
    required this.protocol,
  });

  final String hostIP;
  final String hostPort;
  final String containerPort;
  final String protocol;

  factory ContainerPortDto.fromJson(Map<String, dynamic> json) {
    return ContainerPortDto(
      hostIP: json['hostIP'] as String? ?? '',
      hostPort: json['hostPort'] as String? ?? '',
      containerPort: json['containerPort'] as String? ?? '',
      protocol: json['protocol'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'hostIP': hostIP,
    'hostPort': hostPort,
    'containerPort': containerPort,
    'protocol': protocol,
  };
}

class ContainerVolumeDto {
  const ContainerVolumeDto({
    required this.type,
    required this.sourceDir,
    required this.containerDir,
    required this.mode,
    required this.shared,
  });

  final String type;
  final String sourceDir;
  final String containerDir;
  final String mode;
  final String shared;

  factory ContainerVolumeDto.fromJson(Map<String, dynamic> json) {
    return ContainerVolumeDto(
      type: json['type'] as String? ?? '',
      sourceDir: json['sourceDir'] as String? ?? '',
      containerDir: json['containerDir'] as String? ?? '',
      mode: json['mode'] as String? ?? '',
      shared: json['shared'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'sourceDir': sourceDir,
    'containerDir': containerDir,
    'mode': mode,
    'shared': shared,
  };
}
