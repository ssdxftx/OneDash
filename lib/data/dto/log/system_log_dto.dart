/// `/logs/system/status` 返回项。
class SystemLogStatusDto {
  const SystemLogStatusDto({
    this.source = '',
    this.version = '',
    this.message = '',
    this.keywordFilterSupported = false,
  });

  final String source;
  final String version;
  final String message;
  final bool keywordFilterSupported;

  factory SystemLogStatusDto.fromJson(Map<String, dynamic> json) {
    return SystemLogStatusDto(
      source: json['source'] as String? ?? '',
      version: json['version'] as String? ?? '',
      message: json['message'] as String? ?? '',
      keywordFilterSupported: json['keywordFilterSupported'] as bool? ?? false,
    );
  }
}

/// `/logs/system/read` 单条日志。
class SystemLogItemDto {
  const SystemLogItemDto({
    this.time = '',
    this.service = '',
    this.priority = '',
    this.message = '',
    this.raw = '',
  });

  final String time;
  final String service;
  final String priority;
  final String message;
  final String raw;

  factory SystemLogItemDto.fromJson(Map<String, dynamic> json) {
    return SystemLogItemDto(
      time: json['time'] as String? ?? '',
      service: json['service'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      message: json['message'] as String? ?? '',
      raw: json['raw'] as String? ?? '',
    );
  }
}

/// `/logs/system/read` 返回项。
class SystemLogPageDto {
  const SystemLogPageDto({
    this.items = const [],
    this.hasMore = false,
    this.nextCursor = '',
    this.source = '',
  });

  final List<SystemLogItemDto> items;
  final bool hasMore;
  final String nextCursor;
  final String source;

  factory SystemLogPageDto.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    return SystemLogPageDto(
      items: raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (row) =>
                      SystemLogItemDto.fromJson(row.cast<String, dynamic>()),
                )
                .toList(growable: false)
          : const [],
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String? ?? '',
      source: json['source'] as String? ?? '',
    );
  }
}
