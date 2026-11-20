import 'package:dio/dio.dart';

import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/entities/os_info.dart';
import '../dto/dashboard/dashboard_dto.dart';
import '../dto/host/os_info_dto.dart';

/// 仪表盘 API。
///
/// 对应 1Panel `/dashboard` 相关接口。
class DashboardApi {
  DashboardApi(this._client);

  final DioClient _client;

  static const _dashboardTimeout = Duration(seconds: 15);

  /// 获取主机基础信息 + 当前指标。
  ///
  /// [ioOption] / [netOption] 控制返回的 IO / 网络粒度，默认 `all`。
  /// base / current 并行请求，避免串行带来的双倍网络延迟。
  Future<Dashboard> getDashboard({
    String ioOption = 'all',
    String netOption = 'all',
  }) async {
    final responses = await Future.wait([
      _client.get<Map<String, dynamic>>(
        '/api/v2/dashboard/base/$ioOption/$netOption',
        options: Options(receiveTimeout: _dashboardTimeout),
      ),
      _client.get<Map<String, dynamic>>(
        '/api/v2/dashboard/current/$ioOption/$netOption',
        options: Options(receiveTimeout: _dashboardTimeout),
      ),
    ]);

    return DashboardDto.parse(
      baseJson: ApiResponseParser.map(responses[0]),
      currentJson: ApiResponseParser.map(responses[1]),
    );
  }

  /// GET /api/v2/dashboard/base/os
  Future<OsInfo> getOsInfo({CancelToken? cancelToken}) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/base/os',
      cancelToken: cancelToken,
    );
    return ApiResponseParser.object(resp, OsInfoDto.fromJson).toEntity();
  }

  /// 获取主机基础信息快照。
  ///
  /// 1Panel 的 `/dashboard/base/:ioOption/:netOption` 响应里包含
  /// `currentInfo`，服务器列表卡片只需要这一份轻量快照，避免额外请求
  /// `/dashboard/current/:ioOption/:netOption`。
  Future<Dashboard> getDashboardSnapshot({
    String ioOption = 'all',
    String netOption = 'all',
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/base/$ioOption/$netOption',
      options: Options(receiveTimeout: _dashboardTimeout),
    );
    return DashboardDto.parse(baseJson: ApiResponseParser.map(resp));
  }

  /// 获取主机基础信息。
  Future<DashboardBase> getDashboardBase({
    String ioOption = 'all',
    String netOption = 'all',
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/base/$ioOption/$netOption',
      options: Options(receiveTimeout: _dashboardTimeout),
    );
    return DashboardDto.parseBase(ApiResponseParser.map(resp));
  }

  /// GET /api/v2/dashboard/quick/option
  Future<List<Map<String, dynamic>>> getQuickOptions() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/quick/option',
    );
    return _maps(resp);
  }

  /// POST /api/v2/dashboard/quick/change
  Future<void> changeQuick(List<Map<String, dynamic>> quicks) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/dashboard/quick/change',
      data: {'quicks': quicks},
    );
  }

  /// GET /api/v2/dashboard/quick/directory
  Future<List<Map<String, dynamic>>> getQuickDirectories() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/quick/directory',
    );
    return _maps(resp);
  }

  /// POST /api/v2/dashboard/quick/directory
  Future<void> createQuickDirectory({
    required String path,
    String alias = '',
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/dashboard/quick/directory',
      data: {'path': path, 'alias': alias},
    );
  }

  /// POST /api/v2/dashboard/quick/directory/update
  Future<void> updateQuickDirectory({
    required int id,
    required String path,
    String alias = '',
    bool legacy = false,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/dashboard/quick/directory/update',
      data: {'id': id, 'path': path, 'alias': alias, 'legacy': legacy},
    );
  }

  /// POST /api/v2/dashboard/quick/directory/del
  Future<void> deleteQuickDirectory({
    required int id,
    bool legacy = false,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/dashboard/quick/directory/del',
      data: {'id': id, 'legacy': legacy},
    );
  }

  /// GET /api/v2/dashboard/app/launcher
  Future<List<Map<String, dynamic>>> getAppLauncher() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/app/launcher',
    );
    return _maps(resp);
  }

  /// POST /api/v2/dashboard/app/launcher/option
  Future<List<Map<String, dynamic>>> getAppLauncherOptions({
    String filter = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/dashboard/app/launcher/option',
      data: {'filter': filter},
    );
    return _maps(resp);
  }

  /// POST /api/v2/dashboard/app/launcher/show
  Future<void> updateAppLauncherShow({
    required String key,
    required bool show,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/dashboard/app/launcher/show',
      data: {'key': key, 'value': show ? 'Enable' : 'Disable'},
    );
  }

  /// GET /api/v2/dashboard/current/top/cpu
  Future<List<Map<String, dynamic>>> getTopCpu() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/current/top/cpu',
    );
    return _maps(resp);
  }

  /// GET /api/v2/dashboard/current/top/mem
  Future<List<Map<String, dynamic>>> getTopMem() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/current/top/mem',
    );
    return _maps(resp);
  }

  /// GET /api/v2/dashboard/current/node
  Future<Map<String, dynamic>> getNodeCurrent() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/current/node',
    );
    return ApiResponseParser.map(resp);
  }

  /// 重启服务器、面板或面板代理。
  ///
  /// [operation] 取值 `system`、`1panel`、`1panel-agent`。
  Future<void> restartSystem(String operation) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/dashboard/system/restart/$operation',
    );
  }

  /// 获取实时指标。
  Future<DashboardCurrent> getDashboardCurrent({
    String ioOption = 'all',
    String netOption = 'all',
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/current/$ioOption/$netOption',
      options: Options(receiveTimeout: _dashboardTimeout),
    );
    return DashboardDto.parseCurrent(ApiResponseParser.map(resp));
  }

  static List<Map<String, dynamic>> _maps(Response<dynamic> response) {
    final data = response.data is Map ? (response.data as Map)['data'] : null;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false);
  }
}
