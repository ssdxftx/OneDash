import 'package:dio/dio.dart';

import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/host_tool/supervisor_dto.dart';

/// 主机工具 API（对应 1Panel `/hosts/tool` 相关接口）。
class HostToolApi {
  HostToolApi(this._client);

  final DioClient _client;

  Future<SupervisorToolStatus> getSupervisorStatus() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/tool/status',
      data: const {'type': 'supervisord'},
    );
    return ApiResponseParser.object(resp, SupervisorToolStatus.fromJson);
  }

  Future<void> operateSupervisor(String operate) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/tool/operate',
      data: {'type': 'supervisord', 'operate': operate},
    );
  }

  Future<void> initSupervisor({
    required String configPath,
    required String serviceName,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/tool/init',
      data: {
        'type': 'supervisord',
        'configPath': configPath,
        'serviceName': serviceName,
      },
    );
  }

  Future<String> operateSupervisorConfig({
    required String operate,
    String content = '',
  }) async {
    final path = switch (operate) {
      'get' => '/api/v2/hosts/tool/config/get',
      'set' => '/api/v2/hosts/tool/config/set',
      _ => throw ArgumentError.value(operate, 'operate'),
    };
    final resp = await _client.post<Map<String, dynamic>>(
      path,
      data: {'type': 'supervisord', if (operate == 'set') 'content': content},
    );
    if (operate == 'set') {
      ApiResponseParser.ok(resp);
      return '';
    }
    final data = ApiResponseParser.map(resp);
    return data['content'] as String? ?? '';
  }

  Future<List<SupervisorProcessConfig>> getSupervisorProcesses() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/hosts/tool/supervisor/process',
      options: Options(
        sendTimeout: const Duration(minutes: 3),
        receiveTimeout: const Duration(minutes: 3),
      ),
    );
    return ApiResponseParser.list(resp, SupervisorProcessConfig.fromJson);
  }

  Future<void> submitSupervisorProcess(
    SupervisorProcessConfig config, {
    required String operate,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/tool/supervisor/process',
      data: config.toSubmitJson(operate),
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

  Future<void> operateSupervisorProcess({
    required String name,
    required String operate,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/hosts/tool/supervisor/process',
      data: {'name': name, 'operate': operate},
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

  Future<String> operateSupervisorProcessFile({
    required String name,
    required String file,
    required String operate,
    String content = '',
  }) async {
    final options = Options(
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    );
    final path = operate == 'get'
        ? '/api/v2/hosts/tool/supervisor/process/file/get'
        : '/api/v2/hosts/tool/supervisor/process/file';
    final resp = await _client.post<Map<String, dynamic>>(
      path,
      data: {
        'name': name,
        'file': file,
        if (operate != 'get') ...{
          'operate': operate,
          if (content.isNotEmpty || operate == 'update') 'content': content,
        },
      },
      options: options,
    );
    final data = resp.data?['data'];
    return data is String ? data : '';
  }
}
