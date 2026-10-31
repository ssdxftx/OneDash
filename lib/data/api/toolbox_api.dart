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

  /// 获取系统用户列表（读取 /etc/passwd）。
  Future<List<String>> loadUsers() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/toolbox/device/users',
    );
    return ApiResponseParser.primitiveList<String>(resp);
  }
}
