/// 备份账号选项（来自 GET /api/v2/backups/options）。
class BackupOptionDto {
  const BackupOptionDto({
    required this.id,
    required this.name,
    required this.type,
    required this.isPublic,
  });

  final int id;
  final String name;
  final String type;
  final bool isPublic;

  factory BackupOptionDto.fromJson(Map<String, dynamic> json) {
    return BackupOptionDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
    );
  }
}

/// 网站选项（来自 POST /api/v2/websites/options）。
class WebsiteOptionDto {
  const WebsiteOptionDto({
    required this.id,
    required this.primaryDomain,
    required this.alias,
  });

  final int id;
  final String primaryDomain;
  final String alias;

  factory WebsiteOptionDto.fromJson(Map<String, dynamic> json) {
    return WebsiteOptionDto(
      id: json['id'] as int? ?? 0,
      primaryDomain: json['primaryDomain'] as String? ?? '',
      alias: json['alias'] as String? ?? '',
    );
  }
}

/// 脚本库选项（来自 GET /api/v2/cronjobs/script/options）。
class ScriptOptionDto {
  const ScriptOptionDto({required this.id, required this.name});

  final int id;
  final String name;

  factory ScriptOptionDto.fromJson(Map<String, dynamic> json) {
    return ScriptOptionDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

/// 数据库项选项（来自 GET /api/v2/databases/db/item/{type}）。
class DatabaseItemDto {
  const DatabaseItemDto({
    required this.id,
    required this.name,
    required this.from,
    required this.database,
  });

  final int id;
  final String name;
  final String from;
  final String database;

  factory DatabaseItemDto.fromJson(Map<String, dynamic> json) {
    return DatabaseItemDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      from: json['from'] as String? ?? '',
      database: json['database'] as String? ?? '',
    );
  }
}

/// 快照规则。
class SnapshotRuleDto {
  const SnapshotRuleDto({this.withImage = false, this.ignoreAppIDs = const []});

  final bool withImage;
  final List<int> ignoreAppIDs;

  factory SnapshotRuleDto.fromJson(Map<String, dynamic> json) {
    return SnapshotRuleDto(
      withImage: json['withImage'] as bool? ?? false,
      ignoreAppIDs:
          (json['ignoreAppIDs'] as List?)
              ?.map((e) => e is int ? e : int.tryParse('$e') ?? 0)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'withImage': withImage,
    'ignoreAppIDs': ignoreAppIDs,
  };
}
