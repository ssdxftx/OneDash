import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../core/network/network_exceptions.dart';
import '../../core/network/panel_session.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/server.dart';
import '../../domain/repositories/setting_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/setting_api.dart';
import '../dto/common/page_result.dart';
import '../dto/setting/api_key_dto.dart';
import '../dto/setting/script_library_dto.dart';
import '../dto/setting/command_library_dto.dart';
import '../dto/setting/group_dto.dart';
import '../dto/setting/passkey_dto.dart';

part 'setting_repository_impl.g.dart';

/// [SettingRepository] 的默认实现。
class SettingRepositoryImpl implements SettingRepository {
  SettingRepositoryImpl(
    this._settingApi,
    this._storage, {
    required Server server,
  }) : _server = server;

  final SettingApi _settingApi;
  final StorageService _storage;
  final Server _server;

  @override
  Future<String> getBaseDir() => _settingApi.getBaseDir();

  @override
  Future<bool> getFileDownloadPreference() =>
      _settingApi.getFileDownloadPreference();

  @override
  Future<void> updateFileDownloadPreference({
    required bool useServerFilename,
  }) => _settingApi.updateFileDownloadPreference(
    useServerFilename: useServerFilename,
  );

  @override
  Future<Uint8List> downloadPanelSsl() => _settingApi.downloadPanelSsl();

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
  Future<bool> hasPanelSession() async =>
      await _storage.getPanelSession(_server.id) != null;

  @override
  Future<Map<String, dynamic>> getLoginSetting() =>
      _settingApi.getLoginSetting();

  @override
  Future<Map<String, dynamic>> loadLoginCaptcha() =>
      _settingApi.loadLoginCaptcha();

  @override
  Future<PanelLoginResult> loginPanel({
    required String name,
    required String password,
    required String language,
    String captcha = '',
    String captchaId = '',
    String entrance = '',
  }) async {
    final result = await _settingApi.loginPanel(
      name: name,
      password: password,
      language: language,
      captcha: captcha,
      captchaId: captchaId,
      entrance: entrance,
    );
    if (result.session != null && !result.needsMfa) {
      await _storage.savePanelSession(_server.id, result.session!);
    }
    return result;
  }

  @override
  Future<PanelLoginResult> loginPanelMfa({
    required String sessionId,
    required String code,
  }) async {
    final result = await _settingApi.loginPanelMfa(
      sessionId: sessionId,
      code: code,
    );
    if (result.session != null) {
      await _storage.savePanelSession(_server.id, result.session!);
    }
    return result;
  }

  @override
  Future<void> logoutPanel() async {
    try {
      await _settingApi.logoutPanel();
    } finally {
      await _storage.clearPanelSession(_server.id);
    }
  }

  @override
  Future<void> updatePanelProxy({
    required String proxyUrl,
    required String proxyType,
    required String proxyPort,
    String proxyUser = '',
    String proxyPasswd = '',
    bool proxyPasswdKeep = false,
    bool proxyDocker = false,
    bool withDockerRestart = false,
  }) => _settingApi.updatePanelProxy(
    proxyUrl: proxyUrl,
    proxyType: proxyType,
    proxyPort: proxyPort,
    proxyUser: proxyUser,
    proxyPasswd: proxyPasswd,
    proxyPasswdKeep: proxyPasswdKeep,
    proxyDocker: proxyDocker,
    withDockerRestart: withDockerRestart,
  );

  @override
  Future<void> updateCoreSetting({
    required String key,
    required String value,
  }) => _settingApi.updateCoreSetting(key: key, value: value);

  @override
  Future<String> getMemo() => _settingApi.getMemo();

  @override
  Future<Map<String, dynamic>> getTerminalAppearanceSettings() =>
      _settingApi.getTerminalAppearanceSettings();

  @override
  Future<void> updateTerminalAppearanceSettings(Map<String, String> data) =>
      _settingApi.updateTerminalAppearanceSettings(data);

  @override
  Future<Map<String, dynamic>> getTerminalAiSetting() =>
      _settingApi.getTerminalAiSetting();

  @override
  Future<void> updateTerminalAiSetting({
    required String aiStatus,
    required String aiPrefix,
    String aiAccountId = '',
    String aiRiskCommands = '',
  }) => _settingApi.updateTerminalAiSetting(
    aiStatus: aiStatus,
    aiPrefix: aiPrefix,
    aiAccountId: aiAccountId,
    aiRiskCommands: aiRiskCommands,
  );

  @override
  Future<Map<String, dynamic>> getFileAiSetting() =>
      _settingApi.getFileAiSetting();

  @override
  Future<void> updateFileAiSetting({
    required String aiStatus,
    String aiAccountId = '',
  }) => _settingApi.updateFileAiSetting(
    aiStatus: aiStatus,
    aiAccountId: aiAccountId,
  );

  @override
  Future<Map<String, dynamic>> getFileHistorySetting() =>
      _settingApi.getFileHistorySetting();

  @override
  Future<void> updateFileHistorySetting({
    required String enable,
    required int maxPerPath,
    required int diskQuotaMB,
  }) => _settingApi.updateFileHistorySetting(
    enable: enable,
    maxPerPath: maxPerPath,
    diskQuotaMB: diskQuotaMB,
  );

  @override
  Future<Map<String, dynamic>> getLocalSshConn() =>
      _settingApi.getLocalSshConn();

  @override
  Future<void> saveLocalSshConn(Map<String, dynamic> data) =>
      _settingApi.saveLocalSshConn(data);

  @override
  Future<bool> checkLocalSshConn(Map<String, dynamic> data) =>
      _settingApi.checkLocalSshConn(data);

  @override
  Future<void> setSshDefaultConn({
    required String defaultConn,
    bool withReset = false,
  }) => _settingApi.setSshDefaultConn(
    defaultConn: defaultConn,
    withReset: withReset,
  );

  @override
  Future<void> resetMenuSetting() => _settingApi.resetMenuSetting();

  @override
  Future<void> updateMenuSetting(String value) =>
      _settingApi.updateMenuSetting(value);

  @override
  Future<Map<String, dynamic>> getUpgradeInfo() => _settingApi.getUpgradeInfo();

  @override
  Future<List<Map<String, dynamic>>> getUpgradeReleases() =>
      _settingApi.getUpgradeReleases();

  @override
  Future<String> getUpgradeNotes(String version) =>
      _settingApi.getUpgradeNotes(version);

  @override
  Future<void> upgradePanel(String version) =>
      _settingApi.upgradePanel(version);

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
  Future<List<CoreGroupDto>> searchGroups({required String type}) =>
      _settingApi.searchGroups(type: type);

  @override
  Future<void> createGroup({required String name, required String type}) =>
      _settingApi.createGroup(name: name, type: type);

  @override
  Future<void> updateGroup({
    required int id,
    required String name,
    required String type,
    bool isDefault = false,
  }) => _settingApi.updateGroup(
    id: id,
    name: name,
    type: type,
    isDefault: isDefault,
  );

  @override
  Future<void> deleteGroup(int id) => _settingApi.deleteGroup(id);

  @override
  Future<List<CommandTreeDto>> searchCommandTree({String type = 'command'}) =>
      _settingApi.searchCommandTree(type: type);

  @override
  Future<List<Map<String, dynamic>>> uploadCommandCsv({
    required Uint8List bytes,
    required String filename,
  }) => _settingApi.uploadCommandCsv(bytes: bytes, filename: filename);

  @override
  Future<void> importCommands(List<Map<String, dynamic>> items) =>
      _settingApi.importCommands(items);

  @override
  Future<String> exportCommands() => _settingApi.exportCommands();

  @override
  Future<PageResult<CommandLibraryDto>> searchCommands({
    String type = 'command',
    String info = '',
    int page = 1,
    int pageSize = 50,
    int groupID = 0,
    String orderBy = 'createdAt',
    String order = 'descending',
  }) => _settingApi.searchCommands(
    type: type,
    info: info,
    page: page,
    pageSize: pageSize,
    groupID: groupID,
    orderBy: orderBy,
    order: order,
  );

  @override
  Future<void> createCommand(Map<String, dynamic> data) =>
      _settingApi.createCommand(data);

  @override
  Future<void> updateCommand(Map<String, dynamic> data) =>
      _settingApi.updateCommand(data);

  @override
  Future<void> deleteCommands({
    required List<int> ids,
    String type = 'command',
  }) => _settingApi.deleteCommands(ids: ids, type: type);

  @override
  Future<PageResult<ScriptLibraryDto>> searchScripts({
    String info = '',
    int page = 1,
    int pageSize = 50,
    int groupID = 0,
  }) => _settingApi.searchScripts(
    info: info,
    page: page,
    pageSize: pageSize,
    groupID: groupID,
  );

  @override
  Future<void> createScript(Map<String, dynamic> data) =>
      _settingApi.createScript(data);

  @override
  Future<void> updateScript(Map<String, dynamic> data) =>
      _settingApi.updateScript(data);

  @override
  Future<void> deleteScripts(List<int> ids) => _settingApi.deleteScripts(ids);

  @override
  Future<void> syncScripts(String taskID) => _settingApi.syncScripts(taskID);

  @override
  Future<void> closeMFA() => _settingApi.closeMFA();

  @override
  Future<void> resetExpiredPassword({
    required String oldPassword,
    required String newPassword,
  }) => _settingApi.resetExpiredPassword(
    oldPassword: oldPassword,
    newPassword: newPassword,
  );

  @override
  Future<void> bindMFA({
    required String secret,
    required String code,
    required int interval,
  }) => _settingApi.bindMFA(secret: secret, code: code, interval: interval);

  @override
  Future<PasskeyChallenge> passkeyBeginLogin({String entrance = ''}) =>
      _settingApi.passkeyBeginLogin(entrance: entrance);

  @override
  Future<PanelLoginResult> passkeyFinishLogin({
    required Map<String, dynamic> payload,
    required String sessionId,
    String entrance = '',
  }) => _settingApi.passkeyFinishLogin(
    payload: payload,
    sessionId: sessionId,
    entrance: entrance,
  );

  @override
  Future<PasskeyChallenge> passkeyBeginRegister(String name) =>
      _settingApi.passkeyBeginRegister(name);

  @override
  Future<void> passkeyFinishRegister({
    required Map<String, dynamic> payload,
    required String sessionId,
  }) => _settingApi.passkeyFinishRegister(
    payload: payload,
    sessionId: sessionId,
  );

  @override
  Future<List<Map<String, dynamic>>> listPasskeys() =>
      _settingApi.listPasskeys();

  @override
  Future<void> deletePasskey(String id) => _settingApi.deletePasskey(id);

  @override
  Future<String> generateApiKey() => _settingApi.generateApiKey();

  @override
  Future<void> updateApiConfig(Map<String, dynamic> config) =>
      _settingApi.updateApiConfig(config);

  @override
  Future<PageResult<ApiKeyItemDto>> searchApiKeys({
    int page = 1,
    int pageSize = 20,
    bool excludeRevoked = false,
  }) => _settingApi.searchApiKeys(
    page: page,
    pageSize: pageSize,
    excludeRevoked: excludeRevoked,
  );

  @override
  Future<ApiKeyCreatedDto> createApiKey({
    required String requestId,
    required String name,
    String description = '',
    String ipWhiteList = '',
    String apiTrustedProxies = '',
    int apiKeyValidityTime = 120,
    DateTime? expiresAt,
    bool allowAppBinding = false,
  }) => _settingApi.createApiKey(
    requestId: requestId,
    name: name,
    description: description,
    ipWhiteList: ipWhiteList,
    apiTrustedProxies: apiTrustedProxies,
    apiKeyValidityTime: apiKeyValidityTime,
    expiresAt: expiresAt,
    allowAppBinding: allowAppBinding,
  );

  @override
  Future<void> updateApiKey({
    required String id,
    required int revision,
    required String name,
    String description = '',
    String ipWhiteList = '',
    String apiTrustedProxies = '',
    int apiKeyValidityTime = 120,
    DateTime? expiresAt,
    bool allowAppBinding = false,
  }) => _settingApi.updateApiKey(
    id: id,
    revision: revision,
    name: name,
    description: description,
    ipWhiteList: ipWhiteList,
    apiTrustedProxies: apiTrustedProxies,
    apiKeyValidityTime: apiKeyValidityTime,
    expiresAt: expiresAt,
    allowAppBinding: allowAppBinding,
  );

  @override
  Future<void> setApiKeyStatus({
    required String id,
    required int revision,
    required String status,
  }) => _settingApi.setApiKeyStatus(id: id, revision: revision, status: status);

  @override
  Future<void> revokeApiKey({required String id, required int revision}) =>
      _settingApi.revokeApiKey(id: id, revision: revision);

  @override
  Future<void> deleteApiKey({required String id, required int revision}) =>
      _settingApi.deleteApiKey(id: id, revision: revision);

  @override
  Future<String> revealApiKey({required String id, required int revision}) =>
      _settingApi.revealApiKey(id: id, revision: revision);

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
  if (server == null) throw const ServerNotFoundException();
  return SettingRepositoryImpl(SettingApi(client), storage, server: server);
}
