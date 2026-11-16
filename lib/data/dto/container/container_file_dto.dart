class ContainerFileDto {
  const ContainerFileDto({
    required this.name,
    required this.path,
    required this.isDir,
    required this.isLink,
    required this.linkTo,
    required this.size,
    required this.mode,
    required this.modTime,
  });

  final String name;
  final String path;
  final bool isDir;
  final bool isLink;
  final String linkTo;
  final int size;
  final String mode;
  final String modTime;

  factory ContainerFileDto.fromJson(Map<String, dynamic> json) {
    return ContainerFileDto(
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      isDir: json['isDir'] as bool? ?? false,
      isLink: json['isLink'] as bool? ?? false,
      linkTo: json['linkTo'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      mode: json['mode'] as String? ?? '',
      modTime: json['modTime'] as String? ?? '',
    );
  }
}

class ContainerFileContentDto {
  const ContainerFileContentDto({
    required this.content,
    required this.size,
    required this.truncated,
    required this.isBinary,
  });

  final String content;
  final int size;
  final bool truncated;
  final bool isBinary;

  factory ContainerFileContentDto.fromJson(Map<String, dynamic> json) {
    return ContainerFileContentDto(
      content: json['content'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      truncated: json['truncated'] as bool? ?? false,
      isBinary: json['isBinary'] as bool? ?? false,
    );
  }
}
