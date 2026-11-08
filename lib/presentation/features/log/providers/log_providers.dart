import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories_impl/log_repository_impl.dart';
import '../models/login_log_item.dart';
import '../models/operation_log_item.dart';
import '../models/ssh_log_item.dart';
import '../models/task_log_item.dart';

final operationLogsProvider =
    FutureProvider.autoDispose<List<OperationLogItem>>((ref) async {
      final repository = await ref.watch(logRepositoryProvider.future);
      final page = await repository.searchOperationLogs(
        page: 1,
        pageSize: 50,
        source: '',
        status: '',
        node: '',
        operation: '',
      );
      return page.items.map(OperationLogItem.fromDto).toList(growable: false);
    }, name: 'operationLogsProvider');

final loginLogsProvider = FutureProvider.autoDispose<List<LoginLogItem>>((
  ref,
) async {
  final repository = await ref.watch(logRepositoryProvider.future);
  final page = await repository.searchLoginLogs(
    page: 1,
    pageSize: 50,
    ip: '',
    status: '',
  );
  return page.items.map(LoginLogItem.fromDto).toList(growable: false);
}, name: 'loginLogsProvider');

final sshLogsProvider = FutureProvider.autoDispose<List<SshLogItem>>((
  ref,
) async {
  final repository = await ref.watch(logRepositoryProvider.future);
  final page = await repository.searchSshLogs(
    page: 1,
    pageSize: 50,
    info: '',
    status: 'All',
  );
  return page.items.map(SshLogItem.fromDto).toList(growable: false);
}, name: 'sshLogsProvider');

final taskLogsProvider = FutureProvider.autoDispose<List<TaskLogItem>>((
  ref,
) async {
  final repository = await ref.watch(logRepositoryProvider.future);
  final page = await repository.searchTaskLogs(
    page: 1,
    pageSize: 50,
    status: '',
    type: '',
    taskID: '',
  );
  return page.items.map(TaskLogItem.fromDto).toList(growable: false);
}, name: 'taskLogsProvider');
