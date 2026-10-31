class AppInstalledDto {
  const AppInstalledDto({
    required this.id,
    required this.name,
    required this.appId,
    required this.appDetailId,
    required this.version,
    required this.status,
    required this.message,
    required this.httpPort,
    required this.httpsPort,
    required this.path,
    required this.canUpdate,
    required this.icon,
    required this.appName,
    required this.appKey,
    required this.appType,
    required this.createdAt,
    required this.favorite,
    required this.container,
    required this.serviceName,
  });

  final int id;
  final String name;
  final int appId;
  final int appDetailId;
  final String version;
  final String status;
  final String message;
  final int httpPort;
  final int httpsPort;
  final String path;
  final bool canUpdate;
  final String icon;
  final String appName;
  final String appKey;
  final String appType;
  final DateTime? createdAt;
  final bool favorite;
  final String container;
  final String serviceName;

  String get displayName => appName.isNotEmpty ? appName : name;

  AppInstalledDto copyWith({bool? favorite}) {
    return AppInstalledDto(
      id: id,
      name: name,
      appId: appId,
      appDetailId: appDetailId,
      version: version,
      status: status,
      message: message,
      httpPort: httpPort,
      httpsPort: httpsPort,
      path: path,
      canUpdate: canUpdate,
      icon: icon,
      appName: appName,
      appKey: appKey,
      appType: appType,
      createdAt: createdAt,
      favorite: favorite ?? this.favorite,
      container: container,
      serviceName: serviceName,
    );
  }

  factory AppInstalledDto.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    // Compatibility: 1Panel v2.0.0 may omit serviceName but still returns
    // container/name. Keep serviceName usable for terminal and logs.
    final serviceName =
        json['serviceName'] as String? ?? json['container'] as String? ?? name;

    return AppInstalledDto(
      id: json['id'] as int? ?? 0,
      name: name,
      appId: json['appID'] as int? ?? 0,
      appDetailId: json['appDetailID'] as int? ?? 0,
      version: json['version'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      httpPort: json['httpPort'] as int? ?? 0,
      httpsPort: json['httpsPort'] as int? ?? 0,
      path: json['path'] as String? ?? '',
      canUpdate: json['canUpdate'] as bool? ?? false,
      // Compatibility: 1Panel v2.0.0 returns a base64 icon directly in this
      // field. Newer versions may return empty and require /apps/icon/{name}.
      icon: json['icon'] as String? ?? '',
      appName: json['appName'] as String? ?? '',
      appKey: json['appKey'] as String? ?? name,
      appType: json['appType'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      favorite: json['favorite'] as bool? ?? false,
      container: json['container'] as String? ?? '',
      serviceName: serviceName,
    );
  }
}
