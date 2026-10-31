class DockerStatusDto {
  const DockerStatusDto({required this.isActive, required this.isExist});

  final bool isActive;
  final bool isExist;

  bool get isAvailable => isActive && isExist;

  factory DockerStatusDto.fromJson(Map<String, dynamic> json) {
    return DockerStatusDto(
      isActive: json['isActive'] as bool? ?? false,
      isExist: json['isExist'] as bool? ?? false,
    );
  }
}
