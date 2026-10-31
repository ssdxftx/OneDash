class ContainerResourceStatsDto {
  const ContainerResourceStatsDto({
    required this.containerID,
    required this.cpuTotalUsage,
    required this.systemUsage,
    required this.cpuPercent,
    required this.percpuUsage,
    required this.memoryCache,
    required this.memoryUsage,
    required this.memoryLimit,
    required this.memoryPercent,
  });

  final String containerID;
  final int cpuTotalUsage;
  final int systemUsage;
  final double cpuPercent;
  final int percpuUsage;
  final int memoryCache;
  final int memoryUsage;
  final int memoryLimit;
  final double memoryPercent;

  factory ContainerResourceStatsDto.fromJson(Map<String, dynamic> json) {
    return ContainerResourceStatsDto(
      containerID: json['containerID'] as String? ?? '',
      cpuTotalUsage: json['cpuTotalUsage'] as int? ?? 0,
      systemUsage: json['systemUsage'] as int? ?? 0,
      cpuPercent: (json['cpuPercent'] as num?)?.toDouble() ?? 0.0,
      percpuUsage: json['percpuUsage'] as int? ?? 0,
      memoryCache: json['memoryCache'] as int? ?? 0,
      memoryUsage: json['memoryUsage'] as int? ?? 0,
      memoryLimit: json['memoryLimit'] as int? ?? 0,
      memoryPercent: (json['memoryPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
