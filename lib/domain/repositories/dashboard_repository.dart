import '../entities/dashboard.dart';

/// 仪表盘仓库抽象。
abstract class DashboardRepository {
  Future<Dashboard> getDashboard({
    required String ioOption,
    required String netOption,
  });

  Future<DashboardBase> getDashboardBase({
    required String ioOption,
    required String netOption,
  });

  Future<DashboardCurrent> getDashboardCurrent({
    required String ioOption,
    required String netOption,
  });

  Future<List<String>> getMonitorIoOptions();

  Future<List<String>> getMonitorNetOptions();
}
