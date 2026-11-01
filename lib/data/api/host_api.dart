import 'package:dio/dio.dart';

import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/common/page_result.dart';
import '../dto/host/disk_dto.dart';
import '../dto/host/host_diagnostics_dto.dart';
import '../dto/host/ssh_cert_dto.dart';
import '../dto/host/ssh_info_dto.dart';

/// 主机信息 API。
///
/// 对应 1Panel `/hosts` 相关接口。
class HostApi {
  HostApi(this._client);

  final DioClient _client;

  /// GET `/hosts/monitor/iooptions` - 获取可监控磁盘列表。
  Future<List<String>> getMonitorIoOptions() async {
    final resp = await _client.get<dynamic>('/api/v2/hosts/monitor/iooptions');
    return _optionsFromResponse(resp.data);
  }

  /// GET `/hosts/monitor/netoptions` - 获取可监控网卡列表。
  Future<List<String>> getMonitorNetOptions() async {
    final resp = await _client.get<dynamic>('/api/v2/hosts/monitor/netoptions');
    return _optionsFromResponse(resp.data);
  }

  /// GET /api/v2/hosts/monitor/setting
  Future<Map<String, dynamic>> getMonitorSetting() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/hosts/monitor/setting',
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/hosts/monitor/setting/update
  Future<void> updateMonitorSetting(String key, String value) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/monitor/setting/update',
      data: {'key': key, 'value': value},
    );
  }

  /// POST /api/v2/hosts/monitor/search
  Future<List<Map<String, dynamic>>> searchMonitor({
    String param = 'all',
    required DateTime startTime,
    required DateTime endTime,
    String io = 'all',
    String network = 'all',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/monitor/search',
      data: {
        'param': param,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'io': io,
        'network': network,
      },
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);
  }

  /// POST /api/v2/hosts/test/byinfo
  Future<bool> testHostConnection(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/test/byinfo',
      data: body,
    );
    return resp.data?['data'] == true;
  }

  /// POST /api/v2/hosts/ssh/search
  Future<SshInfoDto> getSshInfo() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/search',
      data: const {},
    );
    return ApiResponseParser.object(resp, SshInfoDto.fromJson);
  }

  /// POST /api/v2/hosts/ssh/operate
  Future<void> operateSsh(String operation) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/operate',
      data: {'operation': operation},
    );
  }

  /// POST /api/v2/hosts/ssh/update — 按 key 更新单项 SSH 配置。
  Future<void> updateSsh(String key, String newValue) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/update',
      data: {'key': key, 'newValue': newValue},
    );
  }

  /// POST /api/v2/settings/ssh/check — 检查面板本地 SSH 连接是否可用。
  Future<bool> checkLocalSshConnection() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/settings/ssh/check',
      data: const {},
    );
    return resp.data?['data'] == true;
  }

  /// POST /api/v2/hosts/ssh/file — 读取 SSH 配置文件内容。
  ///
  /// [name] 为 `"sshd"` 或 `"authKeys"`。
  Future<String> loadSshFile(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/file',
      data: {'name': name},
    );
    return ApiResponseParser.primitive<String>(resp);
  }

  /// POST /api/v2/hosts/ssh/file/update — 写入 SSH 配置文件。
  Future<void> updateSshFile(String key, String path, String value) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/file/update',
      data: {'key': key, 'path': path, 'value': value},
    );
  }

  // ── SSH 证书/密钥管理 ──────────────────────────────────────────────────

  /// POST /api/v2/hosts/ssh/cert/search — 分页查询 SSH 密钥列表。
  Future<PageResult<SshCertDto>> searchCerts({
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/cert/search',
      data: {'page': page, 'pageSize': pageSize},
    );
    return PageResult<SshCertDto>.fromJson(
      ApiResponseParser.map(resp),
      SshCertDto.fromJson,
    );
  }

  /// POST /api/v2/hosts/ssh/cert — 创建 SSH 密钥。
  Future<void> createCert(SshCertOperateReq req) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/cert',
      data: req.toJson(),
    );
  }

  /// POST /api/v2/hosts/ssh/cert/update — 更新 SSH 密钥。
  Future<void> editCert(SshCertOperateReq req) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/cert/update',
      data: req.toJson(),
    );
  }

  /// POST /api/v2/hosts/ssh/cert/delete — 删除 SSH 密钥。
  Future<void> deleteCert(List<int> ids, {bool forceDelete = false}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/cert/delete',
      data: {'ids': ids, 'forceDelete': forceDelete},
    );
  }

  /// POST /api/v2/hosts/ssh/cert/sync — 同步磁盘密钥到数据库。
  Future<void> syncCert() async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/ssh/cert/sync',
      data: const {},
    );
  }

  // ── 终端会话 ──────────────────────────────────────────────────────────

  /// POST /api/v2/hosts/terminal/sessions/search
  Future<List<Map<String, dynamic>>> searchTerminalSessions() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/terminal/sessions/search',
      data: const {},
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);
  }

  /// POST /api/v2/hosts/terminal/sessions/close
  Future<void> closeTerminalSession(String id) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/terminal/sessions/close',
      data: {'id': id},
    );
  }

  /// POST /api/v2/hosts/terminal/sessions/closeAll
  Future<void> closeAllTerminalSessions() async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/terminal/sessions/closeAll',
      data: const {},
    );
  }

  // ── 磁盘与分区 ────────────────────────────────────────────────────────

  /// GET /api/v2/hosts/disks
  Future<CompleteDiskDto> listDisks() async {
    final resp = await _client.get<Map<String, dynamic>>('/api/v2/hosts/disks');
    return ApiResponseParser.object(resp, CompleteDiskDto.fromJson);
  }

  /// POST /api/v2/hosts/disks/mount
  Future<void> mountDisk(DiskMountReq req) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/disks/mount',
      data: req.toJson(),
    );
  }

  /// POST /api/v2/hosts/disks/partition
  Future<void> partitionDisk(DiskPartitionReq req) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/disks/partition',
      data: req.toJson(),
    );
  }

  /// POST /api/v2/hosts/disks/unmount
  Future<void> unmountDisk(String mountPoint) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/disks/unmount',
      data: {'mountPoint': mountPoint},
    );
  }

  // ── 运行时诊断 ────────────────────────────────────────────────────────

  /// GET /api/v2/hosts/diagnostics/summary
  Future<DiagnosticsSummaryDto> getDiagnosticsSummary() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/hosts/diagnostics/summary',
    );
    return ApiResponseParser.object(resp, DiagnosticsSummaryDto.fromJson);
  }

  /// GET /api/v2/hosts/diagnostics/goroutines
  Future<GoroutineSnapshotDto> getGoroutineSnapshot() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/hosts/diagnostics/goroutines',
    );
    return ApiResponseParser.object(resp, GoroutineSnapshotDto.fromJson);
  }

  /// GET /api/v2/hosts/components/:name — 检测主机组件。
  Future<ComponentInfoDto> getComponentInfo(String name) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/hosts/components/${Uri.encodeComponent(name)}',
    );
    return ApiResponseParser.object(resp, ComponentInfoDto.fromJson);
  }

  /// POST /api/v2/hosts/diagnostics/profiles — 返回 pprof 二进制内容。
  Future<List<int>> createDiagnosticsProfile({
    required String type,
    required int duration,
  }) async {
    final resp = await _client.post<List<int>>(
      '/api/v2/hosts/diagnostics/profiles',
      data: {'type': type, 'duration': duration},
      options: Options(responseType: ResponseType.bytes),
    );
    return resp.data ?? const [];
  }

  static List<String> _optionsFromResponse(Object? body) {
    final data = body is Map ? body['data'] : null;
    if (data is! List) return const [];

    return data
        .map((item) {
          if (item is Map) return item['option']?.toString();
          return item?.toString();
        })
        .whereType<String>()
        .where((option) => option.isNotEmpty)
        .toList(growable: false);
  }
}
