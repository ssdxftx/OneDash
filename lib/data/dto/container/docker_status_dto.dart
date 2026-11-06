class DockerStatusDto {
  const DockerStatusDto({
    required this.isActive,
    required this.isExist,
    this.version = '',
  });

  final bool isActive;
  final bool isExist;
  final String version;

  bool get isAvailable => isActive && isExist;

  factory DockerStatusDto.fromJson(Map<String, dynamic> json) {
    final version =
        (json['version'] ??
                json['dockerVersion'] ??
                json['serverVersion'] ??
                '')
            .toString();
    return DockerStatusDto(
      isActive: json['isActive'] as bool? ?? false,
      isExist: json['isExist'] as bool? ?? false,
      version: version,
    );
  }
}
