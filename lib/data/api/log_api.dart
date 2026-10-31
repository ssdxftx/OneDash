import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/common/page_result.dart';
import '../dto/log/login_log_dto.dart';
import '../dto/log/operation_log_dto.dart';
import '../dto/log/ssh_log_dto.dart';
import '../dto/log/task_log_dto.dart';

/// 日志审计 API。
///
/// 对应 1Panel Core `/core/logs` 和 Agent `/logs`、`/hosts/ssh` 相关接口。
class LogApi {
  LogApi(this._client);

  final DioClient _client;

  /// 分页查询操作日志。
  /// POST /api/v2/core/logs/operation
  Future<PageResult<OperationLogDto>> searchOperationLogs({
    int page = 1,
    int pageSize = 20,
    String source = '',
    String status = '',
    String node = '',
    String operation = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/logs/operation',
      data: {
        'page': page,
        'pageSize': pageSize,
        if (source.isNotEmpty) 'source': source,
        if (status.isNotEmpty) 'status': status,
        if (node.isNotEmpty) 'node': node,
        if (operation.isNotEmpty) 'operation': operation,
      },
    );
    return PageResult<OperationLogDto>.fromJson(
      ApiResponseParser.map(resp),
      OperationLogDto.fromJson,
    );
  }

  /// 分页查询登录日志。
  /// POST /api/v2/core/logs/login
  Future<PageResult<LoginLogDto>> searchLoginLogs({
    int page = 1,
    int pageSize = 20,
    String ip = '',
    String status = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/logs/login',
      data: {
        'page': page,
        'pageSize': pageSize,
        if (ip.isNotEmpty) 'ip': ip,
        if (status.isNotEmpty) 'status': status,
      },
    );
    return PageResult<LoginLogDto>.fromJson(
      ApiResponseParser.map(resp),
      LoginLogDto.fromJson,
    );
  }

  /// 清空日志（操作日志或登录日志）。
  /// POST /api/v2/core/logs/clean
  Future<void> cleanLogs(String logType) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/core/logs/clean',
      data: {'logType': logType},
    );
  }

  /// 获取系统日志文件列表。
  /// GET /api/v2/logs/system/files
  Future<List<String>> getSystemLogFiles() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/logs/system/files',
    );
    final data = resp.data?['data'];
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// 分页查询任务日志。
  /// POST /api/v2/logs/tasks/search
  Future<PageResult<TaskLogDto>> searchTaskLogs({
    int page = 1,
    int pageSize = 20,
    String status = '',
    String type = '',
    String taskID = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/logs/tasks/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        if (status.isNotEmpty) 'status': status,
        if (type.isNotEmpty) 'type': type,
        if (taskID.isNotEmpty) 'taskID': taskID,
      },
    );
    return PageResult<TaskLogDto>.fromJson(
      ApiResponseParser.map(resp),
      TaskLogDto.fromJson,
    );
  }

  /// 获取当前正在执行的任务数量。
  ///
  /// Compatibility: 1Panel v2.0.0 task log data may omit taskStatus, so callers
  /// can use this as a coarse fallback for whether any task is still running.
  Future<int> getExecutingTaskCount() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/logs/tasks/executing/count',
    );
    final data = resp.data?['data'];
    return data is num ? data.toInt() : 0;
  }

  /// 分页查询 SSH 登录日志。
  /// POST /api/v2/hosts/ssh/log
  Future<PageResult<SshLogDto>> searchSshLogs({
    int page = 1,
    int pageSize = 20,
    String info = '',
    String status = 'All',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/log',
      data: {
        'page': page,
        'pageSize': pageSize,
        if (info.isNotEmpty) 'info': info,
        'Status': status,
      },
    );
    return PageResult<SshLogDto>.fromJson(
      ApiResponseParser.map(resp),
      SshLogDto.fromJson,
    );
  }

  /// 导出 SSH 登录日志。
  /// POST /api/v2/hosts/ssh/log/export
  ///
  /// 返回服务端临时 CSV 文件路径。
  Future<String> exportSshLogs({
    String info = '',
    String status = 'All',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/log/export',
      data: {if (info.isNotEmpty) 'info': info, 'Status': status},
    );
    return ApiResponseParser.primitive<String>(resp);
  }
}
