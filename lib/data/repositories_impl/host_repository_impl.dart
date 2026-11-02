import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/host_repository.dart';
import '../api/host_api.dart';
import '../dto/host/disk_dto.dart';
import '../dto/host/host_diagnostics_dto.dart';
import '../dto/host/ssh_cert_dto.dart';
import '../dto/host/ssh_info_dto.dart';

class HostRepositoryImpl implements HostRepository {
  HostRepositoryImpl(this._api);

  final HostApi _api;

  @override
  Future<Map<String, dynamic>> getMonitorSetting() => _api.getMonitorSetting();

  @override
  Future<void> updateMonitorSetting(String key, String value) =>
      _api.updateMonitorSetting(key, value);

  @override
  Future<List<Map<String, dynamic>>> searchMonitor({
    String param = 'all',
    required DateTime startTime,
    required DateTime endTime,
  }) =>
      _api.searchMonitor(param: param, startTime: startTime, endTime: endTime);

  @override
  Future<SshInfoDto> getSshInfo() => _api.getSshInfo();

  @override
  Future<String> loadSshFile(String name) => _api.loadSshFile(name);

  @override
  Future<void> updateSshFile(String key, String path, String value) =>
      _api.updateSshFile(key, path, value);

  @override
  Future<void> updateSsh(String key, String newValue) =>
      _api.updateSsh(key, newValue);

  @override
  Future<void> operateSsh(String operation) => _api.operateSsh(operation);

  @override
  Future<bool> checkLocalSshConnection() => _api.checkLocalSshConnection();

  @override
  Future<bool> testHostConnection(Map<String, dynamic> body) =>
      _api.testHostConnection(body);

  @override
  Future<List<SshCertDto>> searchSshCerts() async {
    final page = await _api.searchCerts(pageSize: 100);
    return page.items;
  }

  @override
  Future<void> createSshCert(SshCertOperateReq req) => _api.createCert(req);

  @override
  Future<void> editSshCert(SshCertOperateReq req) => _api.editCert(req);

  @override
  Future<void> deleteSshCert(int id) => _api.deleteCert([id]);

  @override
  Future<void> syncSshCerts() => _api.syncCert();

  @override
  Future<List<Map<String, dynamic>>> searchTerminalSessions() =>
      _api.searchTerminalSessions();

  @override
  Future<void> closeTerminalSession(String id) => _api.closeTerminalSession(id);

  @override
  Future<void> closeAllTerminalSessions() => _api.closeAllTerminalSessions();

  @override
  Future<CompleteDiskDto> getDisks() => _api.listDisks();

  @override
  Future<void> mountDisk(DiskMountReq req) => _api.mountDisk(req);

  @override
  Future<void> partitionDisk(DiskPartitionReq req) => _api.partitionDisk(req);

  @override
  Future<void> unmountDisk(String mountPoint) => _api.unmountDisk(mountPoint);

  @override
  Future<DiagnosticsSummaryDto> getDiagnosticsSummary() =>
      _api.getDiagnosticsSummary();

  @override
  Future<GoroutineSnapshotDto> getGoroutineSnapshot() =>
      _api.getGoroutineSnapshot();

  @override
  Future<List<int>> createDiagnosticsProfile({
    required String type,
    required int duration,
  }) => _api.createDiagnosticsProfile(type: type, duration: duration);

  @override
  Future<ComponentInfoDto> getComponentInfo(String name) =>
      _api.getComponentInfo(name);
}

final hostRepositoryProvider = FutureProvider.autoDispose
    .family<HostRepository, int>((ref, serverId) async {
      final client = await ref.watch(dioClientProvider(serverId).future);
      return HostRepositoryImpl(HostApi(client));
    }, name: 'hostRepositoryProvider');
