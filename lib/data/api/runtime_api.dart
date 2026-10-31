import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../dto/common/page_result.dart';
import '../dto/runtime/node_script_dto.dart';
import '../dto/runtime/runtime_dto.dart';

/// 运行环境 API。
///
/// 对应 1Panel `/runtimes` 相关接口。
class RuntimeApi {
  RuntimeApi(this._client);

  final DioClient _client;

  /// 分页查询运行环境列表。
  Future<PageResult<RuntimeDto>> searchRuntimes(
    Map<String, dynamic> req,
  ) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/search',
      data: req,
    );
    return PageResult<RuntimeDto>.fromJson(
      ApiResponseParser.map(resp),
      RuntimeDto.fromJson,
    );
  }

  /// 创建运行环境。
  Future<void> createRuntime(RuntimeCreateReq req) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes',
      data: req.toJson(),
    );
  }

  /// 查询运行环境详情。
  Future<RuntimeDetailDto> getRuntime(int id) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/runtimes/$id',
    );
    return ApiResponseParser.object(resp, RuntimeDetailDto.fromJson);
  }

  /// 更新运行环境。
  Future<void> updateRuntime(RuntimeCreateReq req) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/update',
      data: req.toJson(),
    );
  }

  /// 删除运行环境。
  Future<void> deleteRuntime(int id, {bool forceDelete = false}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/del',
      data: {'id': id, 'forceDelete': forceDelete},
    );
  }

  /// 操作运行环境（启动/停止/重启）。
  ///
  /// [operate] 可选值: `up`, `down`, `restart`
  Future<void> operateRuntime(int id, String operate) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/operate',
      data: {'ID': id, 'operate': operate},
    );
  }

  /// 同步运行环境状态。
  Future<void> syncRuntimes() async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/sync',
      data: const {},
    );
  }

  /// 获取 Node.js 项目 package.json 中的 scripts 列表。
  Future<List<NodeScriptDto>> getNodeScripts(String codeDir) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/node/package',
      data: {'codeDir': codeDir},
    );
    return ApiResponseParser.list(resp, NodeScriptDto.fromJson);
  }

  /// 搜索 PHP 扩展预设组。
  Future<PageResult<PhpExtensionGroupDto>> searchPhpExtensions({
    int page = 1,
    int pageSize = 100,
    bool all = true,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/extensions/search',
      data: {'page': page, 'pageSize': pageSize, 'all': all},
    );
    return PageResult<PhpExtensionGroupDto>.fromJson(
      ApiResponseParser.map(resp),
      PhpExtensionGroupDto.fromJson,
    );
  }
}

class PhpExtensionGroupDto {
  const PhpExtensionGroupDto({
    required this.id,
    required this.name,
    required this.extensions,
  });

  final int id;
  final String name;
  final String extensions;

  factory PhpExtensionGroupDto.fromJson(Map<String, dynamic> json) {
    return PhpExtensionGroupDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      extensions: json['extensions'] as String? ?? '',
    );
  }
}
