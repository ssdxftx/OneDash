import '../../data/dto/common/page_result.dart';
import '../../data/dto/log/login_log_dto.dart';
import '../../data/dto/log/operation_log_dto.dart';
import '../../data/dto/log/ssh_log_dto.dart';
import '../../data/dto/log/task_log_dto.dart';

/// 日志审计数据仓库接口。
abstract interface class LogRepository {
  Future<PageResult<OperationLogDto>> searchOperationLogs({
    int page,
    int pageSize,
    String source,
    String status,
    String node,
    String operation,
  });

  Future<PageResult<LoginLogDto>> searchLoginLogs({
    int page,
    int pageSize,
    String ip,
    String status,
  });

  Future<void> cleanLogs(String logType);

  Future<List<String>> getSystemLogFiles();

  Future<PageResult<TaskLogDto>> searchTaskLogs({
    int page,
    int pageSize,
    String status,
    String type,
    String taskID,
  });

  Future<PageResult<SshLogDto>> searchSshLogs({
    int page,
    int pageSize,
    String info,
    String status,
  });
}
