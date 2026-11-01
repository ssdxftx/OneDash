import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/firewall_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/firewall_api.dart';
import '../api/process_api.dart';
import '../dto/firewall/firewall_base_info_dto.dart';
import '../dto/firewall/firewall_v2_dto.dart';

part 'firewall_repository_impl.g.dart';

class FirewallRepositoryImpl implements FirewallRepository {
  FirewallRepositoryImpl(this._api, this._processApi);

  final FirewallApi _api;
  final ProcessApi _processApi;

  @override
  Future<FirewallBaseInfoDto> getBaseInfo() => _api.getBaseInfo();

  @override
  Future<FirewallSettingsInfo> getSettings() => _api.getSettings();

  @override
  Future<FirewallInventory> searchRules({
    required String provider,
    int page = 1,
    int pageSize = 100,
    String info = '',
    List<String> families = const [],
    List<String> actions = const [],
    bool refresh = false,
  }) => _api.searchRules(
    provider: provider,
    page: page,
    pageSize: pageSize,
    info: info,
    families: families,
    actions: actions,
    refresh: refresh,
  );

  @override
  Future<void> createRule(Map<String, dynamic> rule) =>
      _api.createRules([rule]);

  @override
  Future<void> deleteRule(FirewallRuleItem item) => _api.deleteRules([item]);

  @override
  Future<void> updateRule(
    FirewallRuleItem item, {
    Map<String, dynamic>? rule,
    String? description,
    int? orderIndex,
    int? priority,
  }) => _api.updateRule(
    item,
    rule: rule,
    description: description,
    orderIndex: orderIndex,
    priority: priority,
  );

  @override
  Future<void> reorderRule(
    FirewallRuleItem item, {
    int? targetPosition,
    int? priority,
  }) => _api.reorderRule(
    item,
    targetPosition: targetPosition,
    priority: priority,
  );

  @override
  Future<void> operate(String operation, {bool withDockerRestart = false}) =>
      _api.operate(operation, withDockerRestart: withDockerRestart);

  @override
  Future<void> updateIPv6(bool enabled) => _api.updateIPv6(enabled);

  @override
  Future<void> operateBackend({
    required String subsystem,
    required String backend,
    required String operation,
  }) => _api.operateBackend(
    subsystem: subsystem,
    backend: backend,
    operation: operation,
  );

  @override
  Future<void> createWhitelist(FirewallWhitelistRule rule) =>
      _api.createWhitelist(rule);

  @override
  Future<void> updateWhitelist({
    required FirewallWhitelistRule oldRule,
    required FirewallWhitelistRule rule,
  }) => _api.updateWhitelist(oldRule: oldRule, rule: rule);

  @override
  Future<void> deleteWhitelist(FirewallWhitelistRule rule) =>
      _api.deleteWhitelist(rule);

  @override
  Future<FirewallBaseInfoDto> getForwardBase() => _api.getForwardBase();

  @override
  Future<FirewallForwardPage> searchForwardRules({
    int page = 1,
    int pageSize = 100,
    String info = '',
  }) => _api.searchForwardRules(page: page, pageSize: pageSize, info: info);

  @override
  Future<void> operateForwardRule(
    List<Map<String, dynamic>> rules, {
    bool import = false,
  }) => _api.operateForwardRule(rules, import: import);

  @override
  Future<void> enableForwarding() => _api.enableForwarding();

  @override
  Future<DockerGuardInfo> getDockerGuard() => _api.getDockerGuard();

  @override
  Future<List<DockerGuardEndpoint>> getDockerEndpoints() =>
      _api.getDockerEndpoints();

  @override
  Future<void> operateDockerGuard(String operation) =>
      _api.operateDockerGuard(operation);

  @override
  Future<List<Map<String, dynamic>>> listRuleBackups() =>
      _api.listRuleBackups();

  @override
  Future<String> getNativeRuleDetail({
    required String provider,
    required String nativeKind,
    required String name,
    required bool permanent,
  }) => _api.getNativeRuleDetail(
    provider: provider,
    nativeKind: nativeKind,
    name: name,
    permanent: permanent,
  );

  @override
  Future<void> resetRules({String? backupFile}) =>
      _api.resetRules(backupFile: backupFile);

  @override
  Future<List<Map<String, dynamic>>> getListeningProcesses() =>
      _processApi.getListeningProcesses();
}

@Riverpod()
Future<FirewallRepository> firewallRepository(Ref ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return FirewallRepositoryImpl(FirewallApi(client), ProcessApi(client));
}
