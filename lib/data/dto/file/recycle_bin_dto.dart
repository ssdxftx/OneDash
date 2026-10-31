class RecycleBinDto {
  final String name;
  final int size;
  final String type;
  final DateTime deleteTime;
  final String rName;
  final String sourcePath;
  final bool isDir;
  final String from;

  RecycleBinDto({
    required this.name,
    required this.size,
    required this.type,
    required this.deleteTime,
    required this.rName,
    required this.sourcePath,
    required this.isDir,
    required this.from,
  });

  factory RecycleBinDto.fromJson(Map<String, dynamic> json) {
    return RecycleBinDto(
      name: json['name'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      type: json['type'] as String? ?? 'file',
      deleteTime: DateTime.parse(
        json['deleteTime'] as String? ?? DateTime.now().toIso8601String(),
      ),
      rName: json['rName'] as String? ?? '',
      sourcePath: json['sourcePath'] as String? ?? '',
      isDir: json['isDir'] as bool? ?? false,
      from: json['from'] as String? ?? '',
    );
  }
}
