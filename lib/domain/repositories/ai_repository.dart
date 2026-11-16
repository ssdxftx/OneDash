import '../../data/dto/ai/ai_account_dto.dart';
import '../../data/dto/ai/ai_agent_dto.dart';
import '../../data/dto/ai/ai_agent_model_config_dto.dart';
import '../../data/dto/ai/ai_agent_role_dto.dart';
import '../../data/dto/ai/ai_feishu_config_dto.dart';
import '../../data/dto/ai/ai_provider_dto.dart';
import '../../data/dto/ai/gpu_info_dto.dart';
import '../../data/dto/ai/mcp_domain_dto.dart';
import '../../data/dto/ai/mcp_server_dto.dart';
import '../../data/dto/ai/ollama_model_dto.dart';
import '../../data/dto/common/page_result.dart';

abstract interface class AiRepository {
  Future<PageResult<OllamaModelDto>> searchOllamaModels({
    int page,
    int pageSize,
    String info,
  });

  Future<void> createOllamaModel(String name);

  Future<void> recreateOllamaModel(String name);
  Future<void> syncOllamaAccount({
    required int id,
    required String baseUrlType,
    String baseUrl,
  });
  Future<Map<String, dynamic>> getGpuOptions();

  Future<Map<String, dynamic>> getModelGpuDevices();
  Stream<String> chatAccount({
    required int id,
    required String model,
    required List<Map<String, String>> messages,
  });

  Future<List<Map<String, dynamic>>> listGpuGroups();
  Future<void> saveGpuGroup(Map<String, dynamic> body);
  Future<void> deleteGpuGroup(int id);
  Future<Map<String, dynamic>> loadModelGpuUsage(Map<String, dynamic> body);
  Future<List<Map<String, dynamic>>> batchOperateAgents(
    Map<String, dynamic> body,
  );
  Future<Map<String, dynamic>> getAgentOverview(int agentId);
  Future<List<Map<String, dynamic>>> getHermesChatSessions(int agentId);
  Future<void> renameHermesChatSession({
    required int agentId,
    required String id,
    required String title,
  });
  Future<void> deleteHermesChatSession({
    required int agentId,
    required String id,
  });
  Future<Map<String, dynamic>> searchGpuMonitor({
    required DateTime startTime,
    required DateTime endTime,
    String deviceID,
    String productName,
    bool legacy,
    String aggregation,
  });
  Future<List<Map<String, dynamic>>> getBenchmarkSources({
    String kind,
    String selected,
  });
  Future<List<Map<String, dynamic>>> listAgentPlugins(int agentId);
  Future<List<Map<String, dynamic>>> searchAgentPlugins({
    required int agentId,
    required String keyword,
    int limit,
  });
  Future<void> installAgentMarketPlugin({
    required int agentId,
    required String package,
    required String version,
    required String taskID,
  });
  Future<void> operateAgentPlugin({
    required int agentId,
    required String pluginId,
    required String operate,
    required String taskID,
  });
  Future<List<Map<String, dynamic>>> listAgentSkills(int agentId);
  Future<List<Map<String, dynamic>>> searchAgentSkills({
    required int agentId,
    required String source,
    required String keyword,
  });
  Future<void> installAgentSkill({
    required int agentId,
    required String source,
    required String slug,
    required String taskID,
  });
  Future<void> updateAgentSkill({
    required int agentId,
    required String name,
    required bool enabled,
  });
  Future<void> uninstallAgentSkill({
    required int agentId,
    required String name,
  });

  Future<void> deleteOllamaModels(List<int> ids, {bool force});

  Future<void> loadOllamaModel(String name);

  Future<void> closeOllamaModel(String name);
  Future<List<Map<String, dynamic>>> discoverAgentAccountModels({
    required String provider,
    required String baseURL,
    required String apiKey,
    required String apiType,
  });
  Future<void> installAgentChannelPlugin({
    required int agentId,
    required String type,
    required String taskID,
  });
  Future<void> upgradeAgentChannelPlugin({
    required int agentId,
    required String type,
    required String taskID,
  });
  Future<void> uninstallAgentChannelPlugin({
    required int agentId,
    required String type,
    required String taskID,
  });
  Future<void> approveAgentChannelPairing({
    required int agentId,
    required String type,
    required String pairingCode,
    String accountId,
  });
  Future<Map<String, dynamic>> checkAgentChannelPlugin({
    required int agentId,
    required String type,
    bool checkLatest,
  });
  Future<List<Map<String, dynamic>>> batchInstallAgents(
    Map<String, dynamic> body,
  );
  Future<List<Map<String, dynamic>>> batchUpgradeAgents(
    Map<String, dynamic> body,
  );
  Future<List<String>> getAgentSecurity(int agentId);
  Future<void> updateAgentSecurity(int agentId, List<String> origins);
  Future<String> getAgentConfigFile(int agentId);
  Future<void> updateAgentConfigFile(int agentId, String content);
  Future<Map<String, dynamic>> getAiDomain(int appInstallId);
  Future<void> bindAiDomain(Map<String, dynamic> body);
  Future<void> updateAiDomain(Map<String, dynamic> body);

  Future<GpuInfoDto> loadGpuInfo();

  Future<McpServerDto> getMcpServer(int id);

  Future<McpDomainDto> getMcpDomain();

  Future<void> bindMcpDomain({
    required String domain,
    required int sslID,
    required String ipList,
  });

  Future<void> updateMcpDomain({
    required int websiteID,
    required int sslID,
    required String ipList,
  });

  Future<void> syncMcpStatus(List<int> ids);

  Future<List<AiProviderDto>> getProviders();
  Future<Map<String, int>> countAccountsByProviders(List<String> providers);

  Future<void> createAccount(Map<String, dynamic> body);

  Future<void> updateAccount(Map<String, dynamic> body);

  Future<PageResult<AiAccountDto>> searchAccounts({
    int page,
    int pageSize,
    String name,
    String provider,
  });

  Future<List<Map<String, dynamic>>> getAccountModels(int accountId);

  Future<void> createAccountModel({
    required int accountId,
    required String id,
    required String name,
  });

  Future<void> updateAccountModel({
    required int accountId,
    required String id,
    required String name,
  });

  Future<void> deleteAccountModel({
    required int accountId,
    required int recordId,
    bool deleteFiles = false,
  });

  Future<void> setAccountVerifyModel({
    required int accountId,
    required int recordId,
  });

  Future<void> verifyAccount({required int id, String model = ''});

  Future<void> deleteAccount(int id);

  Future<PageResult<AiAgentDto>> searchAgents({int page, int pageSize});

  Future<void> createAgent(Map<String, dynamic> body);

  Future<void> resetAgentToken(int id);

  Future<List<AiAgentRoleDto>> getAgentRoles(int agentId);

  Future<List<Map<String, dynamic>>> listAgentRoleMarkdownFiles({
    required int agentId,
    required String workspace,
  });
  Future<void> updateAgentRoleMarkdownFile({
    required int agentId,
    required String workspace,
    required String name,
    required String content,
    bool restart,
  });
  Future<List<Map<String, dynamic>>> batchInstallAgentSkill(
    Map<String, dynamic> body,
  );
  Future<void> switchAgentFeishuPlugin(Map<String, dynamic> body);
  Future<Map<String, dynamic>> getAgentOtherConfig(int agentId);
  Future<void> updateAgentOtherConfig(Map<String, dynamic> body);
  Future<List<Map<String, dynamic>>> checkAgentDelete(int agentId);
  Future<void> deleteAgentRole(int agentId, String roleId);

  Future<String> createAgentRole({
    required int agentId,
    required String name,
    required String model,
    required List<Map<String, String>> bindings,
  });

  Future<void> bindAgentRole({
    required int agentId,
    required String roleId,
    required String channel,
    required String accountId,
  });

  Future<void> unbindAgentRole({
    required int agentId,
    required String roleId,
    required String channel,
    required String accountId,
  });

  Future<List<AiAgentChannelDto>> getAgentChannels(int agentId);

  Future<AiFeishuConfigDto> getFeishuConfig(int agentId);

  Future<Map<String, dynamic>> getChannelConfig(String channel, int agentId);

  Future<void> updateChannelConfig(String channel, Map<String, dynamic> body);

  Future<void> deleteChannelConfig(int agentId, String type);

  Future<void> loginWeixinChannel(int agentId, String taskID);

  Future<void> updateFeishuConfig(Map<String, dynamic> body);

  Future<void> bindAgentWebsite(int agentId, int websiteId);

  Future<void> unbindAgentWebsite(int agentId);

  Future<void> updateAgentRemark(int id, String remark);

  Future<void> deleteAgent(int id);

  Future<AiAgentModelConfigDto> getAgentModelConfig(int agentId);

  Future<void> updateAgentModelConfig({
    required int agentId,
    required int accountId,
    required String model,
    required List<String> fallbacks,
  });

  Future<PageResult<McpServerDto>> searchMcpServers({
    int page,
    int pageSize,
    String name,
  });

  Future<void> createMcpServer(Map<String, dynamic> body);

  Future<void> updateMcpServer(Map<String, dynamic> body);

  Future<void> deleteMcpServer(int id);

  Future<void> operateMcpServer(int id, String operate);

  Future<Map<String, dynamic>> testMcpServer(int id);
}
