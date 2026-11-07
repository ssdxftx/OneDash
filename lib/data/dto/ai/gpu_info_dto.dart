class GpuInfoDto {
  const GpuInfoDto({
    required this.type,
    required this.cudaVersion,
    required this.driverVersion,
    required this.devices,
  });

  final String type;
  final String cudaVersion;
  final String driverVersion;
  final List<Map<String, dynamic>> devices;

  factory GpuInfoDto.fromJson(Map<String, dynamic> json) {
    final raw = json['gpu'] ?? json['xpu'];
    return GpuInfoDto(
      type: json['type'] as String? ?? '',
      cudaVersion: json['cudaVersion'] as String? ?? '',
      driverVersion: json['driverVersion'] as String? ?? '',
      devices: raw is List
          ? raw.whereType<Map<String, dynamic>>().toList(growable: false)
          : const [],
    );
  }
}
