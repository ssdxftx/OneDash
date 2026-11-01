import '../../data/dto/host/disk_dto.dart';
import '../../data/dto/host/host_diagnostics_dto.dart';
import '../../data/dto/host/ssh_cert_dto.dart';
import '../../data/dto/host/ssh_info_dto.dart';

abstract interface class HostRepository {
  Future<Map<String, dynamic>> getMonitorSetting();
  Future<void> updateMonitorSetting(String key, String value);
  Future<List<Map<String, dynamic>>> searchMonitor({
    String param,
    required DateTime startTime,
    required DateTime endTime,
  });
  Future<SshInfoDto> getSshInfo();
  Future<void> updateSsh(String key, String newValue);
  Future<bool> checkLocalSshConnection();
  Future<void> operateSsh(String operation);
  Future<bool> testHostConnection(Map<String, dynamic> body);
  Future<List<SshCertDto>> searchSshCerts();
  Future<void> createSshCert(SshCertOperateReq req);
  Future<void> deleteSshCert(int id);
  Future<List<Map<String, dynamic>>> searchTerminalSessions();
  Future<void> closeTerminalSession(String id);
  Future<void> closeAllTerminalSessions();
  Future<CompleteDiskDto> getDisks();
  Future<void> mountDisk(DiskMountReq req);
  Future<void> partitionDisk(DiskPartitionReq req);
  Future<void> unmountDisk(String mountPoint);
  Future<DiagnosticsSummaryDto> getDiagnosticsSummary();
  Future<GoroutineSnapshotDto> getGoroutineSnapshot();
  Future<List<int>> createDiagnosticsProfile({
    required String type,
    required int duration,
  });
  Future<ComponentInfoDto> getComponentInfo(String name);
}
