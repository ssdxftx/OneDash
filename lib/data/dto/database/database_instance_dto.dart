/// 数据库实例（来自 GET /api/v2/databases/db/list/...）
class DatabaseInstanceDto {
  const DatabaseInstanceDto({
    required this.id,
    required this.type,
    required this.from,
    required this.database,
    required this.version,
    required this.address,
    this.port = 0,
    this.username = '',
    this.password = '',
    this.description = '',
    this.ssl = false,
    this.timeout = 0,
  });

  final int id;
  final String type;
  final String from;
  final String database;
  final String version;
  final String address;
  final int port;
  final String username;
  final String password;
  final String description;
  final bool ssl;
  final int timeout;

  String get name => database;

  factory DatabaseInstanceDto.fromJson(Map<String, dynamic> json) {
    return DatabaseInstanceDto(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      from: json['from'] as String? ?? '',
      database: json['database'] as String? ?? '',
      version: json['version'] as String? ?? '',
      address: json['address'] as String? ?? '',
      port: json['port'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ssl: json['ssl'] as bool? ?? false,
      timeout: json['timeout'] as int? ?? 0,
    );
  }
}

/// 应用安装检查结果（来自 POST /api/v2/apps/installed/check）
class DatabaseCheckDto {
  const DatabaseCheckDto({
    required this.isExist,
    required this.name,
    required this.app,
    required this.version,
    required this.status,
    required this.createdAt,
    required this.lastBackupAt,
    required this.appInstallId,
    required this.containerName,
    required this.installPath,
    required this.httpPort,
    required this.httpsPort,
    required this.websiteDir,
  });

  final bool isExist;
  final String name;
  final String app;
  final String version;
  final String status;
  final String createdAt;
  final String lastBackupAt;
  final int appInstallId;
  final String containerName;
  final String installPath;
  final int httpPort;
  final int httpsPort;
  final String websiteDir;

  factory DatabaseCheckDto.fromJson(Map<String, dynamic> json) {
    return DatabaseCheckDto(
      isExist: json['isExist'] as bool? ?? false,
      name: json['name'] as String? ?? '',
      app: json['app'] as String? ?? '',
      version: json['version'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      lastBackupAt: json['lastBackupAt'] as String? ?? '',
      appInstallId: json['appInstallId'] as int? ?? 0,
      containerName: json['containerName'] as String? ?? '',
      installPath: json['installPath'] as String? ?? '',
      httpPort: json['httpPort'] as int? ?? 0,
      httpsPort: json['httpsPort'] as int? ?? 0,
      websiteDir: json['websiteDir'] as String? ?? '',
    );
  }
}

/// 数据库搜索结果项（来自 POST /api/v2/databases/search 或 /pg/search）。
///
/// MySQL 返回 `mysqlName`，PostgreSQL 返回 `postgresqlName`，
/// 通过 [instanceName] 统一获取实例名。
class DatabaseSearchItemDto {
  const DatabaseSearchItemDto({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.from,
    required this.mysqlName,
    required this.format,
    required this.collation,
    required this.username,
    required this.password,
    required this.permission,
    required this.isDelete,
    required this.description,
    this.pgName,
    this.mongodbName,
    this.superUser,
    this.dbType = '',
  });

  final int id;
  final String createdAt;
  final String name;
  final String from;
  final String mysqlName;
  final String format;
  final String collation;
  final String username;
  final String password;
  final String permission;
  final bool isDelete;
  final String description;
  final String? pgName;
  final String? mongodbName;
  final bool? superUser;

  /// 列表分组用的数据库类型（mysql/postgresql/mongodb/redis）。
  final String dbType;

  /// 实例名：PG/Mongo 优先用各自字段，否则回退到 [mysqlName]。
  String get instanceName {
    if (pgName != null && pgName!.isNotEmpty) return pgName!;
    if (mongodbName != null && mongodbName!.isNotEmpty) return mongodbName!;
    return mysqlName;
  }

  DatabaseSearchItemDto withType(String type) => DatabaseSearchItemDto(
    id: id,
    createdAt: createdAt,
    name: name,
    from: from,
    mysqlName: mysqlName,
    format: format,
    collation: collation,
    username: username,
    password: password,
    permission: permission,
    isDelete: isDelete,
    description: description,
    pgName: pgName,
    mongodbName: mongodbName,
    superUser: superUser,
    dbType: type,
  );

  factory DatabaseSearchItemDto.fromJson(Map<String, dynamic> json) {
    return DatabaseSearchItemDto(
      id: json['id'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      name: json['name'] as String? ?? '',
      from: json['from'] as String? ?? '',
      mysqlName: json['mysqlName'] as String? ?? '',
      format: json['format'] as String? ?? '',
      collation: json['collation'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      permission: json['permission'] as String? ?? '',
      isDelete: json['isDelete'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      pgName: json['postgresqlName'] as String?,
      mongodbName: json['mongodbName'] as String?,
      superUser: json['superUser'] as bool?,
    );
  }
}

/// 字符集与排序规则选项（来自 POST /api/v2/databases/format/options）。
class FormatCollationOption {
  const FormatCollationOption({
    required this.format,
    this.collations = const [],
  });

  final String format;
  final List<String> collations;

  factory FormatCollationOption.fromJson(Map<String, dynamic> json) {
    return FormatCollationOption(
      format: json['format'] as String? ?? '',
      collations:
          (json['collations'] as List?)?.whereType<String>().toList() ??
          const [],
    );
  }
}

/// MySQL 性能变量（来自 POST /api/v2/databases/variables）。
class MysqlVariables {
  const MysqlVariables({
    this.binlogCacheSize,
    this.innodbBufferPoolSize,
    this.innodbLogBufferSize,
    this.joinBufferSize,
    this.keyBufferSize,
    this.longQueryTime,
    this.maxConnections,
    this.maxHeapTableSize,
    this.queryCacheSize,
    this.queryCacheType,
    this.readBufferSize,
    this.readRndBufferSize,
    this.slowQueryLog,
    this.sortBufferSize,
    this.tableOpenCache,
    this.threadCacheSize,
    this.threadStackSize,
    this.tmpTableSize,
  });

  final String? binlogCacheSize;
  final String? innodbBufferPoolSize;
  final String? innodbLogBufferSize;
  final String? joinBufferSize;
  final String? keyBufferSize;
  final String? longQueryTime;
  final String? maxConnections;
  final String? maxHeapTableSize;
  final String? queryCacheSize;
  final String? queryCacheType;
  final String? readBufferSize;
  final String? readRndBufferSize;
  final String? slowQueryLog;
  final String? sortBufferSize;
  final String? tableOpenCache;
  final String? threadCacheSize;
  final String? threadStackSize;
  final String? tmpTableSize;

  factory MysqlVariables.fromJson(Map<String, dynamic> json) {
    return MysqlVariables(
      binlogCacheSize: json['binlog_cache_size'] as String?,
      innodbBufferPoolSize: json['innodb_buffer_pool_size'] as String?,
      innodbLogBufferSize: json['innodb_log_buffer_size'] as String?,
      joinBufferSize: json['join_buffer_size'] as String?,
      keyBufferSize: json['key_buffer_size'] as String?,
      longQueryTime: json['long_query_time'] as String?,
      maxConnections: json['max_connections'] as String?,
      maxHeapTableSize: json['max_heap_table_size'] as String?,
      queryCacheSize: json['query_cache_size'] as String?,
      queryCacheType: json['query_cache_type'] as String?,
      readBufferSize: json['read_buffer_size'] as String?,
      readRndBufferSize: json['read_rnd_buffer_size'] as String?,
      slowQueryLog: json['slow_query_log'] as String?,
      sortBufferSize: json['sort_buffer_size'] as String?,
      tableOpenCache: json['table_open_cache'] as String?,
      threadCacheSize: json['thread_cache_size'] as String?,
      threadStackSize: json['thread_stack'] as String?,
      tmpTableSize: json['tmp_table_size'] as String?,
    );
  }
}

/// 删除检查返回的占用资源（来自 POST /api/v2/databases/del/check）。
class DBResourceDto {
  const DBResourceDto({required this.type, required this.name});

  final String type;
  final String name;

  factory DBResourceDto.fromJson(Map<String, dynamic> json) {
    return DBResourceDto(
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

/// Redis 配置（来自 POST /databases/redis/conf）。
class RedisConfDto {
  const RedisConfDto({
    this.maxclients = '10000',
    this.maxmemory = '0',
    this.requirepass = '',
    this.timeout = '0',
    this.port = '6379',
  });

  final String maxclients;
  final String maxmemory;
  final String requirepass;
  final String timeout;
  final String port;

  factory RedisConfDto.fromJson(Map<String, dynamic> json) {
    return RedisConfDto(
      maxclients: '${json['maxclients'] ?? '10000'}',
      maxmemory: '${json['maxmemory'] ?? '0'}',
      requirepass: '${json['requirepass'] ?? ''}',
      timeout: '${json['timeout'] ?? '0'}',
      port: '${json['port'] ?? '6379'}',
    );
  }
}

/// Redis 持久化配置（来自 POST /databases/redis/persistence/conf）。
class RedisPersistenceDto {
  const RedisPersistenceDto({
    this.aofEnabled = 'no',
    this.rdbEnabled = 'yes',
    this.save = '',
    this.appendfsync = 'everysec',
  });

  final String aofEnabled;
  final String rdbEnabled;
  final String save;
  final String appendfsync;

  factory RedisPersistenceDto.fromJson(Map<String, dynamic> json) {
    return RedisPersistenceDto(
      aofEnabled: '${json['aof_enabled'] ?? json['aofEnabled'] ?? 'no'}',
      rdbEnabled: '${json['rdb_enabled'] ?? json['rdbEnabled'] ?? 'yes'}',
      save: '${json['save'] ?? ''}',
      appendfsync: '${json['appendfsync'] ?? 'everysec'}',
    );
  }
}
