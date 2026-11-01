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
