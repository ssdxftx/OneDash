class AppUpdateVersionDto {
  const AppUpdateVersionDto({
    required this.version,
    required this.detailId,
    required this.dockerCompose,
  });

  final String version;
  final int detailId;
  final String dockerCompose;

  factory AppUpdateVersionDto.fromJson(Map<String, dynamic> json) {
    return AppUpdateVersionDto(
      version: json['version'] as String? ?? '',
      detailId: json['detailId'] as int? ?? 0,
      dockerCompose: json['dockerCompose'] as String? ?? '',
    );
  }
}
