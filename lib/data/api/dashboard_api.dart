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

  /// 获取主机基础信息 + 当前指标。
  ///
  /// [ioOption] / [netOption] 控制返回的 IO / 网络粒度，默认 `all`。
  /// base / current 并行请求，避免串行带来的双倍网络延迟。
  Future<Dashboard> getDashboard({
    String ioOption = 'all',
    String netOption = 'all',
  }) async {
    final (baseResp, currentResp) = await (
      _client.get<Map<String, dynamic>>(
        '/api/v2/dashboard/base/$ioOption/$netOption',
      ),
      _client.get<Map<String, dynamic>>(
        '/api/v2/dashboard/current/$ioOption/$netOption',
      ),
    ).wait;

    return DashboardDto.parse(
      baseJson: ApiResponseParser.map(baseResp),
      currentJson: ApiResponseParser.map(currentResp),
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
    );
    return DashboardDto.parseBase(ApiResponseParser.map(resp));
  }

  /// 获取实时指标。
  Future<DashboardCurrent> getDashboardCurrent({
    String ioOption = 'all',
    String netOption = 'all',
  }) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/dashboard/current/$ioOption/$netOption',
    );
    return DashboardDto.parseCurrent(ApiResponseParser.map(resp));
  }
}
