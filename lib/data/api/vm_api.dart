import '../../core/network/api_response_parser.dart';
import '../dto/common/page_result.dart';
import '../../core/network/dio_client.dart';
import 'task_waiter.dart';

/// 虚拟机 API，对应 1Panel `/vms` 路由。
class VmApi {
  VmApi(this._client);

  final DioClient _client;

  Future<Map<String, dynamic>> checkEnvironment() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/vms/environment',
    );
    return ApiResponseParser.map(resp);
  }

  Future<void> enableEnvironment() async {
    await _client.post<Map<String, dynamic>>('/api/v2/vms/environment/enable');
  }

  Future<Map<String, dynamic>> searchVms({
    int page = 1,
    int pageSize = 100,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/search',
      data: {'page': page, 'pageSize': pageSize},
    );
    return ApiResponseParser.map(resp);
  }

  Future<void> syncVms() async {
    await _client.post<Map<String, dynamic>>('/api/v2/vms/sync');
  }

  Future<Map<String, dynamic>> getVm(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/info',
      data: {'name': name, 'checkDisks': true},
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> getVmConsole(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/console',
      data: {'name': name},
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> getVmStats(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/stats',
      data: {'name': name},
    );
    return ApiResponseParser.map(resp);
  }

  Future<void> createVm(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms',
      data: body,
    );
    await _awaitTask(
      ApiResponseParser.map(resp),
      taskID: '${body['taskID'] ?? ''}',
    );
  }

  Future<void> updateVm(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/update',
      data: body,
    );
    await _awaitTask(
      ApiResponseParser.map(resp),
      taskID: '${body['taskID'] ?? ''}',
    );
  }

  Future<void> renameVm({
    required String name,
    required String newName,
    required String taskID,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/rename',
      data: {'name': name, 'newName': newName, 'taskID': taskID},
    );
    await _awaitTask(ApiResponseParser.map(resp), taskID: taskID);
  }

  Future<void> deleteVm({
    required int id,
    bool force = false,
    required String taskID,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/del',
      data: {'id': id, 'force': force, 'taskID': taskID},
    );
    await _awaitTask(ApiResponseParser.map(resp), taskID: taskID);
  }

  Future<void> operateVm(String name, String operate) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/operate',
      data: {'name': name, 'operate': operate},
    );
  }

  Future<List<Map<String, dynamic>>> listSnapshots(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/snapshots/list',
      data: {'name': name},
    );
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<void> createSnapshot({
    required String name,
    required String snapshotName,
    String description = '',
    required String taskID,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/snapshots',
      data: {
        'name': name,
        'snapshotName': snapshotName,
        'description': description,
        'taskID': taskID,
      },
    );
    await _awaitTask(ApiResponseParser.map(resp), taskID: taskID);
  }

  Future<void> recoverSnapshot({
    required String name,
    required String snapshotName,
    required String taskID,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/snapshots/recover',
      data: {'name': name, 'snapshotName': snapshotName, 'taskID': taskID},
    );
    await _awaitTask(ApiResponseParser.map(resp), taskID: taskID);
  }

  Future<void> deleteSnapshot({
    required String name,
    required String snapshotName,
    required String taskID,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/snapshots/del',
      data: {'name': name, 'snapshotName': snapshotName, 'taskID': taskID},
    );
    await _awaitTask(ApiResponseParser.map(resp), taskID: taskID);
  }

  Future<List<Map<String, dynamic>>> listIsos() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/iso/list',
      data: const {},
    );
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<PageResult<Map<String, dynamic>>> searchIsos({
    int page = 1,
    int pageSize = 100,
    String info = '',
    String type = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/iso/search',
      data: {'page': page, 'pageSize': pageSize, 'info': info, 'type': type},
    );
    return PageResult<Map<String, dynamic>>.fromJson(
      ApiResponseParser.map(resp),
      (json) => json,
    );
  }

  Future<int> startIsoImport(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/iso/import/start',
      data: body,
    );
    final data = resp.data?['data'];
    return data is Map ? (data['id'] as num?)?.toInt() ?? 0 : 0;
  }

  Future<void> updateIsoImport(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/iso/import/update',
      data: body,
    );
  }

  Future<List<Map<String, dynamic>>> listNetworkInterfaces() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/vms/networks/interfaces',
    );
    return ApiResponseParser.list(resp, (json) => json);
  }

  Future<void> createIso(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>('/api/v2/vms/iso', data: body);
  }

  Future<void> updateIso(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/iso/update',
      data: body,
    );
  }

  Future<void> deleteIso(int id, {bool deleteFile = false}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/iso/del',
      data: {'id': id, 'deleteFile': deleteFile},
    );
  }

  Future<Map<String, dynamic>> resizeDisk({
    required String name,
    required String target,
    required int sizeGiB,
    String taskID = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/disks/resize',
      data: {
        'name': name,
        'target': target,
        'sizeGiB': sizeGiB,
        'taskID': taskID,
      },
    );
    final data = ApiResponseParser.map(resp);
    await _awaitTask(data, taskID: taskID);
    return data;
  }

  Future<Map<String, dynamic>> healthCheck(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/health/check',
      data: {'name': name},
    );
    return ApiResponseParser.map(resp);
  }

  Future<List<Map<String, dynamic>>> scanOrphans() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/orphans/scan',
    );
    return ApiResponseParser.list(resp, (json) => json);
  }

  Future<List<Map<String, dynamic>>> cleanOrphans(
    List<Map<String, dynamic>> items,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/orphans/clean',
      data: {'items': items},
    );
    return ApiResponseParser.list(resp, (json) => json);
  }

  Future<void> createTemplate(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/templates',
      data: body,
    );
    await _awaitTask(ApiResponseParser.map(resp));
  }

  Future<void> deleteTemplate(int id, {bool deleteDisk = false}) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/templates/del',
      data: {'id': id, 'deleteDisk': deleteDisk},
    );
    await _awaitTask(ApiResponseParser.map(resp));
  }

  Future<void> createNetwork(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/networks',
      data: body,
    );
  }

  Future<void> updateNetwork(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/networks/update',
      data: body,
    );
  }

  Future<void> deleteNetwork(int id, {bool force = false}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/networks/del',
      data: {'id': id, 'force': force},
    );
  }

  Future<void> createStorage(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/storages',
      data: body,
    );
  }

  Future<void> updateStorage(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/storages/update',
      data: body,
    );
  }

  Future<void> deleteStorage(int id, {bool force = false}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/storages/del',
      data: {'id': id, 'force': force},
    );
  }

  Future<List<Map<String, dynamic>>> listTemplates() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/templates/list',
      data: const {},
    );
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<List<Map<String, dynamic>>> listNetworks() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/networks/list',
      data: const {},
    );
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<List<Map<String, dynamic>>> listNetworkBridges() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/vms/networks/bridges',
    );
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<List<Map<String, dynamic>>> listStorages() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/vms/storages/list',
      data: const {},
    );
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<void> _awaitTask(
    Map<String, dynamic> resp, {
    String taskID = '',
  }) async {
    final resolved = taskID.isNotEmpty ? taskID : '${resp['taskID'] ?? ''}';
    if (resolved.isEmpty) return;
    await TaskWaiter(
      _client,
      interval: const Duration(seconds: 2),
      maxAttempts: 900,
    ).waitFor(resolved, subject: 'VM task');
  }

  static Map<String, dynamic> _mapOf(Map<dynamic, dynamic> value) =>
      value.cast<String, dynamic>();
}
