import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../dto/common/page_result.dart';
import '../../domain/repositories/vm_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/vm_api.dart';

class VmRepositoryImpl implements VmRepository {
  VmRepositoryImpl(this._api);

  final VmApi _api;

  @override
  Future<Map<String, dynamic>> checkEnvironment() => _api.checkEnvironment();

  @override
  Future<void> enableEnvironment() => _api.enableEnvironment();

  @override
  Future<Map<String, dynamic>> searchVms({int page = 1, int pageSize = 100}) =>
      _api.searchVms(page: page, pageSize: pageSize);

  @override
  Future<void> syncVms() => _api.syncVms();

  @override
  Future<Map<String, dynamic>> getVm(String name) => _api.getVm(name);

  @override
  Future<Map<String, dynamic>> getVmStats(String name) => _api.getVmStats(name);

  @override
  Future<void> createVm(Map<String, dynamic> body) => _api.createVm(body);

  @override
  Future<void> updateVm(Map<String, dynamic> body) => _api.updateVm(body);

  @override
  Future<void> renameVm({
    required String name,
    required String newName,
    required String taskID,
  }) => _api.renameVm(name: name, newName: newName, taskID: taskID);

  @override
  Future<void> deleteVm({
    required int id,
    bool force = false,
    required String taskID,
  }) => _api.deleteVm(id: id, force: force, taskID: taskID);

  @override
  Future<void> operateVm(String name, String operate) =>
      _api.operateVm(name, operate);

  @override
  Future<List<Map<String, dynamic>>> listSnapshots(String name) =>
      _api.listSnapshots(name);

  @override
  Future<void> createSnapshot({
    required String name,
    required String snapshotName,
    String description = '',
    required String taskID,
  }) => _api.createSnapshot(
    name: name,
    snapshotName: snapshotName,
    description: description,
    taskID: taskID,
  );

  @override
  Future<void> recoverSnapshot({
    required String name,
    required String snapshotName,
    required String taskID,
  }) => _api.recoverSnapshot(
    name: name,
    snapshotName: snapshotName,
    taskID: taskID,
  );

  @override
  Future<void> deleteSnapshot({
    required String name,
    required String snapshotName,
    required String taskID,
  }) => _api.deleteSnapshot(
    name: name,
    snapshotName: snapshotName,
    taskID: taskID,
  );

  @override
  Future<List<Map<String, dynamic>>> listIsos() => _api.listIsos();

  @override
  Future<PageResult<Map<String, dynamic>>> searchIsos({
    int page = 1,
    int pageSize = 100,
    String info = '',
    String type = '',
  }) => _api.searchIsos(page: page, pageSize: pageSize, info: info, type: type);

  @override
  Future<int> startIsoImport(Map<String, dynamic> body) =>
      _api.startIsoImport(body);

  @override
  Future<void> updateIsoImport(Map<String, dynamic> body) =>
      _api.updateIsoImport(body);

  @override
  Future<List<Map<String, dynamic>>> listNetworkInterfaces() =>
      _api.listNetworkInterfaces();

  @override
  Future<void> createIso(Map<String, dynamic> body) => _api.createIso(body);

  @override
  Future<void> updateIso(Map<String, dynamic> body) => _api.updateIso(body);

  @override
  Future<void> deleteIso(int id, {bool deleteFile = false}) =>
      _api.deleteIso(id, deleteFile: deleteFile);

  @override
  Future<Map<String, dynamic>> resizeDisk({
    required String name,
    required String target,
    required int sizeGiB,
    String taskID = '',
  }) => _api.resizeDisk(
    name: name,
    target: target,
    sizeGiB: sizeGiB,
    taskID: taskID,
  );

  @override
  Future<Map<String, dynamic>> healthCheck(String name) =>
      _api.healthCheck(name);

  @override
  Future<List<Map<String, dynamic>>> scanOrphans() => _api.scanOrphans();

  @override
  Future<List<Map<String, dynamic>>> cleanOrphans(
    List<Map<String, dynamic>> items,
  ) => _api.cleanOrphans(items);

  @override
  Future<void> createTemplate(Map<String, dynamic> body) =>
      _api.createTemplate(body);

  @override
  Future<void> deleteTemplate(int id, {bool deleteDisk = false}) =>
      _api.deleteTemplate(id, deleteDisk: deleteDisk);

  @override
  Future<void> createNetwork(Map<String, dynamic> body) =>
      _api.createNetwork(body);

  @override
  Future<void> updateNetwork(Map<String, dynamic> body) =>
      _api.updateNetwork(body);

  @override
  Future<void> deleteNetwork(int id, {bool force = false}) =>
      _api.deleteNetwork(id, force: force);

  @override
  Future<void> createStorage(Map<String, dynamic> body) =>
      _api.createStorage(body);

  @override
  Future<void> updateStorage(Map<String, dynamic> body) =>
      _api.updateStorage(body);

  @override
  Future<void> deleteStorage(int id, {bool force = false}) =>
      _api.deleteStorage(id, force: force);

  @override
  Future<List<Map<String, dynamic>>> listTemplates() => _api.listTemplates();

  @override
  Future<List<Map<String, dynamic>>> listNetworks() => _api.listNetworks();

  @override
  Future<List<Map<String, dynamic>>> listNetworkBridges() =>
      _api.listNetworkBridges();

  @override
  Future<List<Map<String, dynamic>>> listStorages() => _api.listStorages();
}

final vmRepositoryProvider = FutureProvider<VmRepository>((ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return VmRepositoryImpl(VmApi(client));
}, dependencies: [activeServerIdProvider]);
