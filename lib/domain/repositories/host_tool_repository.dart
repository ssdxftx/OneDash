import '../../data/dto/host_tool/supervisor_dto.dart';

abstract interface class HostToolRepository {
  Future<SupervisorToolStatus> getSupervisorStatus();
  Future<void> operateSupervisor(String operate);
  Future<String> supervisorConfig({required String operate, String content});
  Future<String> supervisorProcessFile({
    required String name,
    required String file,
    required String operate,
    String content,
  });
  Future<void> initSupervisor({
    required String configPath,
    required String serviceName,
  });
  Future<List<SupervisorProcessConfig>> getSupervisorProcesses();
  Future<void> submitSupervisorProcess(
    SupervisorProcessConfig config, {
    required String operate,
  });
  Future<void> operateSupervisorProcess({
    required String name,
    required String operate,
  });
}
