import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/common/page_result.dart';
import '../dto/cronjob/cronjob_dto.dart';
import '../dto/cronjob/cronjob_form_data_dto.dart';

/// 计划任务 API。
///
/// 对应 1Panel `/cronjobs` 相关接口。
class CronjobApi {
  CronjobApi(this._client);

  final DioClient _client;

  /// 分页查询计划任务列表。
  Future<PageResult<CronjobDto>> searchCronjobs(
    Map<String, dynamic> req,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs/search',
      data: req,
    );
    return PageResult<CronjobDto>.fromJson(
      ApiResponseParser.map(resp),
      CronjobDto.fromJson,
    );
  }

  /// 创建计划任务。
  Future<void> createCronjob(CronjobCreateReq req) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs',
      data: req.toJson(),
    );
  }

  /// 查询计划任务详情。
  Future<CronjobDto> getCronjobInfo(int id) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs/load/info',
      data: {'id': id},
    );
    return CronjobDto.fromJson(ApiResponseParser.map(resp));
  }

  /// 更新计划任务。
  Future<void> updateCronjob(CronjobCreateReq req) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs/update',
      data: req.toJson(),
    );
  }

  /// 删除计划任务。
  Future<void> deleteCronjob(List<int> ids, {bool cleanData = false}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs/del',
      data: {'ids': ids, 'cleanData': cleanData},
    );
  }

  /// 更新计划任务状态（启用/禁用）。
  Future<void> updateStatus(int id, String status) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs/status',
      data: {'id': id, 'status': status},
    );
  }

  /// 手动触发执行一次。
  Future<void> handleOnce(int id) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs/handle',
      data: {'id': id},
    );
  }

  /// 停止正在执行的计划任务。
  Future<void> stopCronjob(int id) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs/stop',
      data: {'id': id},
    );
  }

  /// 分页查询执行记录。
  Future<PageResult<CronjobRecordDto>> searchRecords(
    Map<String, dynamic> req,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs/search/records',
      data: req,
    );
    return PageResult<CronjobRecordDto>.fromJson(
      ApiResponseParser.map(resp),
      CronjobRecordDto.fromJson,
    );
  }

  /// 读取执行记录日志。
  Future<String> getRecordLog(int recordId) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs/records/log',
      data: {'id': recordId},
    );
    try {
      return ApiResponseParser.primitive<String>(resp);
    } catch (_) {
      return '';
    }
  }

  /// 清理执行记录。
  Future<void> cleanRecords({
    required int cronjobID,
    bool cleanData = false,
    bool cleanRemoteData = false,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/cronjobs/records/clean',
      data: {
        'cronjobID': cronjobID,
        'cleanData': cleanData,
        'cleanRemoteData': cleanRemoteData,
      },
    );
  }

  // ── 表单数据加载 ──────────────────────────────────────────

  /// 获取脚本库选项。
  Future<List<ScriptOptionDto>> loadScriptOptions() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/cronjobs/script/options',
    );
    return ApiResponseParser.list(resp, ScriptOptionDto.fromJson);
  }
}
