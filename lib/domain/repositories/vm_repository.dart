import '../../data/dto/common/page_result.dart';

abstract interface class VmRepository {
  Future<Map<String, dynamic>> checkEnvironment();
  Future<void> enableEnvironment();
  Future<Map<String, dynamic>> searchVms({int page, int pageSize});
  Future<void> syncVms();
  Future<Map<String, dynamic>> getVm(String name);
  Future<Map<String, dynamic>> getVmStats(String name);
  Future<void> createVm(Map<String, dynamic> body);
  Future<void> updateVm(Map<String, dynamic> body);
  Future<void> renameVm({
    required String name,
    required String newName,
    required String taskID,
  });
  Future<void> deleteVm({required int id, bool force, required String taskID});
  Future<void> operateVm(String name, String operate);
  Future<List<Map<String, dynamic>>> listSnapshots(String name);
  Future<void> createSnapshot({
    required String name,
    required String snapshotName,
    String description,
    required String taskID,
  });
  Future<void> recoverSnapshot({
    required String name,
    required String snapshotName,
    required String taskID,
  });
  Future<void> deleteSnapshot({
    required String name,
    required String snapshotName,
    required String taskID,
  });
  Future<List<Map<String, dynamic>>> listIsos();
  Future<PageResult<Map<String, dynamic>>> searchIsos({
    int page,
    int pageSize,
    String info,
    String type,
  });
  Future<int> startIsoImport(Map<String, dynamic> body);
  Future<void> updateIsoImport(Map<String, dynamic> body);
  Future<List<Map<String, dynamic>>> listNetworkInterfaces();
  Future<void> createIso(Map<String, dynamic> body);
  Future<void> updateIso(Map<String, dynamic> body);
  Future<void> deleteIso(int id, {bool deleteFile});
  Future<Map<String, dynamic>> resizeDisk({
    required String name,
    required String target,
    required int sizeGiB,
    String taskID,
  });
  Future<Map<String, dynamic>> healthCheck(String name);
  Future<List<Map<String, dynamic>>> scanOrphans();
  Future<List<Map<String, dynamic>>> cleanOrphans(
    List<Map<String, dynamic>> items,
  );
  Future<void> createTemplate(Map<String, dynamic> body);
  Future<void> deleteTemplate(int id, {bool deleteDisk});
  Future<void> createNetwork(Map<String, dynamic> body);
  Future<void> updateNetwork(Map<String, dynamic> body);
  Future<void> deleteNetwork(int id, {bool force});
  Future<void> createStorage(Map<String, dynamic> body);
  Future<void> updateStorage(Map<String, dynamic> body);
  Future<void> deleteStorage(int id, {bool force});
  Future<List<Map<String, dynamic>>> listTemplates();
  Future<List<Map<String, dynamic>>> listNetworks();
  Future<List<Map<String, dynamic>>> listNetworkBridges();
  Future<List<Map<String, dynamic>>> listStorages();
}
