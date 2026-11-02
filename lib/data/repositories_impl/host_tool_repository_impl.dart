import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/host_tool_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/host_tool_api.dart';
import '../dto/host_tool/supervisor_dto.dart';

class HostToolRepositoryImpl implements HostToolRepository {
  HostToolRepositoryImpl(this._api);

  final HostToolApi _api;

  @override
  Future<SupervisorToolStatus> getSupervisorStatus() =>
      _api.getSupervisorStatus();

  @override
  Future<String> supervisorConfig({
    required String operate,
    String content = '',
  }) => _api.operateSupervisorConfig(operate: operate, content: content);

  @override
  Future<String> supervisorProcessFile({
    required String name,
    required String file,
    required String operate,
    String content = '',
  }) => _api.operateSupervisorProcessFile(
    name: name,
    file: file,
    operate: operate,
    content: content,
  );

  @override
  Future<void> operateSupervisor(String operate) =>
      _api.operateSupervisor(operate);

  @override
  Future<void> initSupervisor({
    required String configPath,
    required String serviceName,
  }) => _api.initSupervisor(configPath: configPath, serviceName: serviceName);

  @override
  Future<List<SupervisorProcessConfig>> getSupervisorProcesses() =>
      _api.getSupervisorProcesses();

  @override
  Future<void> submitSupervisorProcess(
    SupervisorProcessConfig config, {
    required String operate,
  }) => _api.submitSupervisorProcess(config, operate: operate);

  @override
  Future<void> operateSupervisorProcess({
    required String name,
    required String operate,
  }) => _api.operateSupervisorProcess(name: name, operate: operate);
}

final hostToolRepositoryProvider = FutureProvider<HostToolRepository>((
  ref,
) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return HostToolRepositoryImpl(HostToolApi(client));
}, dependencies: [activeServerIdProvider]);
