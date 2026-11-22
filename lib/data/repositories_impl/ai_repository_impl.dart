import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/ai_api.dart';
import '../dto/ai/ai_account_dto.dart';
import '../dto/ai/ai_agent_dto.dart';
import '../dto/ai/ai_agent_model_config_dto.dart';
import '../dto/ai/ai_agent_role_dto.dart';
import '../dto/ai/ai_feishu_config_dto.dart';
import '../dto/ai/ai_provider_dto.dart';
import '../dto/ai/gpu_info_dto.dart';
import '../dto/ai/mcp_domain_dto.dart';
import '../dto/ai/mcp_server_dto.dart';
import '../dto/ai/ollama_model_dto.dart';
import '../dto/common/page_result.dart';

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._api);

  final AiApi _api;

  @override
  Future<PageResult<OllamaModelDto>> searchOllamaModels({
    int page = 1,
    int pageSize = 100,
    String info = '',
  }) => _api.searchOllamaModels(page: page, pageSize: pageSize, info: info);

  @override
  Future<void> createOllamaModel(String name) => _api.createOllamaModel(name);

  @override
  Future<void> recreateOllamaModel(String name) =>
      _api.recreateOllamaModel(name);

  @override
  Future<void> syncOllamaAccount({
    required int id,
    required String baseUrlType,
    String baseUrl = '',
  }) => _api.syncOllamaAccount(
    id: id,
    baseUrlType: baseUrlType,
    baseUrl: baseUrl,
  );

  @override
  Future<Map<String, dynamic>> getGpuOptions() => _api.getGpuOptions();

  @override
  Future<Map<String, dynamic>> getModelGpuDevices() =>
      _api.getModelGpuDevices();

  @override
  Stream<String> chatAccount({
    required int id,
    required String model,
    required List<Map<String, String>> messages,
  }) => _api.chatAccount(id: id, model: model, messages: messages);

  @override
  Future<List<Map<String, dynamic>>> listGpuGroups() => _api.listGpuGroups();

  @override
  Future<void> saveGpuGroup(Map<String, dynamic> body) =>
      _api.saveGpuGroup(body);

  @override
  Future<void> deleteGpuGroup(int id) => _api.deleteGpuGroup(id);

  @override
  Future<Map<String, dynamic>> loadModelGpuUsage(Map<String, dynamic> body) =>
      _api.loadModelGpuUsage(body);

  @override
  Future<List<Map<String, dynamic>>> batchOperateAgents(
    Map<String, dynamic> body,
  ) => _api.batchOperateAgents(body);

  @override
  @override
  Future<List<Map<String, dynamic>>> discoverAgentAccountModels({
    required String provider,
    required String baseURL,
    required String apiKey,
    required String apiType,
  }) => _api.discoverAgentAccountModels(
    provider: provider,
    baseURL: baseURL,
    apiKey: apiKey,
    apiType: apiType,
  );

  @override
  Future<void> installAgentChannelPlugin({
    required int agentId,
    required String type,
    required String taskID,
  }) => _api.installAgentChannelPlugin(
    agentId: agentId,
    type: type,
    taskID: taskID,
  );

  @override
  Future<void> upgradeAgentChannelPlugin({
    required int agentId,
    required String type,
    required String taskID,
  }) => _api.upgradeAgentChannelPlugin(
    agentId: agentId,
    type: type,
    taskID: taskID,
  );

  @override
  Future<void> uninstallAgentChannelPlugin({
    required int agentId,
    required String type,
    required String taskID,
  }) => _api.uninstallAgentChannelPlugin(
    agentId: agentId,
    type: type,
    taskID: taskID,
  );

  @override
  Future<void> approveAgentChannelPairing({
    required int agentId,
    required String type,
    required String pairingCode,
    String accountId = '',
  }) => _api.approveAgentChannelPairing(
    agentId: agentId,
    type: type,
    pairingCode: pairingCode,
    accountId: accountId,
  );

  @override
  Future<Map<String, dynamic>> checkAgentChannelPlugin({
    required int agentId,
    required String type,
    bool checkLatest = true,
  }) => _api.checkAgentChannelPlugin(
    agentId: agentId,
    type: type,
    checkLatest: checkLatest,
  );

  @override
  Future<List<Map<String, dynamic>>> batchInstallAgents(
    Map<String, dynamic> body,
  ) => _api.batchInstallAgents(body);

  @override
  Future<List<Map<String, dynamic>>> batchUpgradeAgents(
    Map<String, dynamic> body,
  ) => _api.batchUpgradeAgents(body);

  @override
  Future<List<String>> getAgentSecurity(int agentId) =>
      _api.getAgentSecurity(agentId);

  @override
  Future<void> updateAgentSecurity(int agentId, List<String> origins) =>
      _api.updateAgentSecurity(agentId, origins);

  @override
  Future<String> getAgentConfigFile(int agentId) =>
      _api.getAgentConfigFile(agentId);

  @override
  Future<void> updateAgentConfigFile(int agentId, String content) =>
      _api.updateAgentConfigFile(agentId, content);

  @override
  Future<Map<String, dynamic>> getAiDomain(int appInstallId) =>
      _api.getAiDomain(appInstallId);

  @override
  Future<void> bindAiDomain(Map<String, dynamic> body) =>
      _api.bindAiDomain(body);

  @override
  Future<void> updateAiDomain(Map<String, dynamic> body) =>
      _api.updateAiDomain(body);

  @override
  Future<Map<String, dynamic>> getAgentOverview(int agentId) =>
      _api.getAgentOverview(agentId);

  @override
  Future<List<Map<String, dynamic>>> getHermesChatSessions(int agentId) =>
      _api.getHermesChatSessions(agentId);

  @override
  Future<void> renameHermesChatSession({
    required int agentId,
    required String id,
    required String title,
  }) => _api.renameHermesChatSession(agentId: agentId, id: id, title: title);

  @override
  Future<void> deleteHermesChatSession({
    required int agentId,
    required String id,
  }) => _api.deleteHermesChatSession(agentId: agentId, id: id);

  @override
  Future<Map<String, dynamic>> searchGpuMonitor({
    required DateTime startTime,
    required DateTime endTime,
    String deviceID = '',
    String productName = '',
    bool legacy = false,
    String aggregation = '',
  }) => _api.searchGpuMonitor(
    startTime: startTime,
    endTime: endTime,
    deviceID: deviceID,
    productName: productName,
    legacy: legacy,
    aggregation: aggregation,
  );

  @override
  Future<List<Map<String, dynamic>>> getBenchmarkSources({
    String kind = '',
    String selected = '',
  }) => _api.getBenchmarkSources(kind: kind, selected: selected);

  @override
  Future<List<Map<String, dynamic>>> listAgentPlugins(int agentId) =>
      _api.listAgentPlugins(agentId);

  @override
  Future<List<Map<String, dynamic>>> searchAgentPlugins({
    required int agentId,
    required String keyword,
    int limit = 20,
  }) =>
      _api.searchAgentPlugins(agentId: agentId, keyword: keyword, limit: limit);

  @override
  Future<void> installAgentMarketPlugin({
    required int agentId,
    required String package,
    required String version,
    required String taskID,
  }) => _api.installAgentMarketPlugin(
    agentId: agentId,
    package: package,
    version: version,
    taskID: taskID,
  );

  @override
  Future<void> operateAgentPlugin({
    required int agentId,
    required String pluginId,
    required String operate,
    required String taskID,
  }) => _api.operateAgentPlugin(
    agentId: agentId,
    pluginId: pluginId,
    operate: operate,
    taskID: taskID,
  );

  @override
  Future<List<Map<String, dynamic>>> listAgentSkills(int agentId) =>
      _api.listAgentSkills(agentId);

  @override
  Future<List<Map<String, dynamic>>> searchAgentSkills({
    required int agentId,
    required String source,
    required String keyword,
  }) => _api.searchAgentSkills(
    agentId: agentId,
    source: source,
    keyword: keyword,
  );

  @override
  Future<void> installAgentSkill({
    required int agentId,
    required String source,
    required String slug,
    required String taskID,
  }) => _api.installAgentSkill(
    agentId: agentId,
    source: source,
    slug: slug,
    taskID: taskID,
  );

  @override
  Future<void> updateAgentSkill({
    required int agentId,
    required String name,
    required bool enabled,
  }) => _api.updateAgentSkill(agentId: agentId, name: name, enabled: enabled);

  @override
  Future<void> uninstallAgentSkill({
    required int agentId,
    required String name,
  }) => _api.uninstallAgentSkill(agentId: agentId, name: name);

  @override
  Future<void> deleteOllamaModels(List<int> ids, {bool force = false}) =>
      _api.deleteOllamaModels(ids, force: force);

  @override
  Future<String> loadOllamaModel(String name) => _api.loadOllamaModel(name);

  @override
  Future<void> closeOllamaModel(String name) => _api.closeOllamaModel(name);

  @override
  Future<GpuInfoDto> loadGpuInfo() => _api.loadGpuInfo();

  @override
  Future<McpServerDto> getMcpServer(int id) => _api.getMcpServer(id);

  @override
  Future<McpDomainDto> getMcpDomain() => _api.getMcpDomain();

  @override
  Future<void> bindMcpDomain({
    required String domain,
    required int sslID,
    required String ipList,
  }) => _api.bindMcpDomain(domain: domain, sslID: sslID, ipList: ipList);

  @override
  Future<void> updateMcpDomain({
    required int websiteID,
    required int sslID,
    required String ipList,
  }) =>
      _api.updateMcpDomain(websiteID: websiteID, sslID: sslID, ipList: ipList);

  @override
  Future<void> syncMcpStatus(List<int> ids) => _api.syncMcpStatus(ids);

  @override
  Future<List<AiProviderDto>> getProviders() => _api.getProviders();

  @override
  Future<Map<String, int>> countAccountsByProviders(List<String> providers) =>
      _api.countAccountsByProviders(providers);

  @override
  Future<void> createAccount(Map<String, dynamic> body) =>
      _api.createAccount(body);

  @override
  Future<void> updateAccount(Map<String, dynamic> body) =>
      _api.updateAccount(body);

  @override
  Future<PageResult<AiAccountDto>> searchAccounts({
    int page = 1,
    int pageSize = 100,
    String name = '',
    String provider = '',
  }) => _api.searchAccounts(
    page: page,
    pageSize: pageSize,
    name: name,
    provider: provider,
  );

  @override
  Future<List<Map<String, dynamic>>> getAccountModels(int accountId) =>
      _api.getAccountModels(accountId);

  @override
  Future<void> createAccountModel({
    required int accountId,
    required String id,
    required String name,
  }) => _api.createAccountModel(accountId: accountId, id: id, name: name);

  @override
  Future<void> updateAccountModel({
    required int accountId,
    required String id,
    required String name,
  }) => _api.updateAccountModel(accountId: accountId, id: id, name: name);

  @override
  Future<void> deleteAccountModel({
    required int accountId,
    required int recordId,
    bool deleteFiles = false,
  }) => _api.deleteAccountModel(
    accountId: accountId,
    recordId: recordId,
    deleteFiles: deleteFiles,
  );

  @override
  Future<void> setAccountVerifyModel({
    required int accountId,
    required int recordId,
  }) => _api.setAccountVerifyModel(accountId: accountId, recordId: recordId);

  @override
  Future<void> verifyAccount({required int id, String model = ''}) =>
      _api.verifyAccount(id: id, model: model);

  @override
  Future<void> deleteAccount(int id) => _api.deleteAccount(id);

  @override
  Future<PageResult<AiAgentDto>> searchAgents({
    int page = 1,
    int pageSize = 100,
  }) => _api.searchAgents(page: page, pageSize: pageSize);

  @override
  Future<void> createAgent(Map<String, dynamic> body) => _api.createAgent(body);

  @override
  Future<void> resetAgentToken(int id) => _api.resetAgentToken(id);

  @override
  Future<List<AiAgentRoleDto>> getAgentRoles(int agentId) =>
      _api.getAgentRoles(agentId);

  @override
  Future<List<Map<String, dynamic>>> listAgentRoleMarkdownFiles({
    required int agentId,
    required String workspace,
  }) => _api.listAgentRoleMarkdownFiles(agentId: agentId, workspace: workspace);

  @override
  Future<void> updateAgentRoleMarkdownFile({
    required int agentId,
    required String workspace,
    required String name,
    required String content,
    bool restart = false,
  }) => _api.updateAgentRoleMarkdownFile(
    agentId: agentId,
    workspace: workspace,
    name: name,
    content: content,
    restart: restart,
  );

  @override
  Future<List<Map<String, dynamic>>> batchInstallAgentSkill(
    Map<String, dynamic> body,
  ) => _api.batchInstallAgentSkill(body);

  @override
  Future<void> switchAgentFeishuPlugin(Map<String, dynamic> body) =>
      _api.switchAgentFeishuPlugin(body);

  @override
  Future<Map<String, dynamic>> getAgentOtherConfig(int agentId) =>
      _api.getAgentOtherConfig(agentId);

  @override
  Future<void> updateAgentOtherConfig(Map<String, dynamic> body) =>
      _api.updateAgentOtherConfig(body);

  @override
  Future<List<Map<String, dynamic>>> checkAgentDelete(int agentId) =>
      _api.checkAgentDelete(agentId);

  @override
  Future<void> deleteAgentRole(int agentId, String roleId) =>
      _api.deleteAgentRole(agentId, roleId);

  @override
  Future<String> createAgentRole({
    required int agentId,
    required String name,
    required String model,
    required List<Map<String, String>> bindings,
  }) => _api.createAgentRole(
    agentId: agentId,
    name: name,
    model: model,
    bindings: bindings,
  );

  @override
  Future<void> bindAgentRole({
    required int agentId,
    required String roleId,
    required String channel,
    required String accountId,
  }) => _api.bindAgentRole(
    agentId: agentId,
    roleId: roleId,
    channel: channel,
    accountId: accountId,
  );

  @override
  Future<void> unbindAgentRole({
    required int agentId,
    required String roleId,
    required String channel,
    required String accountId,
  }) => _api.unbindAgentRole(
    agentId: agentId,
    roleId: roleId,
    channel: channel,
    accountId: accountId,
  );

  @override
  Future<List<AiAgentChannelDto>> getAgentChannels(int agentId) =>
      _api.getAgentChannels(agentId);

  @override
  Future<AiFeishuConfigDto> getFeishuConfig(int agentId) =>
      _api.getFeishuConfig(agentId);

  @override
  Future<Map<String, dynamic>> getChannelConfig(String channel, int agentId) =>
      _api.getChannelConfig(channel, agentId);

  @override
  Future<void> loginWeixinChannel(int agentId, String taskID) =>
      _api.loginWeixinChannel(agentId, taskID);

  @override
  Future<void> deleteChannelConfig(int agentId, String type) =>
      _api.deleteChannelConfig(agentId, type);

  @override
  Future<void> updateChannelConfig(String channel, Map<String, dynamic> body) =>
      _api.updateChannelConfig(channel, body);

  @override
  Future<void> updateFeishuConfig(Map<String, dynamic> body) =>
      _api.updateFeishuConfig(body);

  @override
  Future<void> bindAgentWebsite(int agentId, int websiteId) =>
      _api.bindAgentWebsite(agentId, websiteId);

  @override
  Future<void> unbindAgentWebsite(int agentId) =>
      _api.unbindAgentWebsite(agentId);

  @override
  Future<void> updateAgentRemark(int id, String remark) =>
      _api.updateAgentRemark(id, remark);

  @override
  Future<void> deleteAgent(int id) => _api.deleteAgent(id);

  @override
  Future<AiAgentModelConfigDto> getAgentModelConfig(int agentId) =>
      _api.getAgentModelConfig(agentId);

  @override
  Future<void> updateAgentModelConfig({
    required int agentId,
    required int accountId,
    required String model,
    required List<String> fallbacks,
  }) => _api.updateAgentModelConfig(
    agentId: agentId,
    accountId: accountId,
    model: model,
    fallbacks: fallbacks,
  );

  @override
  Future<PageResult<McpServerDto>> searchMcpServers({
    int page = 1,
    int pageSize = 100,
    String name = '',
  }) => _api.searchMcpServers(page: page, pageSize: pageSize, name: name);

  @override
  Future<void> createMcpServer(Map<String, dynamic> body) =>
      _api.createMcpServer(body);

  @override
  Future<void> updateMcpServer(Map<String, dynamic> body) =>
      _api.updateMcpServer(body);

  @override
  Future<void> deleteMcpServer(int id) => _api.deleteMcpServer(id);

  @override
  Future<void> operateMcpServer(int id, String operate) =>
      _api.operateMcpServer(id, operate);

  @override
  Future<Map<String, dynamic>> testMcpServer(int id) => _api.testMcpServer(id);
}

final aiRepositoryProvider = FutureProvider<AiRepository>((ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return AiRepositoryImpl(AiApi(client));
}, dependencies: [activeServerIdProvider]);
