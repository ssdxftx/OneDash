import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/common/page_result.dart';
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

  /// GET /api/v2/hosts/disks
  Future<Map<String, dynamic>> listDisks() async {
    final resp = await _client.get<Map<String, dynamic>>('/api/v2/hosts/disks');
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/hosts/disks/unmount
  Future<void> unmountDisk(String mountPoint) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/disks/unmount',
      data: {'mountPoint': mountPoint},
    );
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
