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

  Future<String> loadDeviceConf(String name) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/device/conf',
      data: {'name': name},
    );
    return '${resp.data?['data'] ?? ''}';
  }

  Future<void> updateDeviceByFile({
    required String name,
    required String file,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/device/update/byconf',
      data: {'name': name, 'file': file},
    );
  }

  Future<void> updateDeviceHosts(List<Map<String, String>> hosts) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/device/update/host',
      data: hosts,
    );
  }

  Future<void> updateDevicePassword({
    required String user,
    required String password,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/device/update/passwd',
      data: {'user': user, 'passwd': base64Encode(utf8.encode(password))},
    );
  }

  Future<bool> checkDns({String key = 'form', required String value}) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/device/check/dns',
      data: {'key': key, 'value': value},
    );
    final data = resp.data?['data'];
    return data == true || data == 'true';
  }

  Future<void> cleanSystem(List<Map<String, dynamic>> items) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clean',
      data: items,
    );
  }

  Future<void> deleteClam({
    required List<int> ids,
    bool removeInfected = false,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/del',
      data: {'ids': ids, 'removeInfected': removeInfected},
    );
  }

  Future<void> cleanClamRecords(int id) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/record/clean',
      data: {'id': id},
    );
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
      data: {
        'page': page,
        'pageSize': pageSize,
        'orderBy': 'createdAt',
        'order': 'null',
      },
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

  /// GET /api/v2/toolbox/fail2ban/load/conf
  Future<String> loadFail2banConf() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/toolbox/fail2ban/load/conf',
    );
    return ApiResponseParser.primitive<String>(resp);
  }

  /// POST /api/v2/toolbox/fail2ban/update/byconf
  Future<void> updateFail2banByFile(String file) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/fail2ban/update/byconf',
      data: {'file': file},
    );
  }

  /// POST /api/v2/toolbox/ftp/operate
  Future<void> operateFtp(String operation) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/ftp/operate',
      data: {'operation': operation},
    );
  }

  /// POST /api/v2/toolbox/ftp/sync
  Future<void> syncFtp() async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/ftp/sync',
      data: {'ids': <int>[]},
    );
  }

  /// POST /api/v2/toolbox/ftp/update
  Future<void> updateFtp(Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data);
    final password = payload['password']?.toString() ?? '';
    if (password.isNotEmpty) {
      payload['password'] = base64Encode(utf8.encode(password));
    }
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/ftp/update',
      data: payload,
    );
  }

  /// POST /api/v2/toolbox/ftp/log/search
  Future<Map<String, dynamic>> searchFtpLogs({
    int page = 1,
    int pageSize = 50,
    String user = '',
    String operation = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/ftp/log/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        if (user.isNotEmpty) 'user': user,
        if (operation.isNotEmpty) 'operation': operation,
      },
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/toolbox/clam/search
  Future<List<Map<String, dynamic>>> searchClam({
    int page = 1,
    int pageSize = 100,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        'orderBy': 'createdAt',
        'order': 'null',
      },
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

  /// POST /api/v2/toolbox/clam/update
  Future<void> updateClam(Map<String, dynamic> data) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/update',
      data: data,
    );
  }

  /// POST /api/v2/toolbox/clam/status/update
  Future<void> updateClamStatus(int id, String status) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/status/update',
      data: {'id': id, 'status': status},
    );
  }

  /// POST /api/v2/toolbox/clam/file/search
  Future<String> loadClamFile(String name, {String tail = ''}) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/file/search',
      data: {'name': name, 'tail': tail},
    );
    return ApiResponseParser.primitive<String>(resp);
  }

  /// POST /api/v2/toolbox/clam/file/update
  Future<void> updateClamFile({
    required String name,
    required String file,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/toolbox/clam/file/update',
      data: {'name': name, 'file': file},
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
