import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/website/website_group_dto.dart';

/// 分组 API。
///
/// 对应 1Panel `/groups` 相关接口。
class GroupApi {
  GroupApi(this._client);

  final DioClient _client;

  /// 查询指定类型的分组。
  Future<List<WebsiteGroupDto>> searchGroups({required String type}) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/groups/search',
      data: {'type': type},
    );
    return ApiResponseParser.list(resp, WebsiteGroupDto.fromJson);
  }

  /// 创建分组。
  Future<void> createGroup(WebsiteGroupDto group) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/groups',
      data: group.toJson(),
    );
  }

  /// 更新分组（含设为默认）。
  Future<void> updateGroup(WebsiteGroupDto group) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/groups/update',
      data: group.toJson(),
    );
  }

  /// 删除分组。
  Future<void> deleteGroup(int id) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/groups/del',
      data: {'id': id},
    );
  }
}
