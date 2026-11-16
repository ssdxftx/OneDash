class FileTreeNodeDto {
  const FileTreeNodeDto({
    required this.id,
    required this.name,
    required this.path,
    required this.isDir,
    required this.extension,
    required this.children,
  });

  final String id;
  final String name;
  final String path;
  final bool isDir;
  final String extension;
  final List<FileTreeNodeDto> children;

  factory FileTreeNodeDto.fromJson(Map<String, dynamic> json) {
    return FileTreeNodeDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      isDir: json['isDir'] as bool? ?? false,
      extension: json['extension'] as String? ?? '',
      children: (json['children'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(FileTreeNodeDto.fromJson)
          .toList(growable: false),
    );
  }
}
