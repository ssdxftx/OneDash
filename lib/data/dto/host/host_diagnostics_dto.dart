/// `/hosts/diagnostics/summary` 响应 DTO。
class DiagnosticsSummaryDto {
  const DiagnosticsSummaryDto({
    this.rss = 0,
    this.heapAlloc = 0,
    this.heapObjects = 0,
    this.goroutines = 0,
  });

  final int rss;
  final int heapAlloc;
  final int heapObjects;
  final int goroutines;

  factory DiagnosticsSummaryDto.fromJson(Map<String, dynamic> json) {
    return DiagnosticsSummaryDto(
      rss: (json['rss'] as num?)?.toInt() ?? 0,
      heapAlloc: (json['heapAlloc'] as num?)?.toInt() ?? 0,
      heapObjects: (json['heapObjects'] as num?)?.toInt() ?? 0,
      goroutines: (json['goroutines'] as num?)?.toInt() ?? 0,
    );
  }
}

/// `/hosts/diagnostics/goroutines` 响应 DTO。
class GoroutineSnapshotDto {
  const GoroutineSnapshotDto({
    this.total = 0,
    this.groupCount = 0,
    this.truncated = false,
    this.capturedAt = '',
    this.groups = const [],
  });

  final int total;
  final int groupCount;
  final bool truncated;
  final String capturedAt;
  final List<GoroutineGroupDto> groups;

  factory GoroutineSnapshotDto.fromJson(Map<String, dynamic> json) {
    return GoroutineSnapshotDto(
      total: (json['total'] as num?)?.toInt() ?? 0,
      groupCount: (json['groupCount'] as num?)?.toInt() ?? 0,
      truncated: json['truncated'] as bool? ?? false,
      capturedAt: json['capturedAt'] as String? ?? '',
      groups: switch (json['goroutines']) {
        final List rows =>
          rows
              .whereType<Map>()
              .map(
                (row) =>
                    GoroutineGroupDto.fromJson(row.cast<String, dynamic>()),
              )
              .toList(growable: false),
        _ => const [],
      },
    );
  }
}

/// 按状态与调用栈分组的协程快照。
class GoroutineGroupDto {
  const GoroutineGroupDto({
    this.state = '',
    this.top = '',
    this.count = 0,
    this.stack = const [],
  });

  final String state;
  final String top;
  final int count;
  final List<String> stack;

  factory GoroutineGroupDto.fromJson(Map<String, dynamic> json) {
    return GoroutineGroupDto(
      state: json['state'] as String? ?? '',
      top: json['top'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      stack: switch (json['stack']) {
        final List rows => rows.map((row) => '$row').toList(growable: false),
        _ => const [],
      },
    );
  }
}

/// `/hosts/components/:name` 响应 DTO。
class ComponentInfoDto {
  const ComponentInfoDto({
    this.exists = false,
    this.version = '',
    this.path = '',
    this.error = '',
  });

  final bool exists;
  final String version;
  final String path;
  final String error;

  factory ComponentInfoDto.fromJson(Map<String, dynamic> json) {
    return ComponentInfoDto(
      exists: json['exists'] as bool? ?? false,
      version: json['version'] as String? ?? '',
      path: json['path'] as String? ?? '',
      error: json['error'] as String? ?? '',
    );
  }
}
