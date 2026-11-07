import 'package:uuid/uuid.dart';

import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/ai/ai_account_dto.dart';
import '../dto/ai/ai_agent_model_config_dto.dart';
import '../dto/ai/ai_agent_role_dto.dart';
import '../dto/ai/ai_feishu_config_dto.dart';
import '../dto/ai/ai_provider_dto.dart';
import '../dto/ai/ai_agent_dto.dart';
import '../dto/ai/gpu_info_dto.dart';
import '../dto/ai/mcp_domain_dto.dart';
import '../dto/ai/mcp_server_dto.dart';
import '../dto/ai/ollama_model_dto.dart';
import '../dto/common/page_result.dart';

class AiApi {
  AiApi(this._client);

  final DioClient _client;

  Future<PageResult<OllamaModelDto>> searchOllamaModels({
    int page = 1,
    int pageSize = 100,
    String info = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/ollama/model/search',
      data: {'page': page, 'pageSize': pageSize, 'info': info},
    );
    return PageResult<OllamaModelDto>.fromJson(
      ApiResponseParser.map(resp),
      OllamaModelDto.fromJson,
    );
  }

  Future<void> createOllamaModel(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/ollama/model',
      data: {'name': name, 'taskID': const Uuid().v4()},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> deleteOllamaModels(List<int> ids, {bool force = false}) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/ollama/model/del',
      data: {'ids': ids, 'forceDelete': force},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> loadOllamaModel(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/ollama/model/load',
      data: {'name': name, 'taskID': const Uuid().v4()},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> closeOllamaModel(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/ollama/close',
      data: {'name': name, 'taskID': const Uuid().v4()},
    );
    ApiResponseParser.ok(resp);
  }

  Future<GpuInfoDto> loadGpuInfo() async {
    final resp = await _client.get<Map<String, dynamic>>('/api/v2/ai/gpu/load');
    return ApiResponseParser.object(resp, GpuInfoDto.fromJson);
  }

  Future<McpServerDto> getMcpServer(int id) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/mcp/server/detail',
      data: {'id': id},
    );
    return ApiResponseParser.object(resp, McpServerDto.fromJson);
  }

  Future<McpDomainDto> getMcpDomain() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/ai/mcp/domain/get',
    );
    return ApiResponseParser.object(resp, McpDomainDto.fromJson);
  }

  Future<void> bindMcpDomain({
    required String domain,
    required int sslID,
    required String ipList,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/mcp/domain/bind',
      data: {'domain': domain, 'sslID': sslID, 'ipList': ipList},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> updateMcpDomain({
    required int websiteID,
    required int sslID,
    required String ipList,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/mcp/domain/update',
      data: {'websiteID': websiteID, 'sslID': sslID, 'ipList': ipList},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> syncMcpStatus(List<int> ids) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/mcp/server/status/sync',
      data: {'ids': ids},
    );
    ApiResponseParser.ok(resp);
  }

  Future<PageResult<McpServerDto>> searchMcpServers({
    int page = 1,
    int pageSize = 100,
    String name = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/mcp/search',
      data: {'page': page, 'pageSize': pageSize, 'name': name},
    );
    return PageResult<McpServerDto>.fromJson(
      ApiResponseParser.map(resp),
      McpServerDto.fromJson,
    );
  }

  Future<void> createMcpServer(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/mcp/server',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> updateMcpServer(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/mcp/server/update',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> deleteMcpServer(int id) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/mcp/server/del',
      data: {'id': id},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> operateMcpServer(int id, String operate) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/mcp/server/op',
      data: {'id': id, 'operate': operate},
    );
    ApiResponseParser.ok(resp);
  }

  Future<Map<String, dynamic>> testMcpServer(int id) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/mcp/server/connection/test',
      data: {'id': id},
    );
    return ApiResponseParser.map(resp);
  }

  Future<PageResult<AiAccountDto>> searchAccounts({
    int page = 1,
    int pageSize = 100,
    String name = '',
    String provider = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        'name': name,
        'provider': provider,
      },
    );
    return PageResult<AiAccountDto>.fromJson(
      ApiResponseParser.map(resp),
      AiAccountDto.fromJson,
    );
  }

  Future<void> deleteAccount(int id) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/delete',
      data: {'id': id},
    );
    ApiResponseParser.ok(resp);
  }

  Future<PageResult<AiAgentDto>> searchAgents({
    int page = 1,
    int pageSize = 100,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/search',
      data: {'page': page, 'pageSize': pageSize},
    );
    return PageResult<AiAgentDto>.fromJson(
      ApiResponseParser.map(resp),
      AiAgentDto.fromJson,
    );
  }

  Future<void> resetAgentToken(int id) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/token/reset',
      data: {'id': id},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> updateAgentRemark(int id, String remark) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/remark',
      data: {'id': id, 'remark': remark},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> deleteAgent(int id) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/delete',
      data: {'id': id, 'taskID': const Uuid().v4(), 'forceDelete': false},
    );
    ApiResponseParser.ok(resp);
  }

  Future<List<AiProviderDto>> getProviders() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/ai/accounts/providers',
    );
    return ApiResponseParser.list(resp, AiProviderDto.fromJson);
  }

  Future<void> createAccount(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> updateAccount(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/update',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<AiAgentModelConfigDto> getAgentModelConfig(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/model/get',
      data: {'agentId': agentId},
    );
    return ApiResponseParser.object(resp, AiAgentModelConfigDto.fromJson);
  }

  Future<void> updateAgentModelConfig({
    required int agentId,
    required int accountId,
    required String model,
    required List<String> fallbacks,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/model/update',
      data: {
        'agentId': agentId,
        'accountId': accountId,
        'model': model,
        'fallbacks': fallbacks,
        'metadata': const [],
      },
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> createAgent(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> bindAgentWebsite(int agentId, int websiteId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/website/bind',
      data: {'agentId': agentId, 'websiteId': websiteId},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> unbindAgentWebsite(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/website/unbind',
      data: {'agentId': agentId},
    );
    ApiResponseParser.ok(resp);
  }

  Future<List<AiAgentRoleDto>> getAgentRoles(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/agent/list',
      data: {'agentId': agentId},
    );
    return ApiResponseParser.list(resp, AiAgentRoleDto.fromJson);
  }

  Future<void> deleteAgentRole(int agentId, String roleId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/agent/delete',
      data: {'agentId': agentId, 'id': roleId},
    );
    ApiResponseParser.ok(resp);
  }

  Future<List<AiAgentChannelDto>> getAgentChannels(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/agent/channels',
      data: {'agentId': agentId},
    );
    return ApiResponseParser.list(resp, AiAgentChannelDto.fromJson);
  }

  Future<String> createAgentRole({
    required int agentId,
    required String name,
    required String model,
    required List<Map<String, String>> bindings,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/agent/create',
      data: {
        'agentId': agentId,
        'name': name,
        'model': model,
        'bindings': bindings,
      },
    );
    final data = ApiResponseParser.map(resp);
    return '${data['output'] ?? ''}';
  }

  Future<void> bindAgentRole({
    required int agentId,
    required String roleId,
    required String channel,
    required String accountId,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/agent/bind',
      data: {
        'agentId': agentId,
        'id': roleId,
        'channel': channel,
        'accountId': accountId,
      },
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> unbindAgentRole({
    required int agentId,
    required String roleId,
    required String channel,
    required String accountId,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/agent/unbind',
      data: {
        'agentId': agentId,
        'id': roleId,
        'channel': channel,
        'accountId': accountId,
      },
    );
    ApiResponseParser.ok(resp);
  }

  Future<AiFeishuConfigDto> getFeishuConfig(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/channel/feishu/get',
      data: {'agentId': agentId},
    );
    return ApiResponseParser.object(resp, AiFeishuConfigDto.fromJson);
  }

  Future<void> updateFeishuConfig(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/channel/feishu/update',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<Map<String, dynamic>> getChannelConfig(
    String channel,
    int agentId,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/channel/$channel/get',
      data: {'agentId': agentId},
    );
    return ApiResponseParser.map(resp);
  }

  Future<void> updateChannelConfig(
    String channel,
    Map<String, dynamic> body,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/channel/$channel/update',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> deleteChannelConfig(int agentId, String type) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/channel/delete',
      data: {'agentId': agentId, 'type': type},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> loginWeixinChannel(int agentId, String taskID) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/channel/weixin/login',
      data: {'agentId': agentId, 'taskID': taskID},
    );
    ApiResponseParser.ok(resp);
  }
}
