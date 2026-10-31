class AppInstalledCheckRes {
  const AppInstalledCheckRes({
    required this.isExist,
    required this.name,
    required this.app,
    required this.version,
    required this.status,
    required this.appInstallId,
    required this.containerName,
  });

  final bool isExist;
  final String name;
  final String app;
  final String version;
  final String status;
  final int appInstallId;
  final String containerName;

  factory AppInstalledCheckRes.fromJson(Map<String, dynamic> json) {
    return AppInstalledCheckRes(
      isExist: json['isExist'] as bool? ?? false,
      name: json['name'] as String? ?? '',
      app: json['app'] as String? ?? '',
      version: json['version'] as String? ?? '',
      status: json['status'] as String? ?? '',
      appInstallId: json['appInstallId'] as int? ?? 0,
      containerName: json['containerName'] as String? ?? '',
    );
  }
}
