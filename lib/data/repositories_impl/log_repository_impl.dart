import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/log_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/log_api.dart';
import '../dto/common/page_result.dart';
import '../dto/log/login_log_dto.dart';
import '../dto/log/operation_log_dto.dart';
import '../dto/log/ssh_log_dto.dart';
import '../dto/log/task_log_dto.dart';

part 'log_repository_impl.g.dart';

/// [LogRepository] 的默认实现。
class LogRepositoryImpl implements LogRepository {
  LogRepositoryImpl(this._api);

  final LogApi _api;

  @override
  Future<PageResult<OperationLogDto>> searchOperationLogs({
    int page = 1,
    int pageSize = 20,
    String source = '',
    String status = '',
    String node = '',
    String operation = '',
  }) => _api.searchOperationLogs(
    page: page,
    pageSize: pageSize,
    source: source,
    status: status,
    node: node,
    operation: operation,
  );

  @override
  Future<PageResult<LoginLogDto>> searchLoginLogs({
    int page = 1,
    int pageSize = 20,
    String ip = '',
    String status = '',
  }) => _api.searchLoginLogs(
    page: page,
    pageSize: pageSize,
    ip: ip,
    status: status,
  );

  @override
  Future<void> cleanLogs(String logType) => _api.cleanLogs(logType);

  @override
  Future<List<String>> getSystemLogFiles() => _api.getSystemLogFiles();

  @override
  Future<PageResult<TaskLogDto>> searchTaskLogs({
    int page = 1,
    int pageSize = 20,
    String status = '',
    String type = '',
    String taskID = '',
  }) => _api.searchTaskLogs(
    page: page,
    pageSize: pageSize,
    status: status,
    type: type,
    taskID: taskID,
  );

  @override
  Future<PageResult<SshLogDto>> searchSshLogs({
    int page = 1,
    int pageSize = 20,
    String info = '',
    String status = 'All',
  }) => _api.searchSshLogs(
    page: page,
    pageSize: pageSize,
    info: info,
    status: status,
  );

  @override
  Future<String> exportSshLogs({String info = '', String status = 'All'}) =>
      _api.exportSshLogs(info: info, status: status);
}

/// 基于当前激活服务器的日志仓库 Provider。
@Riverpod()
Future<LogRepository> logRepository(Ref ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return LogRepositoryImpl(LogApi(client));
}
