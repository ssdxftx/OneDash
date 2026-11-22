class Server {
  int id = 0;

  String syncId = '';

  String? name;

  late String host;

  late int port;

  bool isHttps = false;

  bool allowInsecureConnections = false;

  int sortIndex = 0;

  DateTime? createdAt;

  DateTime? updatedAt;

  DateTime? lastUsedAt;

  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    return '$host:$port';
  }

  Uri get baseUrl {
    final scheme = isHttps ? 'https' : 'http';
    return Uri(scheme: scheme, host: host, port: port);
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'syncId': syncId,
      'name': name,
      'host': host,
      'port': port,
      'isHttps': isHttps,
      'allowInsecureConnections': allowInsecureConnections,
      'sortIndex': sortIndex,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  static Server fromJson(Map<String, Object?> json) {
    return Server()
      ..id = _intValue(json['id'])
      ..syncId = _stringValue(json['syncId'])
      ..name = _nullableStringValue(json['name'])
      ..host = _stringValue(json['host'])
      ..port = _intValue(json['port'])
      ..isHttps = json['isHttps'] == true
      ..allowInsecureConnections = json['allowInsecureConnections'] == true
      ..sortIndex = _intValue(json['sortIndex'])
      ..createdAt = _dateTimeValue(json['createdAt'])
      ..updatedAt = _dateTimeValue(json['updatedAt'])
      ..lastUsedAt = _dateTimeValue(json['lastUsedAt']);
  }

  static String _stringValue(Object? value) {
    if (value is String) return value;
    return value?.toString() ?? '';
  }

  static String? _nullableStringValue(Object? value) {
    if (value == null) return null;
    final text = _stringValue(value);
    return text.isEmpty ? null : text;
  }

  static int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _dateTimeValue(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
