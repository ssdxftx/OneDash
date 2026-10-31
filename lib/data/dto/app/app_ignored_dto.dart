class AppIgnoredDto {
  const AppIgnoredDto({
    required this.id,
    required this.appId,
    required this.appDetailId,
    required this.scope,
    required this.version,
    required this.name,
  });

  final int id;
  final int appId;
  final int appDetailId;
  final String scope;
  final String version;
  final String name;

  AppIgnoredDto copyWith({String? name}) {
    return AppIgnoredDto(
      id: id,
      appId: appId,
      appDetailId: appDetailId,
      scope: scope,
      version: version,
      name: name ?? this.name,
    );
  }

  factory AppIgnoredDto.fromJson(Map<String, dynamic> json) {
    return AppIgnoredDto(
      id: json['ID'] as int? ?? 0,
      appId: json['appID'] as int? ?? 0,
      appDetailId: json['appDetailID'] as int? ?? 0,
      scope: json['scope'] as String? ?? '',
      version: json['version'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
