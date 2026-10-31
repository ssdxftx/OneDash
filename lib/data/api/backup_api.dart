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

  /// 搜索备份账号。
  Future<Map<String, dynamic>> searchBackupAccounts({
    required int page,
    required int pageSize,
    String type = '',
    String name = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/backups/search',
      data: {'page': page, 'pageSize': pageSize, 'type': type, 'name': name},
    );
    return ApiResponseParser.map(resp);
  }

  /// 创建备份账号。
  Future<void> createBackupAccount(Map<String, dynamic> data) async {
    await _client.post('/api/v2/backups', data: data);
  }

  /// 更新备份账号。
  Future<void> updateBackupAccount(Map<String, dynamic> data) async {
    await _client.post('/api/v2/backups/update', data: data);
  }

  /// 删除备份账号。
  Future<void> deleteBackupAccount(int id) async {
    await _client.post('/api/v2/backups/del', data: {'id': id});
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

  /// 刷新 Token。
  Future<void> refreshToken(int id) async {
    await _client.post('/api/v2/backups/refresh/token', data: {'id': id});
  }

  /// 获取本地备份目录。
  Future<String> getLocalDir() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/backups/local',
    );
    return ApiResponseParser.primitive<String>(resp);
  }
}
