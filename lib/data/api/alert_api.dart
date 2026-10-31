import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/alert/alert_dto.dart';
import '../dto/common/page_result.dart';

class AlertApi {
  AlertApi(this._client);

  final DioClient _client;

  /// 搜索告警列表。
  Future<PageResult<AlertInfo>> searchAlerts(AlertSearchReq req) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/alert/search',
      data: req.toJson(),
    );
    return PageResult<AlertInfo>.fromJson(
      ApiResponseParser.map(resp),
      AlertInfo.fromJson,
    );
  }

  /// 创建告警。
  Future<void> createAlert(AlertCreateReq req) async {
    await _client.post('/api/v2/alert', data: req.toJson());
  }

  /// 更新告警。
  Future<void> updateAlert(int id, AlertCreateReq req) async {
    await _client.post(
      '/api/v2/alert/update',
      data: {...req.toJson(), 'id': id},
    );
  }

  /// 删除告警。
  Future<void> deleteAlert(int id) async {
    await _client.post('/api/v2/alert/del', data: {'id': id});
  }

  /// 启用/禁用告警。
  Future<void> updateAlertStatus(int id, String status) async {
    await _client.post(
      '/api/v2/alert/status',
      data: {'id': id, 'status': status},
    );
  }

  /// 搜索告警日志。
  Future<PageResult<AlertLogInfo>> searchAlertLogs(
    AlertLogSearchReq req,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/alert/logs/search',
      data: req.toJson(),
    );
    return PageResult<AlertLogInfo>.fromJson(
      ApiResponseParser.map(resp),
      AlertLogInfo.fromJson,
    );
  }

  /// 清空告警日志。
  Future<void> cleanAlertLogs() async {
    await _client.post('/api/v2/alert/logs/clean');
  }

  /// 获取告警配置。
  Future<AlertConfigInfo> getAlertConfig() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/alert/config/info',
    );
    return ApiResponseParser.object(resp, AlertConfigInfo.fromJson);
  }

  /// 更新告警配置。
  Future<void> updateAlertConfig(AlertConfigUpdateReq req) async {
    await _client.post('/api/v2/alert/config/update', data: req.toJson());
  }

  /// 测试告警配置。
  Future<bool> testAlertConfig(AlertConfigTestReq req) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/alert/config/test',
      data: req.toJson(),
    );
    return ApiResponseParser.primitive<bool>(resp);
  }

  /// 删除告警配置。
  Future<void> deleteAlertConfig(int id) async {
    await _client.post('/api/v2/alert/config/del', data: {'id': id});
  }

  /// 获取磁盘列表。
  Future<List<Map<String, dynamic>>> listDisks() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/alert/disks/list',
    );
    final data = resp.data?['data'];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
