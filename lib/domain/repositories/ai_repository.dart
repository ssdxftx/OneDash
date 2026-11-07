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

  Future<void> deleteOllamaModels(List<int> ids, {bool force});

  Future<void> loadOllamaModel(String name);

  Future<void> closeOllamaModel(String name);

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

  Future<void> createAccount(Map<String, dynamic> body);

  Future<void> updateAccount(Map<String, dynamic> body);

  Future<PageResult<AiAccountDto>> searchAccounts({
    int page,
    int pageSize,
    String name,
    String provider,
  });

  Future<void> deleteAccount(int id);

  Future<PageResult<AiAgentDto>> searchAgents({int page, int pageSize});

  Future<void> createAgent(Map<String, dynamic> body);

  Future<void> resetAgentToken(int id);

  Future<List<AiAgentRoleDto>> getAgentRoles(int agentId);

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
