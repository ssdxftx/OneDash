import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/backup_api.dart';
import '../api/file_api.dart';
import '../dto/backup/backup_record_dto.dart';
import '../dto/backup/backup_record_search_req.dart';
import '../dto/common/page_result.dart';
import '../dto/common/task_log_dto.dart';

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(this._backupApi, this._fileApi);

  final BackupApi _backupApi;
  final FileApi _fileApi;

  @override
  Future<PageResult<BackupRecordDto>> searchRecords(
    BackupRecordSearchReq req,
  ) => _backupApi.searchRecords(req);

  @override
  Future<List<BackupRecordSizeDto>> recordSizes(BackupRecordSearchReq req) =>
      _backupApi.recordSizes(req);

  @override
  Future<void> deleteRecords(List<int> ids) => _backupApi.deleteRecords(ids);

  @override
  Future<void> backupApp({
    required String name,
    required String detailName,
    required String secret,
    required String taskID,
    required String description,
  }) => _backupApi.backupApp(
    name: name,
    detailName: detailName,
    secret: secret,
    taskID: taskID,
    description: description,
  );

  @override
  Future<void> backupContainer({
    required String name,
    required String detailName,
    required String secret,
    required String taskID,
    required String description,
    required bool stopBefore,
  }) => _backupApi.backupContainer(
    name: name,
    detailName: detailName,
    secret: secret,
    taskID: taskID,
    description: description,
    stopBefore: stopBefore,
  );

  @override
  Future<void> recoverApp({
    required int downloadAccountID,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
    required int backupRecordID,
  }) => _backupApi.recoverApp(
    downloadAccountID: downloadAccountID,
    name: name,
    detailName: detailName,
    file: file,
    secret: secret,
    taskID: taskID,
    backupRecordID: backupRecordID,
  );

  @override
  Future<void> recoverContainer({
    required int downloadAccountID,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
    required int backupRecordID,
    required int timeout,
  }) => _backupApi.recoverContainer(
    downloadAccountID: downloadAccountID,
    name: name,
    detailName: detailName,
    file: file,
    secret: secret,
    taskID: taskID,
    backupRecordID: backupRecordID,
    timeout: timeout,
  );

  @override
  Future<void> backupDatabase({
    required String type,
    required String name,
    required String detailName,
    required String secret,
    required String taskID,
    required String description,
    List<String> args = const [],
  }) => _backupApi.backupDatabase(
    type: type,
    name: name,
    detailName: detailName,
    secret: secret,
    taskID: taskID,
    description: description,
    args: args,
  );

  @override
  Future<void> recoverDatabase({
    required int downloadAccountID,
    required String type,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
  }) => _backupApi.recoverDatabase(
    downloadAccountID: downloadAccountID,
    type: type,
    name: name,
    detailName: detailName,
    file: file,
    secret: secret,
    taskID: taskID,
  );

  @override
  Future<String> downloadRecord({
    required int downloadAccountID,
    required String fileDir,
    required String fileName,
  }) => _backupApi.downloadRecord(
    downloadAccountID: downloadAccountID,
    fileDir: fileDir,
    fileName: fileName,
  );

  @override
  Future<void> uploadForRecover({
    required String filePath,
    required String targetDir,
  }) => _backupApi.uploadForRecover(filePath: filePath, targetDir: targetDir);

  @override
  Future<void> recoverByUpload({
    required int downloadAccountID,
    required String type,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
    int timeout = 0,
  }) => _backupApi.recoverByUpload(
    downloadAccountID: downloadAccountID,
    type: type,
    name: name,
    detailName: detailName,
    file: file,
    secret: secret,
    taskID: taskID,
    timeout: timeout,
  );

  @override
  Future<TaskLogDto> readTaskLog(String taskID, {required bool latest}) {
    return _fileApi.readFile<TaskLogDto>(
      id: 0,
      type: 'task',
      name: '',
      taskID: taskID,
      latest: latest,
      fromJson: TaskLogDto.fromJson,
    );
  }
}

final backupRepositoryProvider = FutureProvider<BackupRepository>((ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return BackupRepositoryImpl(BackupApi(client), FileApi(client));
}, dependencies: [activeServerIdProvider]);
