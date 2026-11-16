import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';

/// 面板级 MCP 管理 API（core 服务）。
class McpApi {
  McpApi(this._client);

  final DioClient _client;

  static const _base = '/api/v2/core/mcp';

  Future<Map<String, dynamic>> getStatus() async {
    final resp = await _client.get<Map<String, dynamic>>('$_base/status');
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> getSettings() async {
    final resp = await _client.get<Map<String, dynamic>>('$_base/settings');
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/settings',
      data: body,
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> getCatalog() async {
    final resp = await _client.get<Map<String, dynamic>>('$_base/catalog');
    return ApiResponseParser.map(resp);
  }

  Future<List<Map<String, dynamic>>> getNodes() async {
    final resp = await _client.get<Map<String, dynamic>>('$_base/nodes');
    return ApiResponseParser.list(resp, (json) => json);
  }

  Future<Map<String, dynamic>> operateService(String operation) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/service/operate',
      data: {'operation': operation},
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> installService(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/service/install',
      data: body,
    );
    return ApiResponseParser.map(resp);
  }

  Future<String> getServiceLogs() async {
    final resp = await _client.get<Map<String, dynamic>>('$_base/service/logs');
    return '${ApiResponseParser.map(resp)['content'] ?? ''}';
  }

  Future<Map<String, dynamic>> getWebsiteStatus() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '$_base/website/status',
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> bindWebsite(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/website/bind',
      data: body,
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> updateWebsite(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/website/update',
      data: body,
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> unbindWebsite(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/website/unbind',
      data: body,
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> searchCredentials({
    int page = 1,
    int pageSize = 50,
    bool excludeRevoked = false,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/credentials/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        'excludeRevoked': excludeRevoked,
      },
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> createCredential(
    Map<String, dynamic> body,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/credentials/create',
      data: {'requestID': const Uuid().v4(), ...body},
    );
    return ApiResponseParser.map(resp);
  }

  Future<void> updateCredential(Map<String, dynamic> body) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/credentials/update',
      data: body,
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> setCredentialStatus({
    required String id,
    required int revision,
    required String status,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/credentials/status',
      data: {'id': id, 'revision': revision, 'status': status},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> revokeCredential({
    required String id,
    required int revision,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/credentials/revoke',
      data: {'id': id, 'revision': revision},
    );
    ApiResponseParser.ok(resp);
  }

  Future<void> deleteCredential({
    required String id,
    required int revision,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/credentials/delete',
      data: {'id': id, 'revision': revision},
    );
    ApiResponseParser.ok(resp);
  }

  Future<String> revealCredential({
    required String id,
    required int revision,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/credentials/reveal',
      data: {'id': id, 'revision': revision},
    );
    return '${ApiResponseParser.map(resp)['token'] ?? ''}';
  }

  Future<String> rotateCredential({
    required String id,
    required int revision,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/credentials/rotate',
      data: {'id': id, 'revision': revision},
    );
    return '${ApiResponseParser.map(resp)['token'] ?? ''}';
  }

  Future<Map<String, dynamic>> exportCredential({
    required String id,
    required int revision,
    required String client,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/credentials/export',
      data: {'id': id, 'revision': revision, 'client': client},
      options: Options(responseType: ResponseType.json),
    );
    return ApiResponseParser.map(resp);
  }

  Future<Map<String, dynamic>> searchInvocations({
    int page = 1,
    int pageSize = 50,
    String credentialId = '',
    String toolId = '',
    String status = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '$_base/invocations/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        'credentialId': credentialId,
        'toolId': toolId,
        'status': status,
      },
    );
    return ApiResponseParser.map(resp);
  }
}
