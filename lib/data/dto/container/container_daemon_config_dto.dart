class ContainerDaemonConfigDto {
  const ContainerDaemonConfigDto({
    required this.isSwarm,
    required this.version,
    required this.registryMirrors,
    required this.insecureRegistries,
    required this.liveRestore,
    required this.iptables,
    required this.cgroupDriver,
    required this.ipv6,
    required this.fixedCidrV6,
    required this.ip6Tables,
    required this.experimental,
    required this.logMaxSize,
    required this.logMaxFile,
  });

  final bool isSwarm;
  final String version;
  final List<String> registryMirrors;
  final List<String> insecureRegistries;
  final bool liveRestore;
  final bool iptables;
  final String cgroupDriver;
  final bool ipv6;
  final String fixedCidrV6;
  final bool ip6Tables;
  final bool experimental;
  final String logMaxSize;
  final String logMaxFile;

  factory ContainerDaemonConfigDto.fromJson(Map<String, dynamic> json) {
    return ContainerDaemonConfigDto(
      isSwarm: json['isSwarm'] as bool? ?? false,
      version: json['version'] as String? ?? '',
      registryMirrors: _stringList(json['registryMirrors']),
      insecureRegistries: _stringList(json['insecureRegistries']),
      liveRestore: json['liveRestore'] as bool? ?? false,
      iptables: json['iptables'] as bool? ?? false,
      cgroupDriver: json['cgroupDriver'] as String? ?? '',
      ipv6: json['ipv6'] as bool? ?? false,
      fixedCidrV6: json['fixedCidrV6'] as String? ?? '',
      ip6Tables: json['ip6Tables'] as bool? ?? false,
      experimental: json['experimental'] as bool? ?? false,
      logMaxSize: json['logMaxSize'] as String? ?? '',
      logMaxFile: json['logMaxFile'] as String? ?? '',
    );
  }

  static List<String> _stringList(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList(growable: false);
  }
}
