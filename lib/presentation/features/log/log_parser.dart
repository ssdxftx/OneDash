import 'dart:convert';

enum LogLevel { trace, debug, info, warn, error, fatal, plain }

enum LogFormat { json, nginxAccess, nginxError, generic, plain }

class ParsedLogLine {
  const ParsedLogLine({
    required this.level,
    required this.message,
    required this.format,
    this.time,
    this.status,
    this.method,
    this.path,
    this.ip,
    this.userAgent,
    this.referer,
    this.bytes,
    this.upstream,
    this.duration,
    this.xff,
  });

  final LogLevel level;
  final LogFormat format;
  final String message;
  final String? time;
  final int? status;
  final String? method;
  final String? path;
  final String? ip;
  final String? userAgent;
  final String? referer;
  final int? bytes;
  final String? upstream;
  final String? duration;
  final String? xff;

  bool get isAccess => format == LogFormat.nginxAccess;
  bool get isError => format == LogFormat.nginxError;
  bool get hasDetails =>
      isAccess ||
      isError ||
      (time != null && time!.isNotEmpty) ||
      message != path;
}

final _nginxAccess = RegExp(
  r'^(?<ip>\S+) \S+ \S+ \[(?<time>[^\]]+)\] '
  r'"(?<method>[A-Z]+) (?<path>\S+)(?: [^"]*)?" '
  r'(?<status>\d{3}) (?<bytes>\d+|-)'
  r'(?: "(?<referer>[^"]*)" "(?<ua>[^"]*)")?'
  r'(?: "(?<xff>[^"]*)")?'
  r'(?<extra>.*)$',
);

final _nginxError = RegExp(
  r'^(\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}) \[(\w+)\] (.*)$',
);

final _generic = RegExp(
  r'^(?:\[|\()?(\d{4}[-/]\d{2}[-/]\d{2}[ T]\d{2}:\d{2}:\d{2}(?:[.,]\d+)?'
  r'(?:Z|[+-]\d{2}:?\d{2})?)(?:\]|\))?\s*'
  r'(?:\[(TRACE|DEBUG|INFO|NOTICE|WARN|WARNING|ERROR|ERR|FATAL|CRITICAL)\]|'
  r'(TRACE|DEBUG|INFO|NOTICE|WARN|WARNING|ERROR|ERR|FATAL|CRITICAL)\b)?'
  r'\s*(.*)$',
  caseSensitive: false,
);

/// Parses JSON, nginx access/error and timestamped log lines.
/// Unrecognised text is returned as a plain line so nothing is dropped.
ParsedLogLine parseLogLine(String raw) {
  final trimmed = raw.trim();
  if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
    try {
      final json = jsonDecode(trimmed);
      if (json is Map) {
        final level = logLevelOf(
          (json['level'] ?? json['severity'] ?? '').toString(),
        );
        final message =
            (json['message'] ?? json['msg'] ?? json['log'] ?? trimmed)
                .toString();
        final time = (json['time'] ?? json['timestamp'] ?? '').toString();
        return ParsedLogLine(
          level: level,
          format: LogFormat.json,
          message: message,
          time: time.isEmpty ? null : time,
        );
      }
    } on FormatException {
      // Fall through to the plain line, never drop content.
    }
  }

  final access = _nginxAccess.firstMatch(trimmed);
  if (access != null) {
    final status = int.tryParse(access.namedGroup('status') ?? '');
    final extra = access.namedGroup('extra') ?? '';
    return ParsedLogLine(
      level: _levelForStatus(status),
      format: LogFormat.nginxAccess,
      message: trimmed,
      time: access.namedGroup('time'),
      ip: access.namedGroup('ip'),
      method: access.namedGroup('method'),
      path: access.namedGroup('path'),
      status: status,
      bytes: int.tryParse(access.namedGroup('bytes') ?? ''),
      referer: _clean(access.namedGroup('referer')),
      userAgent: _clean(access.namedGroup('ua')),
      xff: _clean(access.namedGroup('xff')),
      upstream: _field(extra, 'upstream_addr'),
      duration: _accessDuration(extra),
    );
  }

  final error = _nginxError.firstMatch(trimmed);
  if (error != null) {
    final rest = error.group(3) ?? '';
    return ParsedLogLine(
      level: logLevelOf(error.group(2) ?? ''),
      format: LogFormat.nginxError,
      message: rest,
      time: error.group(1),
      ip: _field(rest, 'client'),
      upstream: _field(rest, 'upstream'),
      path: _field(rest, 'request'),
    );
  }

  final generic = _generic.firstMatch(trimmed);
  if (generic != null) {
    return ParsedLogLine(
      level: logLevelOf(generic.group(2) ?? generic.group(3) ?? ''),
      format: LogFormat.generic,
      message: generic.group(4) ?? raw,
      time: generic.group(1),
    );
  }

  return ParsedLogLine(
    level: logLevelOf(trimmed),
    format: LogFormat.plain,
    message: raw,
  );
}

LogLevel logLevelOf(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('fatal') || normalized.contains('critical')) {
    return LogLevel.fatal;
  }
  if (normalized.contains('error') || normalized.contains('err')) {
    return LogLevel.error;
  }
  if (normalized.contains('warn')) return LogLevel.warn;
  if (normalized.contains('debug')) return LogLevel.debug;
  if (normalized.contains('trace')) return LogLevel.trace;
  if (normalized.contains('info') || normalized.contains('notice')) {
    return LogLevel.info;
  }
  return LogLevel.plain;
}

LogLevel _levelForStatus(int? status) {
  if (status == null) return LogLevel.plain;
  if (status >= 500) return LogLevel.error;
  if (status >= 400) return LogLevel.warn;
  if (status >= 300) return LogLevel.info;
  if (status >= 200) return LogLevel.info;
  return LogLevel.plain;
}

String? _clean(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty || text == '-') return null;
  return text;
}

String? _field(String text, String name) {
  if (text.isEmpty) return null;
  final quoted = RegExp('$name[=:]\\s*"([^"]*)"').firstMatch(text);
  if (quoted != null) return _clean(quoted.group(1));
  final match = RegExp('$name[=:]\\s*([^,\\s\\]]+)').firstMatch(text);
  return match == null ? null : _clean(match.group(1));
}

String? _accessDuration(String extra) {
  // Common nginx formats append $request_time as the last bare number.
  final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)\s*$').firstMatch(extra);
  if (match == null) return null;
  return '${match.group(1)}s';
}
