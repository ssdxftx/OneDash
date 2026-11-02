class FileLogDto {
  const FileLogDto({
    required this.path,
    required this.lines,
    required this.total,
    required this.end,
  });

  final String path;
  final List<String> lines;
  final int total;
  final bool end;

  factory FileLogDto.fromJson(Map<String, dynamic> json) {
    return FileLogDto(
      path: json['path'] as String? ?? '',
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      end: json['end'] == true,
    );
  }
}
