import '../../data/dto/firewall/firewall_base_info_dto.dart';
import '../../data/dto/firewall/firewall_v2_dto.dart';

abstract interface class FirewallRepository {
  Future<FirewallBaseInfoDto> getBaseInfo();

  Future<FirewallSettingsInfo> getSettings();

  Future<FirewallInventory> searchRules({
    required String provider,
    int page,
    int pageSize,
    String info,
    List<String> families,
    List<String> actions,
    bool refresh,
  });

  Future<void> createRule(Map<String, dynamic> rule);

  Future<void> deleteRule(FirewallRuleItem item);

  Future<void> updateRule(
    FirewallRuleItem item, {
    Map<String, dynamic>? rule,
    String? description,
    int? orderIndex,
    int? priority,
  });

  Future<void> reorderRule(
    FirewallRuleItem item, {
    int? targetPosition,
    int? priority,
  });

  Future<void> operate(String operation, {bool withDockerRestart});

  Future<void> updateIPv6(bool enabled);

  Future<void> operateBackend({
    required String subsystem,
    required String backend,
    required String operation,
  });

  Future<void> createWhitelist(FirewallWhitelistRule rule);

  Future<void> updateWhitelist({
    required FirewallWhitelistRule oldRule,
    required FirewallWhitelistRule rule,
  });

  Future<void> deleteWhitelist(FirewallWhitelistRule rule);

  Future<FirewallBaseInfoDto> getForwardBase();

  Future<FirewallForwardPage> searchForwardRules({
    int page,
    int pageSize,
    String info,
  });

  Future<void> operateForwardRule(
    List<Map<String, dynamic>> rules, {
    bool import,
  });

  Future<void> enableForwarding();

  Future<DockerGuardInfo> getDockerGuard();

  Future<List<DockerGuardEndpoint>> getDockerEndpoints();

  Future<void> operateDockerGuard(String operation);

  Future<List<Map<String, dynamic>>> listRuleBackups();

  Future<String> getNativeRuleDetail({
    required String provider,
    required String nativeKind,
    required String name,
    required bool permanent,
  });

  Future<void> resetRules({String? backupFile});

  Future<List<Map<String, dynamic>>> getListeningProcesses();
}
