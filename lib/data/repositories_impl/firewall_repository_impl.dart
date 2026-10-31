import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/firewall_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/firewall_api.dart';
import '../api/process_api.dart';
import '../dto/common/page_result.dart';
import '../dto/firewall/firewall_base_info_dto.dart';
import '../dto/firewall/rule_info_dto.dart';

part 'firewall_repository_impl.g.dart';

class FirewallRepositoryImpl implements FirewallRepository {
  FirewallRepositoryImpl(this._api, this._processApi);

  final FirewallApi _api;
  final ProcessApi _processApi;

  @override
  Future<FirewallBaseInfoDto> getBaseInfo() => _api.getBaseInfo();

  @override
  Future<PageResult<RuleInfoDto>> searchRules({
    required String type,
    int page = 1,
    int pageSize = 15,
    String info = '',
    String strategy = '',
  }) => _api.searchRules(
    type: type,
    page: page,
    pageSize: pageSize,
    info: info,
    strategy: strategy,
  );

  @override
  Future<void> operate(String operation, {bool withDockerRestart = false}) =>
      _api.operate(operation, withDockerRestart: withDockerRestart);

  @override
  Future<void> operatePortRule(Map<String, dynamic> body) =>
      _api.operatePortRule(body);

  @override
  Future<void> operateIpRule(Map<String, dynamic> body) =>
      _api.operateIpRule(body);

  @override
  Future<void> updatePortRule(Map<String, dynamic> body) =>
      _api.updatePortRule(body);

  @override
  Future<void> updateAddrRule(Map<String, dynamic> body) =>
      _api.updateAddrRule(body);

  @override
  Future<void> batchOperate(Map<String, dynamic> body) =>
      _api.batchOperate(body);

  @override
  Future<void> updateDescription(Map<String, dynamic> body) =>
      _api.updateDescription(body);

  @override
  Future<void> operateFilterChain({
    required String name,
    required String operate,
  }) => _api.operateFilterChain(name: name, operate: operate);

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
