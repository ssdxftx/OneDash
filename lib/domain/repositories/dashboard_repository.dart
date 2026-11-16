import '../entities/dashboard.dart';

/// 仪表盘仓库抽象。
abstract class DashboardRepository {
  Future<Dashboard> getDashboard({
    required String ioOption,
    required String netOption,
  });

  Future<Dashboard> getDashboardSnapshot({
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

  Future<void> restartSystem(String operation);

  Future<List<Map<String, dynamic>>> getQuickOptions();
  Future<void> changeQuick(List<Map<String, dynamic>> quicks);
  Future<List<Map<String, dynamic>>> getQuickDirectories();
  Future<void> createQuickDirectory({required String path, String alias});
  Future<void> updateQuickDirectory({
    required int id,
    required String path,
    String alias,
    bool legacy,
  });
  Future<void> deleteQuickDirectory({required int id, bool legacy});
  Future<List<Map<String, dynamic>>> getAppLauncher();
  Future<List<Map<String, dynamic>>> getAppLauncherOptions({String filter});
  Future<void> updateAppLauncherShow({required String key, required bool show});
  Future<List<Map<String, dynamic>>> getTopCpu();
  Future<List<Map<String, dynamic>>> getTopMem();
  Future<Map<String, dynamic>> getNodeCurrent();

  Future<List<String>> getMonitorIoOptions();

  Future<List<String>> getMonitorNetOptions();
}
