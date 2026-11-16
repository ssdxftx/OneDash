import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/dashboard_api.dart';
import '../api/host_api.dart';

part 'dashboard_repository_impl.g.dart';

/// [DashboardRepository] 的默认实现。
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._dashboardApi, this._hostApi);

  final DashboardApi _dashboardApi;
  final HostApi _hostApi;

  @override
  Future<Dashboard> getDashboard({
    required String ioOption,
    required String netOption,
  }) => _dashboardApi.getDashboard(ioOption: ioOption, netOption: netOption);

  @override
  Future<Dashboard> getDashboardSnapshot({
    required String ioOption,
    required String netOption,
  }) => _dashboardApi.getDashboardSnapshot(
    ioOption: ioOption,
    netOption: netOption,
  );

  @override
  Future<DashboardBase> getDashboardBase({
    required String ioOption,
    required String netOption,
  }) =>
      _dashboardApi.getDashboardBase(ioOption: ioOption, netOption: netOption);

  @override
  Future<DashboardCurrent> getDashboardCurrent({
    required String ioOption,
    required String netOption,
  }) => _dashboardApi.getDashboardCurrent(
    ioOption: ioOption,
    netOption: netOption,
  );

  @override
  Future<void> restartSystem(String operation) =>
      _dashboardApi.restartSystem(operation);
  @override
  Future<List<Map<String, dynamic>>> getQuickOptions() =>
      _dashboardApi.getQuickOptions();

  @override
  Future<void> changeQuick(List<Map<String, dynamic>> quicks) =>
      _dashboardApi.changeQuick(quicks);

  @override
  Future<List<Map<String, dynamic>>> getQuickDirectories() =>
      _dashboardApi.getQuickDirectories();

  @override
  Future<void> createQuickDirectory({
    required String path,
    String alias = '',
  }) => _dashboardApi.createQuickDirectory(path: path, alias: alias);

  @override
  Future<void> updateQuickDirectory({
    required int id,
    required String path,
    String alias = '',
    bool legacy = false,
  }) => _dashboardApi.updateQuickDirectory(
    id: id,
    path: path,
    alias: alias,
    legacy: legacy,
  );

  @override
  Future<void> deleteQuickDirectory({required int id, bool legacy = false}) =>
      _dashboardApi.deleteQuickDirectory(id: id, legacy: legacy);

  @override
  Future<List<Map<String, dynamic>>> getAppLauncher() =>
      _dashboardApi.getAppLauncher();

  @override
  Future<List<Map<String, dynamic>>> getAppLauncherOptions({
    String filter = '',
  }) => _dashboardApi.getAppLauncherOptions(filter: filter);

  @override
  Future<void> updateAppLauncherShow({
    required String key,
    required bool show,
  }) => _dashboardApi.updateAppLauncherShow(key: key, show: show);

  @override
  Future<List<Map<String, dynamic>>> getTopCpu() => _dashboardApi.getTopCpu();

  @override
  Future<List<Map<String, dynamic>>> getTopMem() => _dashboardApi.getTopMem();

  @override
  Future<Map<String, dynamic>> getNodeCurrent() =>
      _dashboardApi.getNodeCurrent();

  @override
  Future<List<String>> getMonitorIoOptions() => _hostApi.getMonitorIoOptions();

  @override
  Future<List<String>> getMonitorNetOptions() =>
      _hostApi.getMonitorNetOptions();
}

/// 基于当前激活服务器的仓库 Provider。
@Riverpod()
Future<DashboardRepository> dashboardRepository(Ref ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return DashboardRepositoryImpl(DashboardApi(client), HostApi(client));
}
