/// 慢日志文件读取结果（来自 POST /api/v2/files/read，type=mysql-slow-logs）。
class SlowLogFileDto {
  const SlowLogFileDto({
    required this.end,
    required this.path,
    required this.total,
    required this.lines,
    required this.totalLines,
  });

  /// 是否已到文件末尾。
  final bool end;

  /// 文件路径。
  final String path;

  /// 总条目数。
  final int total;

  /// 日志行内容。
  final List<String> lines;

  /// 总行数。
  final int totalLines;

  factory SlowLogFileDto.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List?;
    return SlowLogFileDto(
      end: json['end'] as bool? ?? true,
      path: json['path'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      lines:
          rawLines?.map((line) => line.toString()).toList(growable: false) ??
          const [],
      totalLines: json['totalLines'] as int? ?? 0,
    );
  }
}
