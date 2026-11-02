import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/server.dart';
import '../../domain/repositories/setting_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/setting_api.dart';

part 'setting_repository_impl.g.dart';

/// [SettingRepository] 的默认实现。
class SettingRepositoryImpl implements SettingRepository {
  SettingRepositoryImpl(this._settingApi, {required Server server})
    : _server = server;

  final SettingApi _settingApi;
  final Server _server;

  @override
  Future<String> getBaseDir() => _settingApi.getBaseDir();

  @override
  Future<void> updateSetting({required String key, required String value}) =>
      _settingApi.updateSetting(key: key, value: value);

  @override
  Future<Map<String, dynamic>> searchSettings() => _settingApi.searchSettings();

  @override
  Future<String> getSystemIP() => _settingApi.getSystemIP();

  @override
  String getServerHost() => _server.host;

  @override
  Future<Map<String, dynamic>> searchCoreSettings() =>
      _settingApi.searchCoreSettings();

  @override
  Future<void> updateCoreSetting({
    required String key,
    required String value,
  }) => _settingApi.updateCoreSetting(key: key, value: value);

  @override
  Future<void> saveDescription({
    required String id,
    required String type,
    String detailType = '',
    required bool isPinned,
    required String description,
  }) => _settingApi.saveDescription(
    id: id,
    type: type,
    detailType: detailType,
    isPinned: isPinned,
    description: description,
  );

  @override
  Future<void> saveMemo(String content) => _settingApi.saveMemo(content);

  @override
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) => _settingApi.updatePassword(
    oldPassword: oldPassword,
    newPassword: newPassword,
  );

  @override
  Future<void> updatePort(int serverPort) => _settingApi.updatePort(serverPort);

  @override
  Future<List<String>> loadInterfaceAddr() => _settingApi.loadInterfaceAddr();

  @override
  Future<void> updateBindInfo({
    required String ipv6,
    required String bindAddress,
  }) => _settingApi.updateBindInfo(ipv6: ipv6, bindAddress: bindAddress);

  @override
  Future<void> updateSSL(Map<String, dynamic> data) =>
      _settingApi.updateSSL(data);

  @override
  Future<Map<String, dynamic>> loadSSLInfo() => _settingApi.loadSSLInfo();

  @override
  Future<Map<String, dynamic>> loadMFA({
    required String title,
    required int interval,
  }) => _settingApi.loadMFA(title: title, interval: interval);

  @override
  Future<void> bindMFA({
    required String secret,
    required String code,
    required String interval,
  }) => _settingApi.bindMFA(secret: secret, code: code, interval: interval);

  @override
  Future<List<Map<String, dynamic>>> listPasskeys() =>
      _settingApi.listPasskeys();

  @override
  Future<void> deletePasskey(int id) => _settingApi.deletePasskey(id);

  @override
  Future<String> generateApiKey() => _settingApi.generateApiKey();

  @override
  Future<void> updateApiConfig(Map<String, dynamic> config) =>
      _settingApi.updateApiConfig(config);

  @override
  Future<void> createSnapshot(Map<String, dynamic> data) =>
      _settingApi.createSnapshot(data);

  @override
  Future<void> importSnapshot(Map<String, dynamic> data) =>
      _settingApi.importSnapshot(data);

  @override
  Future<Map<String, dynamic>> searchSnapshots({
    required int page,
    required int pageSize,
    String info = '',
    String orderBy = 'createdAt',
    String order = 'null',
  }) => _settingApi.searchSnapshots(
    page: page,
    pageSize: pageSize,
    info: info,
    orderBy: orderBy,
    order: order,
  );

  @override
  Future<Map<String, dynamic>> loadSnapshotData() =>
      _settingApi.loadSnapshotData();

  @override
  Future<void> deleteSnapshots({
    required List<int> ids,
    bool deleteWithFile = false,
  }) => _settingApi.deleteSnapshots(ids: ids, deleteWithFile: deleteWithFile);

  @override
  Future<void> recoverSnapshot({
    required int id,
    bool isNew = false,
    bool reDownload = false,
    String taskID = '',
    String secret = '',
  }) => _settingApi.recoverSnapshot(
    id: id,
    isNew: isNew,
    reDownload: reDownload,
    taskID: taskID,
    secret: secret,
  );

  @override
  Future<void> rollbackSnapshot({
    required int id,
    String taskID = '',
    String secret = '',
  }) => _settingApi.rollbackSnapshot(id: id, taskID: taskID, secret: secret);

  @override
  Future<void> recreateSnapshot(int id) => _settingApi.recreateSnapshot(id);

  @override
  Future<void> updateSnapshotDescription(int id, String description) =>
      _settingApi.updateSnapshotDescription(id, description);
}

/// 基于当前激活服务器的设置仓库 Provider。
@Riverpod()
Future<SettingRepository> settingRepository(Ref ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  final storage = ref.watch(storageServiceProvider);
  final server = await storage.getServer(serverId);
  if (server == null) throw StateError('服务器不存在: $serverId');
  return SettingRepositoryImpl(SettingApi(client), server: server);
}
