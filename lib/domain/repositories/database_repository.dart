import '../../data/dto/common/page_result.dart';
import '../../data/dto/database/database_instance_dto.dart';
import '../../data/dto/database/slow_log_file_dto.dart';

/// 数据库数据仓库接口。
abstract interface class DatabaseRepository {
  Future<List<DatabaseInstanceDto>> listInstances(String types);
  Future<PageResult<DatabaseInstanceDto>> searchRemoteDatabases({
    required String type,
    int page,
    int pageSize,
    String info,
    String orderBy,
    String? order,
  });
  Future<DatabaseCheckDto> checkInstalled({
    required String key,
    required String name,
  });
  Future<int> getInstalledAppPort({required String type, String name});
  Future<PageResult<DatabaseSearchItemDto>> searchDatabases({
    required String database,
    int page,
    int pageSize,
  });
  Future<PageResult<DatabaseSearchItemDto>> searchPgDatabases({
    required String database,
    int page,
    int pageSize,
  });
  Future<void> loadPgFromRemote({required String database});
  Future<Map<String, String>> getStatus({
    required String type,
    required String name,
  });
  Future<List<DBResourceDto>> checkDelete({
    required int id,
    required String type,
    required String database,
  });
  Future<void> deleteDatabase({
    required int id,
    required String type,
    required String database,
    bool forceDelete,
    bool deleteBackup,
  });
  Future<void> changePassword({
    required int id,
    required String from,
    required String type,
    required String database,
    required String value,
    String? name,
  });
  Future<void> changeAccess({
    required int id,
    required String from,
    required String type,
    required String database,
    required String value,
  });
  Future<bool> checkRemoteConnection(Map<String, dynamic> body);
  Future<void> createRemoteDatabase(Map<String, dynamic> body);
  Future<Map<String, dynamic>> getConnInfo({
    required String type,
    required String name,
  });
  Future<bool> getRemoteAccess({required String type, required String name});
  Future<void> updateRemoteAccess({
    required String type,
    required String database,
    required bool remote,
  });
  Future<Map<String, dynamic>> getDatabase(String name);
  Future<void> updateRemoteDatabase(Map<String, dynamic> body);
  Future<void> deleteRemoteDatabase({
    required int id,
    required String database,
    bool forceDelete,
    bool deleteBackup,
  });
  Future<List<FormatCollationOption>> getFormatOptions(String name);
  Future<void> createDatabase(Map<String, dynamic> body);
  Future<void> createPgDatabase(Map<String, dynamic> body);
  Future<void> loadFromRemote({
    required String from,
    required String type,
    required String database,
  });
  Future<String> loadConfigFile({required String type, required String name});
  Future<void> updateConfigFile({
    required String type,
    required String database,
    required String file,
  });
  Future<MysqlVariables> loadVariables({
    required String type,
    required String name,
  });
  Future<void> updateVariables({
    required String type,
    required String database,
    required List<Map<String, dynamic>> variables,
  });
  Future<SlowLogFileDto> readSlowLog({
    required String type,
    required String name,
    int page,
    bool latest,
  });

  // Redis 专用
  Future<Map<String, String>> getRedisStatus({
    required String type,
    required String name,
  });
  Future<RedisConfDto> getRedisConf({
    required String type,
    required String name,
  });
  Future<void> updateRedisConf({
    required String dbType,
    required String database,
    required String timeout,
    required String maxclients,
    required String maxmemory,
  });
  Future<void> changeRedisPassword({
    required String database,
    required String value,
  });
  Future<RedisPersistenceDto> getRedisPersistence({
    required String type,
    required String name,
  });
  Future<void> updateRedisAofPersistence({
    required String dbType,
    required String database,
    required String appendonly,
    required String appendfsync,
  });
  Future<void> updateRedisRdbPersistence({
    required String dbType,
    required String database,
    required String save,
  });
  Future<void> installRedisCli();

  Future<PageResult<DatabaseSearchItemDto>> searchMongoDatabases({
    required String database,
    int page,
    int pageSize,
  });
  Future<void> createMongoDatabase(Map<String, dynamic> body);
  Future<void> deletePgDatabase({
    required int id,
    required String type,
    required String database,
    bool forceDelete,
    bool deleteBackup,
  });
  Future<void> deleteMongoDatabase({
    required int id,
    required String database,
    bool forceDelete,
    bool deleteBackup,
  });
  Future<void> changePgPrivileges({
    required String database,
    required String name,
    required String username,
    required bool superUser,
  });
  Future<void> bindPgUser({
    required String database,
    required String name,
    required String username,
    required String password,
    bool superUser,
  });
  Future<String> loadMongoPrivileges({
    required String database,
    required String name,
    required String username,
  });
  Future<void> changeMongoPrivileges({
    required String database,
    required String name,
    required String username,
    required String permission,
  });
  Future<void> bindMongoUser({
    required String database,
    required String name,
    required String username,
    required String password,
  });
  Future<List<Map<String, dynamic>>> searchUsers({required String database});
  Future<void> createUser({
    required String database,
    required String username,
    required String host,
    required String password,
    List<String> dbs,
    String description,
  });
  Future<void> deleteUser({
    required String database,
    required String username,
    required String host,
  });
  Future<void> changeUserPassword({
    required String database,
    required String username,
    required String host,
    required String password,
  });
  Future<List<Map<String, dynamic>>> searchGrants({required String database});
  Future<void> grantUser({
    required String database,
    required String db,
    required String username,
    required String host,
  });
  Future<void> revokeGrant({
    required String database,
    required String db,
    required String username,
    required String host,
  });
}
