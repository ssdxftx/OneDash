import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_exceptions.dart';
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

  /// 分页搜索告警通知配置。
  /// POST /api/v2/alert/config/search
  Future<PageResult<AlertConfigInfo>> searchAlertConfigs(
    AlertConfigSearchReq req,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/alert/config/search',
      data: req.toJson(),
    );
    return PageResult<AlertConfigInfo>.fromJson(
      ApiResponseParser.map(resp),
      AlertConfigInfo.fromJson,
    );
  }

  /// 获取 Clam 扫描列表。
  /// GET /api/v2/alert/clams/list
  Future<List<ClamAlertInfo>> listClams() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/alert/clams/list',
    );
    return ApiResponseParser.list(resp, ClamAlertInfo.fromJson);
  }

  /// 获取计划任务告警列表。
  /// POST /api/v2/alert/cronjob/list
  Future<List<CronJobAlertInfo>> listAlertCronJobs({
    String name = '',
    String status = '',
    String type = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/alert/cronjob/list',
      data: {'name': name, 'status': status, 'type': type},
    );
    return ApiResponseParser.list(resp, CronJobAlertInfo.fromJson);
  }

  /// 获取已启用的告警通知配置。
  Future<List<AlertConfigInfo>> getAlertConfigs() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/alert/config/info',
      data: const <String, dynamic>{},
    );
    return ApiResponseParser.list(resp, AlertConfigInfo.fromJson);
  }

  /// 获取告警配置。
  Future<AlertConfigInfo> getAlertConfig() async {
    final configs = await getAlertConfigs();
    if (configs.isEmpty) {
      throw const ApiFormatException('没有可编辑的告警配置');
    }
    return configs.first;
  }

  /// 更新告警配置。
  /// POST /api/v2/alert/config/status
  Future<void> updateAlertConfigStatus(int id, String status) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/alert/config/status',
      data: {'id': id, 'status': status},
    );
  }

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
