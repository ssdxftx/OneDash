import '../../data/dto/backup/backup_record_dto.dart';
import '../../data/dto/backup/backup_record_search_req.dart';
import '../../data/dto/common/page_result.dart';
import '../../data/dto/common/task_log_dto.dart';

abstract interface class BackupRepository {
  Future<PageResult<BackupRecordDto>> searchRecords(BackupRecordSearchReq req);

  Future<List<BackupRecordSizeDto>> recordSizes(BackupRecordSearchReq req);

  Future<void> deleteRecords(List<int> ids);

  Future<void> backupApp({
    required String name,
    required String detailName,
    required String secret,
    required String taskID,
    required String description,
  });

  Future<void> backupContainer({
    required String name,
    required String detailName,
    required String secret,
    required String taskID,
    required String description,
    required bool stopBefore,
  });

  Future<void> recoverApp({
    required int downloadAccountID,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
    required int backupRecordID,
  });

  Future<void> recoverContainer({
    required int downloadAccountID,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
    required int backupRecordID,
    required int timeout,
  });

  Future<void> backupDatabase({
    required String type,
    required String name,
    required String detailName,
    required String secret,
    required String taskID,
    required String description,
    List<String> args,
  });

  Future<void> recoverDatabase({
    required int downloadAccountID,
    required String type,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
  });

  Future<String> downloadRecord({
    required int downloadAccountID,
    required String fileDir,
    required String fileName,
  });

  Future<void> uploadForRecover({
    required String filePath,
    required String targetDir,
  });

  Future<void> recoverByUpload({
    required int downloadAccountID,
    required String type,
    required String name,
    required String detailName,
    required String file,
    required String secret,
    required String taskID,
    int timeout,
  });

  Future<TaskLogDto> readTaskLog(String taskID, {required bool latest});
}
