import '../../data/dto/common/page_result.dart';
import '../../data/dto/firewall/firewall_base_info_dto.dart';
import '../../data/dto/firewall/rule_info_dto.dart';

abstract interface class FirewallRepository {
  Future<FirewallBaseInfoDto> getBaseInfo();

  Future<PageResult<RuleInfoDto>> searchRules({
    required String type,
    int page,
    int pageSize,
    String info,
    String strategy,
  });

  Future<void> operate(String operation, {bool withDockerRestart});

  Future<void> operatePortRule(Map<String, dynamic> body);

  Future<void> operateIpRule(Map<String, dynamic> body);

  Future<void> updatePortRule(Map<String, dynamic> body);

  Future<void> updateAddrRule(Map<String, dynamic> body);

  Future<void> batchOperate(Map<String, dynamic> body);

  Future<void> updateDescription(Map<String, dynamic> body);

  Future<void> operateFilterChain({
    required String name,
    required String operate,
  });

  Future<List<Map<String, dynamic>>> getListeningProcesses();
}
