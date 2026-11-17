import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/backup/backup_record_dto.dart';
import '../dto/backup/backup_record_search_req.dart';
import '../dto/common/page_result.dart';
import '../dto/cronjob/cronjob_form_data_dto.dart';

class BackupApi {
  BackupApi(this._client);

  final DioClient _client;

  Future<PageResult<BackupRecordDto>> searchRecords(
    BackupRecordSearchReq req,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/record/search',
      query: const {'operateNode': 'local'},
      data: req.toJson(),
    );
    return PageResult<BackupRecordDto>.fromJson(
      ApiResponseParser.map(resp),
      BackupRecordDto.fromJson,
    );
  }

  Future<List<BackupRecordSizeDto>> recordSizes(
    BackupRecordSearchReq req,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/record/size',
      query: const {'operateNode': 'local'},
      data: req.toJson(),
    );
    return ApiResponseParser.list(resp, BackupRecordSizeDto.fromJson);
  }

  Future<void> deleteRecords(List<int> ids) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/record/del',
      data: {'ids': ids, 'node': 'local'},
    );
  }

  Future<void> backupApp({
    required String name,
    required String detailName,
    required String secret,
    required String taskID,
    required String description,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/backup',
      query: const {'operateNode': 'local'},
      data: {
        'type': 'app',
        'name': name,
        'detailName': detailName,
        'secret': secret,
        'taskID': taskID,
        'description': description,
        'args': <Object>[],
      },
    );
  }

  Future<void> backupContainer({
    required String name,
    required String detailName,
    required String secret,
    required String taskID,
    required String description,
    required bool stopBefore,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/backup',
      query: const {'operateNode': 'local'},
      data: {
        'type': 'container',
        'name': name,
        'detailName': detailName,
        'secret': secret,
        'taskID': taskID,
        'description': description,
        'args': <Object>[],
        'stopBefore': stopBefore,
      },
    );
  }

  Future<void> recoverApp({
    required int downloadAccountID,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
    required int backupRecordID,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/recover',
      query: const {'operateNode': 'local'},
      data: {
        'downloadAccountID': downloadAccountID,
        'type': 'app',
        'name': name,
        'detailName': detailName,
        'file': file,
        'secret': secret,
        'taskID': taskID,
        'backupRecordID': backupRecordID,
        'timeout': 1800,
      },
    );
  }

  Future<void> recoverContainer({
    required int downloadAccountID,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
    required int backupRecordID,
    required int timeout,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/recover',
      query: const {'operateNode': 'local'},
      data: {
        'downloadAccountID': downloadAccountID,
        'type': 'container',
        'name': name,
        'detailName': detailName,
        'file': file,
        'secret': secret,
        'taskID': taskID,
        'backupRecordID': backupRecordID,
        'timeout': timeout,
      },
    );
  }

  Future<void> backupDatabase({
    required String type,
    required String name,
    required String detailName,
    required String secret,
    required String taskID,
    required String description,
    List<String> args = const [],
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/backup',
      query: const {'operateNode': 'local'},
      data: {
        'type': type,
        'name': name,
        'detailName': detailName,
        'secret': secret,
        'taskID': taskID,
        'description': description,
        'args': args,
      },
    );
  }

  Future<void> recoverDatabase({
    required int downloadAccountID,
    required String type,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
    int backupRecordID = 0,
    int timeout = 0,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/recover',
      query: const {'operateNode': 'local'},
      data: {
        'downloadAccountID': downloadAccountID,
        'type': type,
        'name': name,
        'detailName': detailName,
        'file': file,
        'secret': secret,
        'taskID': taskID,
        'backupRecordID': backupRecordID,
        'timeout': timeout,
      },
    );
  }

  Future<String> downloadRecord({
    required int downloadAccountID,
    required String fileDir,
    required String fileName,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/record/download',
      data: {
        'downloadAccountID': downloadAccountID,
        'fileDir': fileDir,
        'fileName': fileName,
      },
    );
    return ApiResponseParser.primitive<String>(resp);
  }

  /// 将已有文件复制到导入目录（从服务器选择文件用）。
  Future<void> uploadForRecover({
    required String filePath,
    required String targetDir,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/upload',
      data: {'filePath': filePath, 'targetDir': targetDir},
    );
  }

  /// 从本机上传文件执行恢复（导入备份）。
  Future<void> recoverByUpload({
    required int downloadAccountID,
    required String type,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
    int timeout = 0,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/recover/byupload',
      query: const {'operateNode': 'local'},
      data: {
        'downloadAccountID': downloadAccountID,
        'type': type,
        'name': name,
        'detailName': detailName,
        'file': file,
        'secret': secret,
        'taskID': taskID,
        'timeout': timeout,
      },
    );
  }

  /// 获取备份账号选项列表。
  Future<List<BackupOptionDto>> loadBackupOptions() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/backups/options',
    );
    return ApiResponseParser.list(resp, BackupOptionDto.fromJson);
  }

  /// GET /api/v2/backups/check/{name} — 校验备份账号名称是否被使用。
  Future<void> checkBackupName(String name) async {
    await _client.get<Map<String, dynamic>>(
      '/api/v2/backups/check/${Uri.encodeComponent(name)}',
    );
  }

  /// POST /api/v2/backups/search/files — 查询备份账号中的快照文件。
  Future<List<String>> searchRecordFiles(int recordId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/search/files',
      data: {'id': recordId},
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data.map((item) => '$item').toList(growable: false);
  }

  /// POST /api/v2/backups/record/search/bycronjob
  Future<PageResult<BackupRecordDto>> searchRecordsByCronjob({
    required int cronjobId,
    int page = 1,
    int pageSize = 100,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/record/search/bycronjob',
      data: {'cronjobID': cronjobId, 'page': page, 'pageSize': pageSize},
    );
    return PageResult<BackupRecordDto>.fromJson(
      ApiResponseParser.map(resp),
      BackupRecordDto.fromJson,
    );
  }

  /// POST /api/v2/backups/record/description/update
  Future<void> updateRecordDescription({
    required int id,
    required String description,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/record/description/update',
      data: {'id': id, 'description': description},
    );
  }

  /// 搜索备份账号。
  Future<Map<String, dynamic>> searchBackupAccounts({
    required int page,
    required int pageSize,
    String type = '',
    String name = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/search',
      data: {'page': page, 'pageSize': pageSize, 'type': type, 'info': name},
    );
    return ApiResponseParser.map(resp);
  }

  /// 创建备份账号；面板级账号使用 core 路由。
  Future<void> createBackupAccount(Map<String, dynamic> data) async {
    await _client.post(
      data['isPublic'] == true ? '/api/v2/core/backups' : '/api/v2/backups',
      data: data,
    );
  }

  /// 更新备份账号；面板级账号使用 core 路由。
  Future<void> updateBackupAccount(Map<String, dynamic> data) async {
    await _client.post(
      data['isPublic'] == true
          ? '/api/v2/core/backups/update'
          : '/api/v2/backups/update',
      data: data,
    );
  }

  /// 删除备份账号；面板级账号按名称删除。
  Future<void> deleteBackupAccount({
    required int id,
    required String name,
    required bool isPublic,
  }) async {
    await _client.post(
      isPublic ? '/api/v2/core/backups/del' : '/api/v2/backups/del',
      data: isPublic ? {'name': name} : {'id': id},
    );
  }

  /// 测试备份账号连接。
  Future<Map<String, dynamic>> checkBackupConnection(
    Map<String, dynamic> data,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/conn/check',
      data: data,
    );
    return ApiResponseParser.map(resp);
  }

  /// 获取备份桶列表。
  Future<List<dynamic>> listBuckets(Map<String, dynamic> data) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/buckets',
      data: data,
    );
    final result = resp.data?['data'];
    return result is List ? result : [];
  }

  /// 刷新 Token；面板级账号按名称刷新。
  Future<void> refreshToken({
    required int id,
    required String name,
    required bool isPublic,
  }) async {
    await _client.post(
      isPublic
          ? '/api/v2/core/backups/refresh/token'
          : '/api/v2/backups/refresh/token',
      data: isPublic ? {'name': name} : {'id': id},
    );
  }

  /// 获取备份客户端应用信息。
  /// GET /api/v2/core/backups/client/:clientType
  Future<Map<String, dynamic>> getClientInfo(String clientType) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/core/backups/client/${Uri.encodeComponent(clientType)}',
    );
    return ApiResponseParser.map(resp);
  }

  /// 获取本地备份目录。
  Future<String> getLocalDir() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/backups/local',
    );
    return ApiResponseParser.primitive<String>(resp);
  }
}
