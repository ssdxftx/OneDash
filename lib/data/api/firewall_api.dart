import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/common/task_log_dto.dart';
import '../dto/firewall/firewall_base_info_dto.dart';
import '../dto/firewall/firewall_v2_dto.dart';

/// 1Panel v2.4.2 防火墙 API。
///
/// 只保留 `hosts/firewall/*` 的新路由，不包含 v2.0 legacy 分支。
class FirewallApi {
  FirewallApi(this._client);

  final DioClient _client;

  Future<FirewallBaseInfoDto> getBaseInfo() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/base',
      data: const {'name': 'base'},
    );
    return ApiResponseParser.object(response, FirewallBaseInfoDto.fromJson);
  }

  Future<FirewallSettingsInfo> getSettings() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/settings',
    );
    return ApiResponseParser.object(response, FirewallSettingsInfo.new);
  }

  Future<FirewallInventory> searchRules({
    required String provider,
    int page = 1,
    int pageSize = 100,
    String info = '',
    List<String> families = const [],
    List<String> actions = const [],
    bool refresh = false,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/rules/search',
      data: {
        'scopes': scopesFor(provider),
        'page': page,
        'pageSize': pageSize,
        'info': info,
        'families': families,
        'actions': actions,
        'excludeChains': const <String>[],
        'refresh': refresh,
      },
    );
    return ApiResponseParser.object(response, FirewallInventory.fromJson);
  }

  Future<void> createRules(
    List<Map<String, dynamic>> rules, {
    String sourceKind = 'user',
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/rules',
      data: {
        'items': rules
            .map((rule) => {'rule': rule, 'sourceKind': sourceKind})
            .toList(),
      },
    );
    await _awaitTask(
      ApiResponseParser.object(response, FirewallTaskResult.fromJson),
    );
  }

  Future<void> deleteRules(List<FirewallRuleItem> items) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/rules/delete',
      data: {'targets': items.map((item) => item.deleteTarget()).toList()},
    );
    await _awaitTask(
      ApiResponseParser.object(response, FirewallTaskResult.fromJson),
    );
  }

  Future<void> updateRule(
    FirewallRuleItem item, {
    Map<String, dynamic>? rule,
    String? description,
    int? orderIndex,
    int? priority,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/rules/update',
      data: {
        ...item.deleteTarget(),
        if (rule != null) 'rule': rule,
        if (description != null) 'description': description,
        if (orderIndex != null) 'orderIndex': orderIndex,
        if (priority != null) 'priority': priority,
      },
    );
    ApiResponseParser.ok(response);
  }

  Future<void> reorderRule(
    FirewallRuleItem item, {
    int? targetPosition,
    int? priority,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/rules/reorder',
      data: {
        ...item.deleteTarget(),
        if (targetPosition != null) 'targetPosition': targetPosition,
        if (priority != null) 'priority': priority,
      },
    );
    ApiResponseParser.ok(response);
  }

  Future<void> operate(
    String operation, {
    bool withDockerRestart = false,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/operate',
      data: {'operation': operation, 'withDockerRestart': withDockerRestart},
    );
    await _awaitTask(
      ApiResponseParser.object(response, FirewallTaskResult.fromJson),
    );
  }

  Future<void> updateIPv6(bool enabled) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/settings/ipv6',
      data: {'status': enabled ? 'Enable' : 'Disable'},
    );
    await _awaitTask(
      ApiResponseParser.object(response, FirewallTaskResult.fromJson),
    );
  }

  Future<void> operateBackend({
    required String subsystem,
    required String backend,
    required String operation,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/settings/operate',
      data: {
        'subsystem': subsystem,
        'backend': backend,
        'operation': operation,
      },
    );
    ApiResponseParser.ok(response);
  }

  Future<void> createWhitelist(FirewallWhitelistRule rule) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/settings/whitelist',
      data: {'rule': rule.toJson()},
    );
    ApiResponseParser.ok(response);
  }

  Future<void> updateWhitelist({
    required FirewallWhitelistRule oldRule,
    required FirewallWhitelistRule rule,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/settings/whitelist/update',
      data: {'oldRule': oldRule.toJson(), 'rule': rule.toJson()},
    );
    ApiResponseParser.ok(response);
  }

  Future<void> deleteWhitelist(FirewallWhitelistRule rule) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/settings/whitelist/delete',
      data: {'rule': rule.toJson()},
    );
    ApiResponseParser.ok(response);
  }

  Future<FirewallBaseInfoDto> getForwardBase() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/forward/base',
      data: const {},
    );
    return ApiResponseParser.object(response, FirewallBaseInfoDto.fromJson);
  }

  Future<FirewallForwardPage> searchForwardRules({
    int page = 1,
    int pageSize = 100,
    String info = '',
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/forward/search',
      data: {'page': page, 'pageSize': pageSize, 'info': info},
    );
    return ApiResponseParser.object(response, FirewallForwardPage.fromJson);
  }

  Future<void> operateForwardRule(
    List<Map<String, dynamic>> rules, {
    bool import = false,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/forward/operate',
      data: {'rules': rules, if (import) 'import': true},
    );
    await _awaitTask(
      ApiResponseParser.object(response, FirewallTaskResult.fromJson),
    );
  }

  Future<void> enableForwarding() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/forward/enable',
      data: const {},
    );
    await _awaitTask(
      ApiResponseParser.object(response, FirewallTaskResult.fromJson),
    );
  }

  Future<DockerGuardInfo> getDockerGuard() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/docker/ports',
    );
    return ApiResponseParser.object(response, DockerGuardInfo.new);
  }

  Future<List<DockerGuardEndpoint>> getDockerEndpoints() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/docker/endpoints',
    );
    return ApiResponseParser.list(response, DockerGuardEndpoint.new);
  }

  Future<void> operateDockerGuard(String operation) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/docker/operate',
      data: {'operation': operation},
    );
    await _awaitTask(
      ApiResponseParser.object(response, FirewallTaskResult.fromJson),
    );
  }

  Future<List<Map<String, dynamic>>> listRuleBackups() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/rules/backups',
      query: const {'subsystem': 'system'},
    );
    final data = ApiResponseParser.map(response);
    final files = data['files'];
    if (files is! List) return const [];
    return files.whereType<Map>().map(_fileMap).toList(growable: false);
  }

  Future<String> getNativeRuleDetail({
    required String provider,
    required String nativeKind,
    required String name,
    required bool permanent,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/rules/native/detail',
      data: {
        'provider': provider,
        'nativeKind': nativeKind,
        'name': name,
        'permanent': permanent,
      },
    );
    return ApiResponseParser.primitive<String>(response);
  }

  Future<void> resetRules({String? backupFile}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/firewall/rules/reset',
      data: {if (backupFile != null) 'backupFile': backupFile},
    );
    ApiResponseParser.ok(response);
  }

  Future<void> _awaitTask(FirewallTaskResult task) async {
    if (!task.queued || task.taskID.isEmpty) return;
    for (var attempt = 0; attempt < 20; attempt++) {
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v2/logs/tasks/read',
        data: {
          'taskID': task.taskID,
          'page': 1,
          'pageSize': 200,
          'latest': true,
        },
      );
      final log = ApiResponseParser.object(response, TaskLogDto.fromJson);
      final status = log.taskStatus.toLowerCase();
      if (status == 'success') return;
      if (status == 'failed' || status == 'error') {
        final detail = log.lines.isEmpty ? '' : log.lines.last;
        throw StateError('防火墙任务执行失败 $detail'.trim());
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    throw StateError('防火墙任务仍在执行，请稍后刷新');
  }

  static Map<String, dynamic> _fileMap(Map<dynamic, dynamic> file) =>
      Map<String, dynamic>.from(file);

  static List<Map<String, dynamic>> scopesFor(String provider) {
    switch (provider) {
      case 'iptables':
      case 'nftables':
        return [
          for (final family in ['ipv4', 'ipv6'])
            for (final chain in [
              '1PANEL_BASIC_BEFORE',
              '1PANEL_BASIC',
              '1PANEL_BASIC_AFTER',
            ])
              {
                'provider': provider,
                'family': family,
                'table': 'filter',
                'chain': chain,
                'direction': 'input',
              },
        ];
      case 'firewalld':
        return [
          {
            'provider': provider,
            'family': 'inet',
            'zone': 'public',
            'direction': 'input',
          },
        ];
      case 'ufw':
        return [
          for (final family in ['ipv4', 'ipv6'])
            {
              'provider': provider,
              'family': family,
              'chain': 'incoming',
              'direction': 'input',
            },
        ];
      default:
        throw StateError('不支持的防火墙后端 $provider');
    }
  }

  static Map<String, dynamic> scopeFor(String provider, String family) {
    if (provider == 'iptables' || provider == 'nftables') {
      return {
        'provider': provider,
        'family': family,
        'table': 'filter',
        'chain': '1PANEL_BASIC',
        'direction': 'input',
      };
    }
    if (provider == 'firewalld') {
      return {
        'provider': provider,
        'family': 'inet',
        'zone': 'public',
        'direction': 'input',
      };
    }
    if (provider == 'ufw') {
      return {
        'provider': provider,
        'family': family,
        'chain': 'incoming',
        'direction': 'input',
      };
    }
    throw StateError('不支持的防火墙后端 $provider');
  }
}
