import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/common/page_result.dart';
import '../dto/cronjob/cronjob_form_data_dto.dart';
import '../dto/database/database_instance_dto.dart';

/// 数据库 API。
///
/// 对应 1Panel `/databases` 相关接口。
class DatabaseApi {
  DatabaseApi(this._client);

  final DioClient _client;

  /// 获取数据库实例列表。
  ///
  /// [types] 为逗号分隔的数据库类型，如
  /// `postgresql,postgresql-cluster,mysql,mariadb,mysql-cluster,redis,redis-cluster`。
  Future<List<DatabaseInstanceDto>> listInstances(String types) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/databases/db/list/$types',
    );
    final data = resp.data?['data'];
    if (data == null) return const [];
    return (data as List)
        .whereType<Map<String, dynamic>>()
        .map(DatabaseInstanceDto.fromJson)
        .toList();
  }

  /// 搜索数据库实例中的数据库列表。
  Future<PageResult<DatabaseSearchItemDto>> searchDatabases({
    required String database,
    int page = 1,
    int pageSize = 20,
    String info = '',
    String orderBy = 'createdAt',
    String? order,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        'info': info,
        'database': database,
        'orderBy': orderBy,
        'order': order ?? 'null',
      },
    );
    return PageResult<DatabaseSearchItemDto>.fromJson(
      ApiResponseParser.map(resp),
      DatabaseSearchItemDto.fromJson,
    );
  }

  /// 搜索 PostgreSQL 实例中的数据库列表。
  Future<PageResult<DatabaseSearchItemDto>> searchPgDatabases({
    required String database,
    int page = 1,
    int pageSize = 20,
    String info = '',
    String orderBy = 'createdAt',
    String? order,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/pg/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        'info': info,
        'database': database,
        'orderBy': orderBy,
        'order': order ?? 'null',
      },
    );
    return PageResult<DatabaseSearchItemDto>.fromJson(
      ApiResponseParser.map(resp),
      DatabaseSearchItemDto.fromJson,
    );
  }

  /// 从 PostgreSQL 服务器同步数据库列表到面板。
  ///
  /// [database] 为 PG 实例名（URL 路径参数）。
  Future<void> loadPgFromRemote({required String database}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/pg/$database/load',
    );
  }

  /// 获取数据库运行状态与性能指标。
  Future<Map<String, String>> getStatus({
    required String type,
    required String name,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/status',
      data: {'type': type, 'name': name},
    );
    final raw = ApiResponseParser.map(resp);
    return raw.map((k, v) => MapEntry(k, v?.toString() ?? ''));
  }

  /// 删除前检查：是否有网站/应用占用该数据库。
  ///
  /// 返回空数组表示无占用，可以安全删除。
  Future<List<DBResourceDto>> checkDelete({
    required int id,
    required String type,
    required String database,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/del/check',
      data: {'id': id, 'type': type, 'database': database},
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(DBResourceDto.fromJson)
        .toList();
  }

  /// 删除数据库。
  Future<void> deleteDatabase({
    required int id,
    required String type,
    required String database,
    bool forceDelete = false,
    bool deleteBackup = false,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/del',
      data: {
        'id': id,
        'type': type,
        'database': database,
        'forceDelete': forceDelete,
        'deleteBackup': deleteBackup,
      },
    );
  }

  /// 修改数据库密码。
  ///
  /// [value] 为 Base64 编码后的新密码。
  Future<void> changePassword({
    required int id,
    required String from,
    required String type,
    required String database,
    required String value,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/change/password',
      data: {
        'id': id,
        'from': from,
        'type': type,
        'database': database,
        'value': value,
      },
    );
  }

  /// 测试远程数据库连接。
  ///
  /// [body] 为 `DatabaseCreate` 结构的字段映射。
  /// 返回 `true` 表示连接成功。
  Future<bool> checkRemoteConnection(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/db/check',
      data: body,
    );
    return resp.data?['data'] == true;
  }

  /// 创建远程数据库连接。
  Future<void> createRemoteDatabase(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/db',
      data: body,
    );
  }

  /// 搜索远程数据库连接列表。
  Future<PageResult<DatabaseInstanceDto>> searchRemoteDatabases({
    required String type,
    int page = 1,
    int pageSize = 20,
    String info = '',
    String orderBy = 'createdAt',
    String? order,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/db/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        'info': info,
        'type': type,
        'orderBy': orderBy,
        'order': order ?? 'null',
      },
    );
    return PageResult<DatabaseInstanceDto>.fromJson(
      ApiResponseParser.map(resp),
      DatabaseInstanceDto.fromJson,
    );
  }

  /// 检查数据库是否允许远程 root 访问（仅本地数据库）。
  ///
  /// 返回 `true` 表示已开启远程访问。
  Future<bool> getRemoteAccess({
    required String type,
    required String name,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/remote',
      data: {'type': type, 'name': name},
    );
    return resp.data?['data'] == true;
  }

  /// 设置本地数据库实例是否允许远程 root 访问。
  Future<void> updateRemoteAccess({
    required String type,
    required String database,
    required bool remote,
  }) async {
    // 1Panel 修改 root 远程访问权限。
    // id: 0 表示修改 root，database 传实例名，from 固定为 local。
    await changeAccess(
      id: 0,
      from: 'local',
      type: type,
      database: database,
      value: remote ? '%' : 'localhost',
    );
  }

  /// 获取远程数据库连接详情。
  ///
  /// 返回包含 `address`、`port`、`username`、`password` 等字段的原始映射。
  Future<Map<String, dynamic>> getDatabase(String name) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/databases/db/$name',
    );
    return (resp.data?['data'] as Map<String, dynamic>?) ?? {};
  }

  /// 更新远程数据库连接。
  Future<void> updateRemoteDatabase(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/db/update',
      data: body,
    );
  }

  /// 解绑远程数据库实例。
  Future<void> deleteRemoteDatabase({
    required int id,
    required String database,
    bool forceDelete = false,
    bool deleteBackup = false,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/db/del',
      data: {
        'id': id,
        'database': database,
        'deleteBackup': deleteBackup,
        'forceDelete': forceDelete,
      },
    );
  }

  /// 获取字符集与排序规则选项。
  ///
  /// [name] 为当前连接名（实例名），不是新库名。
  Future<List<FormatCollationOption>> getFormatOptions(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/format/options',
      data: {'name': name},
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(FormatCollationOption.fromJson)
        .toList();
  }

  /// 创建数据库。
  Future<void> createDatabase(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>('/api/v2/databases', data: body);
  }

  /// 创建 PostgreSQL 数据库。
  Future<void> createPgDatabase(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/pg',
      data: body,
    );
  }

  /// 从服务器同步数据库（将面板记录与 MySQL 实例对齐）。
  Future<void> loadFromRemote({
    required String from,
    required String type,
    required String database,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/load',
      data: {'from': from, 'type': type, 'database': database},
    );
  }

  /// 修改数据库访问权限。
  ///
  /// [value] 为主机规则：`%`（任意）、`localhost`（仅本机）、或自定义 IP/网段。
  Future<void> changeAccess({
    required int id,
    required String from,
    required String type,
    required String database,
    required String value,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/change/access',
      data: {
        'id': id,
        'from': from,
        'type': type,
        'database': database,
        'value': value,
      },
    );
  }

  /// 加载数据库配置文件内容（如 my.cnf）。
  Future<String> loadConfigFile({
    required String type,
    required String name,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/common/load/file',
      data: {'type': type, 'name': name},
    );
    return ApiResponseParser.primitive<String>(resp);
  }

  /// 更新数据库配置文件。
  Future<void> updateConfigFile({
    required String type,
    required String database,
    required String file,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/common/update/conf',
      data: {'type': type, 'database': database, 'file': file},
    );
    ApiResponseParser.ok(resp);
  }

  /// 加载 MySQL 性能变量。
  Future<MysqlVariables> loadVariables({
    required String type,
    required String name,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/variables',
      data: {'type': type, 'name': name},
    );
    return ApiResponseParser.object(resp, MysqlVariables.fromJson);
  }

  /// 更新 MySQL 性能变量。
  Future<void> updateVariables({
    required String type,
    required String database,
    required List<Map<String, dynamic>> variables,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/variables/update',
      data: {'type': type, 'database': database, 'variables': variables},
    );
    ApiResponseParser.ok(resp);
  }

  // ── Redis 专用接口 ──────────────────────────────────────────

  /// 获取 Redis 运行状态（专用接口，返回结构化指标）。
  Future<Map<String, String>> getRedisStatus({
    required String type,
    required String name,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/redis/status',
      data: {'type': type, 'name': name},
    );
    final raw = ApiResponseParser.map(resp);
    return raw.map((k, v) => MapEntry(k, v?.toString() ?? ''));
  }

  /// 获取 Redis 配置。
  Future<RedisConfDto> getRedisConf({
    required String type,
    required String name,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/redis/conf',
      data: {'type': type, 'name': name},
    );
    return ApiResponseParser.object(resp, RedisConfDto.fromJson);
  }

  /// 更新 Redis 配置（timeout / maxclients / maxmemory）。
  Future<void> updateRedisConf({
    required String dbType,
    required String database,
    required String timeout,
    required String maxclients,
    required String maxmemory,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/redis/conf/update',
      data: {
        'dbType': dbType,
        'database': database,
        'timeout': timeout,
        'maxclients': maxclients,
        'maxmemory': maxmemory,
      },
    );
    ApiResponseParser.ok(resp);
  }

  /// 修改 Redis 密码。
  Future<void> changeRedisPassword({
    required String database,
    required String value,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/redis/password',
      data: {'database': database, 'value': value},
    );
    ApiResponseParser.ok(resp);
  }

  /// 获取 Redis 持久化配置。
  Future<RedisPersistenceDto> getRedisPersistence({
    required String type,
    required String name,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/redis/persistence/conf',
      data: {'type': type, 'name': name},
    );
    return ApiResponseParser.object(resp, RedisPersistenceDto.fromJson);
  }

  /// 更新 Redis AOF 持久化配置。
  Future<void> updateRedisAofPersistence({
    required String dbType,
    required String database,
    required String appendonly,
    required String appendfsync,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/redis/persistence/update',
      data: {
        'dbType': dbType,
        'database': database,
        'type': 'aof',
        'appendonly': appendonly,
        'appendfsync': appendfsync,
      },
    );
    ApiResponseParser.ok(resp);
  }

  /// 更新 Redis RDB 持久化配置。
  ///
  /// [save] 为逗号分隔的规则串，如 `"3600 1,300 100,60 10000"`。
  Future<void> updateRedisRdbPersistence({
    required String dbType,
    required String database,
    required String save,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/redis/persistence/update',
      data: {
        'dbType': dbType,
        'database': database,
        'type': 'rbd',
        'save': save,
      },
    );
    ApiResponseParser.ok(resp);
  }

  /// 安装 redis-cli（用于远程 Redis 终端）。
  Future<void> installRedisCli() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/databases/redis/install/cli',
    );
    ApiResponseParser.ok(resp);
  }

  /// 获取数据库项列表（按类型，用于计划任务表单选择）。
  Future<List<DatabaseItemDto>> loadDatabaseItems(String dbType) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/databases/db/item/$dbType',
    );
    return ApiResponseParser.list(resp, DatabaseItemDto.fromJson);
  }
}
