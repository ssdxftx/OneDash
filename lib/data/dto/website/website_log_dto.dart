enum WebsiteLogType {
  access('access.log', 'access'),
  error('error.log', 'error');

  const WebsiteLogType(this.fileName, this.exportName);

  final String fileName;
  final String exportName;
}

class WebsiteLogFileDto {
  const WebsiteLogFileDto({
    required this.end,
    required this.path,
    required this.total,
    required this.taskStatus,
    required this.lines,
    required this.scope,
    required this.totalLines,
  });

  final bool end;
  final String path;
  final int total;
  final String taskStatus;
  final List<String> lines;
  final String scope;
  final int totalLines;

  factory WebsiteLogFileDto.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List?;
    return WebsiteLogFileDto(
      end: json['end'] as bool? ?? true,
      path: json['path'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      taskStatus: json['taskStatus'] as String? ?? '',
      lines:
          rawLines?.map((line) => line.toString()).toList(growable: false) ??
          const [],
      scope: json['scope'] as String? ?? '',
      totalLines: json['totalLines'] as int? ?? 0,
    );
  }
}
