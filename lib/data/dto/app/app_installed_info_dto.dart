class AppInstalledInfoDto {
  const AppInstalledInfoDto({
    required this.id,
    required this.name,
    required this.version,
    required this.status,
    required this.message,
    required this.httpPort,
    required this.container,
    required this.composePath,
    required this.appKey,
  });

  final int id;
  final String name;
  final String version;
  final String status;
  final String message;
  final int httpPort;
  final String container;
  final String composePath;
  final String appKey;

  factory AppInstalledInfoDto.fromJson(Map<String, dynamic> json) {
    return AppInstalledInfoDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      version: json['version'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      httpPort: json['HttpPort'] as int? ?? json['httpPort'] as int? ?? 0,
      container: json['container'] as String? ?? '',
      composePath: json['composePath'] as String? ?? '',
      appKey: json['appKey'] as String? ?? '',
    );
  }
}
