import 'dart:convert';

import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';

/// 工具箱 API（对应 1Panel `/toolbox` 相关接口）。
class ToolboxApi {
  ToolboxApi(this._client);

  final DioClient _client;

  /// POST /api/v2/toolbox/device/base
  Future<Map<String, dynamic>> getDeviceBase() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/device/base',
      data: const {},
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/toolbox/scan
  Future<Map<String, dynamic>> scanClean() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/scan',
      data: const {},
    );
    return ApiResponseParser.map(resp);
  }

  /// GET /api/v2/toolbox/fail2ban/base
  Future<Map<String, dynamic>> getFail2banBase() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/toolbox/fail2ban/base',
    );
    return ApiResponseParser.map(resp);
  }

  /// GET /api/v2/toolbox/ftp/base
  Future<Map<String, dynamic>> getFtpBase() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/toolbox/ftp/base',
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/toolbox/clam/base
  Future<Map<String, dynamic>> getClamBase() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/base',
      data: const {},
    );
    return ApiResponseParser.map(resp);
  }

  /// GET /api/v2/toolbox/device/zone/options
  Future<List<String>> getZoneOptions() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/toolbox/device/zone/options',
    );
    return ApiResponseParser.primitiveList<String>(resp);
  }

  /// POST /api/v2/toolbox/device/update/conf
  Future<void> updateDeviceConf(String key, String value) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/device/update/conf',
      data: {'key': key, 'value': value},
    );
  }

  /// POST /api/v2/toolbox/device/update/swap
  Future<void> updateSwap({
    required String path,
    required int size,
    bool isNew = true,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/device/update/swap',
      data: {'path': path, 'size': size, 'isNew': isNew},
    );
  }

  /// POST /api/v2/toolbox/fail2ban/search
  Future<List<String>> searchFail2ban(String status) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/fail2ban/search',
      data: {'status': status},
    );
    return ApiResponseParser.primitiveList<String>(resp);
  }

  /// POST /api/v2/toolbox/fail2ban/operate
  Future<void> operateFail2ban(String operation) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/fail2ban/operate',
      data: {'operation': operation},
    );
  }

  /// POST /api/v2/toolbox/fail2ban/operate/sshd
  Future<void> operateFail2banSshd(List<String> ips, String operate) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/fail2ban/operate/sshd',
      data: {'ips': ips, 'operate': operate},
    );
  }

  /// POST /api/v2/toolbox/fail2ban/update — 更新单条基础配置。
  Future<void> updateFail2banConf(String key, String value) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/fail2ban/update',
      data: {'key': key, 'value': value},
    );
  }

  /// POST /api/v2/toolbox/ftp/search
  Future<List<Map<String, dynamic>>> searchFtp({
    int page = 1,
    int pageSize = 100,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/ftp/search',
      data: {'page': page, 'pageSize': pageSize},
    );
    final data = resp.data?['data'];
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList(growable: false);
    }
    return const [];
  }

  /// POST /api/v2/toolbox/ftp
  Future<void> createFtp({
    required String user,
    required String password,
    required String path,
    String description = '',
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/ftp',
      data: {
        'user': user,
        'password': base64Encode(utf8.encode(password)),
        'path': path,
        'description': description,
      },
    );
  }

  /// POST /api/v2/toolbox/ftp/del
  Future<void> deleteFtp(List<int> ids) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/ftp/del',
      data: {'ids': ids},
    );
  }

  /// POST /api/v2/toolbox/clam/search
  Future<List<Map<String, dynamic>>> searchClam({
    int page = 1,
    int pageSize = 100,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/search',
      data: {'page': page, 'pageSize': pageSize},
    );
    final data = resp.data?['data'];
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList(growable: false);
    }
    return const [];
  }

  /// POST /api/v2/toolbox/clam
  Future<void> createClam({
    required String name,
    required String path,
    String infectedStrategy = 'none',
    String infectedDir = '',
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam',
      data: {
        'name': name,
        'path': path,
        'infectedStrategy': infectedStrategy,
        'infectedDir': infectedDir,
        'spec': '',
        'specObj': <String, dynamic>{},
        'hasSpec': false,
        'timeout': 3600,
        'description': '',
      },
    );
  }

  /// POST /api/v2/toolbox/clam/operate
  Future<void> operateClam(String operation) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/operate',
      data: {'operation': operation},
    );
  }

  /// POST /api/v2/toolbox/clam/record/search
  Future<List<Map<String, dynamic>>> searchClamRecords({
    required int clamId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/record/search',
      data: {'page': page, 'pageSize': pageSize, 'clamID': clamId},
    );
    final data = resp.data?['data'];
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList(growable: false);
    }
    return const [];
  }

  /// POST /api/v2/toolbox/clam/handle
  Future<void> handleClam(int id) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/handle',
      data: {'id': id},
    );
  }

  /// 获取系统用户列表（读取 /etc/passwd）。
  Future<List<String>> loadUsers() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/toolbox/device/users',
    );
    return ApiResponseParser.primitiveList<String>(resp);
  }
}
