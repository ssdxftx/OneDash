/// 应用服务项（来自 GET /api/v2/apps/services/:key）。
class AppServiceDto {
  const AppServiceDto({
    required this.label,
    required this.value,
    this.from = '',
    this.status = '',
    this.config = const {},
    this.appInstallID = 0,
  });

  final String label;
  final String value;
  final String from;
  final String status;
  final Map<String, dynamic> config;
  final int appInstallID;

  factory AppServiceDto.fromJson(Map<String, dynamic> json) {
    return AppServiceDto(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      from: json['from'] as String? ?? '',
      status: json['status'] as String? ?? '',
      config: (json['config'] as Map<String, dynamic>?) ?? const {},
      appInstallID: json['appInstallID'] as int? ?? 0,
    );
  }
}
