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
  Future<void> deleteOllamaModels(List<int> ids, {bool force = false}) =>
      _api.deleteOllamaModels(ids, force: force);

  @override
  Future<void> loadOllamaModel(String name) => _api.loadOllamaModel(name);

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
