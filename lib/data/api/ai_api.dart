import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import 'task_waiter.dart';
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

  Future<void> recreateOllamaModel(String name) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/ollama/model/recreate',
      data: {'name': name},
    );
  }

  Future<void> syncOllamaAccount({
    required int id,
    required String baseUrlType,
    String baseUrl = '',
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/ollama/account/sync',
      data: {
        'id': id,
        'modelAccountBaseURLType': baseUrlType,
        'modelAccountBaseURL': baseUrl,
      },
    );
  }

  Future<Map<String, dynamic>> getGpuOptions() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/ai/gpu/options',
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> searchGpuMonitor({
    required DateTime startTime,
    required DateTime endTime,
    String deviceID = '',
    String productName = '',
    bool legacy = false,
    String aggregation = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/gpu/search',
      data: {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'deviceID': deviceID,
        'productName': productName,
        'legacy': legacy,
        'aggregation': aggregation,
      },
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> getModelGpuDevices() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/ai/model/gpu/devices',
    );
    return ApiResponseParser.map(resp);
  }

  /// 模型账号流式对话。逐段返回模型输出的文本增量。
  Stream<String> chatAccount({
    required int id,
    required String model,
    required List<Map<String, String>> messages,
  }) async* {
    final response = await _client.postStream(
      '/api/v2/ai/accounts/chat',
      data: {'id': id, 'model': model, 'messages': messages},
    );
    final body = response.data;
    if (body == null) return;
    var buffer = '';
    await for (final text in body.stream.map(
      (bytes) => utf8.decode(bytes, allowMalformed: true),
    )) {
      buffer += text;
      while (true) {
        final separator = buffer.indexOf('\n\n');
        if (separator < 0) break;
        final event = buffer.substring(0, separator);
        buffer = buffer.substring(separator + 2);
        final delta = _chatDelta(event);
        if (delta != null) yield delta;
      }
    }
    final delta = _chatDelta(buffer);
    if (delta != null) yield delta;
  }

  String? _chatDelta(String event) {
    for (final line in event.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('data:')) continue;
      final payload = trimmed.substring(5).trim();
      if (payload.isEmpty || payload == '[DONE]') continue;
      Object? decoded;
      try {
        decoded = jsonDecode(payload);
      } catch (_) {
        continue;
      }
      if (decoded is! Map) continue;
      final error = decoded['error'];
      if (error is Map && '${error['message'] ?? ''}'.isNotEmpty) {
        throw FormatException('${error['message']}');
      }
      final choices = decoded['choices'];
      if (choices is List && choices.isNotEmpty) {
        final choice = choices.first;
        if (choice is Map) {
          final delta = choice['delta'];
          if (delta is Map && delta['content'] is String) {
            return delta['content'] as String;
          }
          final text = choice['text'];
          if (text is String && text.isNotEmpty) return text;
        }
      }
      final delta = decoded['delta'];
      if (delta is Map && delta['text'] is String) {
        return delta['text'] as String;
      }
      if (delta is String && delta.isNotEmpty) return delta;
      final candidates = decoded['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final candidate = candidates.first;
        if (candidate is Map) {
          final content = candidate['content'];
          if (content is Map) {
            final parts = content['parts'];
            if (parts is List && parts.isNotEmpty) {
              final part = parts.first;
              if (part is Map && part['text'] is String) {
                return part['text'] as String;
              }
            }
          }
        }
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> listGpuGroups() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/ai/gpu/groups',
    );
    return ApiResponseParser.list(resp, (json) => json);
  }

  Future<void> saveGpuGroup(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/gpu/groups/save',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> deleteGpuGroup(int id) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/gpu/groups/del',
      data: {'id': id},
    );
    ApiResponseParser.ok(resp);
  }

  Future<Map<String, dynamic>> loadModelGpuUsage(
    Map<String, dynamic> body,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/model/gpu/usage',
      data: body,
    );
    return ApiResponseParser.map(resp);
  }

  Future<List<Map<String, dynamic>>> batchOperateAgents(
    Map<String, dynamic> body,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/batch/operate',
      data: body,
    );
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<List<Map<String, dynamic>>> batchInstallAgents(
    Map<String, dynamic> body,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/batch/install',
      data: body,
    );
    final data = resp.data?['data'];
    if (data is Map) {
      return [Map<String, dynamic>.from(data)];
    }
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<List<Map<String, dynamic>>> batchUpgradeAgents(
    Map<String, dynamic> body,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/batch/upgrade',
      data: body,
    );
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<List<String>> getAgentSecurity(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/security/get',
      data: {'agentId': agentId},
    );
    final data = ApiResponseParser.map(resp);
    final origins = data['allowedOrigins'];
    if (origins is List) {
      return origins.map((item) => '$item').toList(growable: false);
    }
    return const [];
  }

  Future<void> updateAgentSecurity(int agentId, List<String> origins) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/security/update',
      data: {'agentId': agentId, 'allowedOrigins': origins},
    );
  }

  Future<String> getAgentConfigFile(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/config-file/get',
      data: {'agentId': agentId},
    );
    return '${ApiResponseParser.map(resp)['content'] ?? ''}';
  }

  Future<void> updateAgentConfigFile(int agentId, String content) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/config-file/update',
      data: {'agentId': agentId, 'content': content},
    );
  }

  Future<Map<String, dynamic>> getAiDomain(int appInstallId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/domain/get',
      data: {'appInstallID': appInstallId},
    );
    return ApiResponseParser.map(resp);
  }

  Future<void> bindAiDomain(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/domain/bind',
      data: body,
    );
  }

  Future<void> updateAiDomain(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/domain/update',
      data: body,
    );
  }

  Future<Map<String, dynamic>> getAgentOverview(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/overview',
      data: {'agentId': agentId},
    );
    return ApiResponseParser.map(resp);
  }

  Future<List<Map<String, dynamic>>> getHermesChatSessions(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/hermes/chat/sessions',
      data: {'agentId': agentId},
    );
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<void> renameHermesChatSession({
    required int agentId,
    required String id,
    required String title,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/hermes/chat/sessions/rename',
      data: {'agentId': agentId, 'id': id, 'title': title},
    );
  }

  Future<void> deleteHermesChatSession({
    required int agentId,
    required String id,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/hermes/chat/sessions/delete',
      data: {'agentId': agentId, 'id': id},
    );
  }

  Future<List<Map<String, dynamic>>> getBenchmarkSources({
    String kind = '',
    String selected = '',
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/ai/benchmark/sources',
      query: {
        if (kind.isNotEmpty) 'kind': kind,
        if (selected.isNotEmpty) 'selected': selected,
      },
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map>().map(_mapOf).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> discoverAgentAccountModels({
    required String provider,
    required String baseURL,
    required String apiKey,
    required String apiType,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/models/discover',
      data: {
        'provider': provider,
        'baseURL': baseURL,
        'apiKey': apiKey,
        'apiType': apiType,
      },
    );
    return ApiResponseParser.list(resp, _mapOf);
  }

  Future<void> installAgentChannelPlugin({
    required int agentId,
    required String type,
    required String taskID,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/plugin/install',
      data: {'agentId': agentId, 'type': type, 'taskID': taskID},
    );
  }

  Future<void> upgradeAgentChannelPlugin({
    required int agentId,
    required String type,
    required String taskID,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/plugin/upgrade',
      data: {'agentId': agentId, 'type': type, 'taskID': taskID},
    );
  }

  Future<void> uninstallAgentChannelPlugin({
    required int agentId,
    required String type,
    required String taskID,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/plugin/uninstall',
      data: {'agentId': agentId, 'type': type, 'taskID': taskID},
    );
  }

  Future<void> approveAgentChannelPairing({
    required int agentId,
    required String type,
    required String pairingCode,
    String accountId = '',
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/channel/pairing/approve',
      data: {
        'agentId': agentId,
        'type': type,
        'pairingCode': pairingCode,
        'accountId': accountId,
      },
    );
  }

  Future<Map<String, dynamic>> checkAgentChannelPlugin({
    required int agentId,
    required String type,
    bool checkLatest = true,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/plugin/check',
      data: {'agentId': agentId, 'type': type, 'checkLatest': checkLatest},
    );
    return ApiResponseParser.map(resp);
  }

  Future<List<Map<String, dynamic>>> listAgentPlugins(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/plugins/list',
      data: {'agentId': agentId},
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map>().map(_mapOf).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> searchAgentPlugins({
    required int agentId,
    required String keyword,
    int limit = 20,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/plugins/search',
      data: {'agentId': agentId, 'keyword': keyword, 'limit': limit},
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map>().map(_mapOf).toList(growable: false);
  }

  Future<void> installAgentMarketPlugin({
    required int agentId,
    required String package,
    required String version,
    required String taskID,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/plugins/install',
      data: {
        'agentId': agentId,
        'package': package,
        'version': version,
        'taskID': taskID,
      },
    );
    await _awaitTask(resp);
  }

  Future<void> operateAgentPlugin({
    required int agentId,
    required String pluginId,
    required String operate,
    required String taskID,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/plugins/operate',
      data: {
        'agentId': agentId,
        'pluginId': pluginId,
        'operate': operate,
        'taskID': taskID,
      },
    );
    await _awaitTask(resp);
  }

  Future<List<Map<String, dynamic>>> listAgentSkills(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/skills/list',
      data: {'agentId': agentId},
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map>().map(_mapOf).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> searchAgentSkills({
    required int agentId,
    required String source,
    required String keyword,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/skills/search',
      data: {'agentId': agentId, 'source': source, 'keyword': keyword},
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map>().map(_mapOf).toList(growable: false);
  }

  Future<void> installAgentSkill({
    required int agentId,
    required String source,
    required String slug,
    required String taskID,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/skills/install',
      data: {
        'agentId': agentId,
        'source': source,
        'slug': slug,
        'taskID': taskID,
      },
    );
    await _awaitTask(resp);
  }

  Future<void> updateAgentSkill({
    required int agentId,
    required String name,
    required bool enabled,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/skills/update',
      data: {'agentId': agentId, 'name': name, 'enabled': enabled},
    );
  }

  Future<void> uninstallAgentSkill({
    required int agentId,
    required String name,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/skills/uninstall',
      data: {'agentId': agentId, 'name': name},
    );
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

  /// POST /api/v2/ai/accounts/models
  Future<List<Map<String, dynamic>>> getAccountModels(int accountId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/models',
      data: {'accountId': accountId},
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList(growable: false);
  }

  /// POST /api/v2/ai/accounts/models/create
  Future<void> createAccountModel({
    required int accountId,
    required String id,
    required String name,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/models/create',
      data: {
        'accountId': accountId,
        'model': {'id': id, 'name': name},
      },
    );
  }

  /// POST /api/v2/ai/accounts/models/update
  Future<void> updateAccountModel({
    required int accountId,
    required String id,
    required String name,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/models/update',
      data: {
        'accountId': accountId,
        'model': {'id': id, 'name': name},
      },
    );
  }

  /// POST /api/v2/ai/accounts/models/delete
  Future<void> deleteAccountModel({
    required int accountId,
    required int recordId,
    bool deleteFiles = false,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/models/delete',
      data: {
        'accountId': accountId,
        'recordId': recordId,
        'deleteFiles': deleteFiles,
      },
    );
  }

  /// POST /api/v2/ai/accounts/models/verify-model
  Future<void> setAccountVerifyModel({
    required int accountId,
    required int recordId,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/models/verify-model',
      data: {'accountId': accountId, 'recordId': recordId},
    );
  }

  /// POST /api/v2/ai/accounts/verify
  Future<void> verifyAccount({required int id, String model = ''}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/verify',
      data: {'id': id, 'model': model},
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

  /// 按供应商统计模型账号数量。
  /// POST /api/v2/ai/accounts/counts
  Future<Map<String, int>> countAccountsByProviders(
    List<String> providers,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/accounts/counts',
      data: {'providers': providers},
    );
    final data = resp.data?['data'];
    if (data is! Map) return const {};
    return data.map(
      (key, value) => MapEntry(
        '$key',
        value is num ? value.toInt() : int.tryParse('$value') ?? 0,
      ),
    );
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

  Future<List<Map<String, dynamic>>> listAgentRoleMarkdownFiles({
    required int agentId,
    required String workspace,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/agent/md/list',
      data: {'agentId': agentId, 'workspace': workspace},
    );
    return ApiResponseParser.list(resp, (json) => json);
  }

  Future<void> updateAgentRoleMarkdownFile({
    required int agentId,
    required String workspace,
    required String name,
    required String content,
    bool restart = false,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/agent/md/update',
      data: {
        'agentId': agentId,
        'workspace': workspace,
        'restart': restart,
        'files': [
          {'name': name, 'content': content},
        ],
      },
    );
    ApiResponseParser.ok(resp);
  }

  Future<List<Map<String, dynamic>>> batchInstallAgentSkill(
    Map<String, dynamic> body,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/batch/skill/install',
      data: body,
    );
    return ApiResponseParser.list(resp, (json) => json);
  }

  Future<void> switchAgentFeishuPlugin(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/channel/feishu/switch',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<Map<String, dynamic>> getAgentOtherConfig(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/other/get',
      data: {'agentId': agentId},
    );
    return ApiResponseParser.map(resp);
  }

  Future<void> updateAgentOtherConfig(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/other/update',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<List<Map<String, dynamic>>> checkAgentDelete(int agentId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/delete/check',
      data: {'agentId': agentId},
    );
    return ApiResponseParser.list(resp, (json) => json);
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

  static const Map<String, String> _channelPaths = {
    'telegram': 'telegram',
    'discord': 'discord',
    'wecom': 'wecom',
    'dingtalk': 'dingtalk',
    'qqbot': 'qqbot',
  };

  String _channelPath(String channel) {
    final path = _channelPaths[channel];
    if (path == null) {
      throw ArgumentError.value(channel, 'channel', 'Unsupported channel');
    }
    return path;
  }

  Future<Map<String, dynamic>> getChannelConfig(
    String channel,
    int agentId,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/channel/${_channelPath(channel)}/get',
      data: {'agentId': agentId},
    );
    return ApiResponseParser.map(resp);
  }

  Future<void> updateChannelConfig(
    String channel,
    Map<String, dynamic> body,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/ai/agents/channel/${_channelPath(channel)}/update',
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

  static Map<String, dynamic> _mapOf(Map<dynamic, dynamic> value) =>
      Map<String, dynamic>.from(value);

  Future<void> _awaitTask(Response<dynamic> response) async {
    final data = response.data is Map ? (response.data as Map)['data'] : null;
    if (data is! Map) return;
    final taskID = '${data['taskID'] ?? ''}';
    if (data['queued'] == true && taskID.isNotEmpty) {
      await TaskWaiter(
        _client,
        interval: const Duration(seconds: 2),
        maxAttempts: 300,
      ).waitFor(taskID, subject: 'AI task');
    }
  }
}
