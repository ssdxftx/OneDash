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

  /// 删除前检查关联资源。
  /// GET /api/v2/runtimes/installed/delete/check/:id
  Future<List<Map<String, dynamic>>> checkRuntimeDelete(int id) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/runtimes/installed/delete/check/$id',
    );
    return ApiResponseParser.list(resp, (json) => json);
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

  /// GET /api/v2/runtimes/php/:id/extensions
  Future<Map<String, dynamic>> getPhpExtensions(int id) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/runtimes/php/$id/extensions',
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/runtimes/php/extensions/install
  Future<void> installPhpExtension(int id, String name, String taskId) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/extensions/install',
      data: {'ID': id, 'name': name, 'taskID': taskId},
    );
  }

  /// POST /api/v2/runtimes/php/extensions/uninstall
  Future<void> uninstallPhpExtension(int id, String name) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/extensions/uninstall',
      data: {'ID': id, 'name': name},
    );
  }

  /// POST /api/v2/runtimes/php/file
  Future<String> getPhpFile(int id, String type) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/file',
      data: {'id': id, 'type': type},
    );
    final data = resp.data?['data'];
    if (data is Map) return '${data['content'] ?? ''}';
    return '$data';
  }

  /// POST /api/v2/runtimes/php/update
  Future<void> updatePhpFile(int id, String type, String content) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/update',
      data: {'id': id, 'type': type, 'content': content},
    );
  }

  /// GET /api/v2/runtimes/php/fpm/status/:id
  Future<Map<String, dynamic>> getPhpConfig(int id) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/runtimes/php/config/$id',
    );
    return ApiResponseParser.map(resp);
  }

  Future<void> updatePhpConfig({
    required int id,
    required String scope,
    Map<String, String> params = const {},
    List<String> disableFunctions = const [],
    String uploadMaxSize = '',
    String maxExecutionTime = '',
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/config',
      data: {
        'id': id,
        'scope': scope,
        'params': params,
        'disableFunctions': disableFunctions,
        'uploadMaxSize': uploadMaxSize,
        'maxExecutionTime': maxExecutionTime,
      },
    );
  }

  Future<Map<String, dynamic>> getPhpContainer(int id) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/runtimes/php/container/$id',
    );
    return ApiResponseParser.map(resp);
  }

  Future<void> updatePhpContainer(Map<String, dynamic> body) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/container/update',
      data: body,
    );
  }

  Future<List<Map<String, dynamic>>> getFpmStatus(int id) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/runtimes/php/fpm/status/$id',
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);
  }

  /// GET /api/v2/runtimes/php/fpm/config/:id
  Future<Map<String, dynamic>> getFpmConfig(int id) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/runtimes/php/fpm/config/$id',
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/runtimes/php/fpm/config
  Future<void> updateFpmConfig(int id, Map<String, dynamic> params) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/fpm/config',
      data: {'id': id, 'params': params},
    );
  }

  /// POST /api/v2/runtimes/node/modules
  Future<List<Map<String, dynamic>>> getNodeModules(int id) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/node/modules',
      data: {'ID': id},
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);
  }

  /// POST /api/v2/runtimes/node/modules/operate
  Future<void> operateNodeModule({
    required int id,
    required String operate,
    required String module,
    required String packageManager,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/node/modules/operate',
      data: {
        'ID': id,
        'operate': operate,
        'module': module,
        'pkgManager': packageManager,
      },
    );
  }

  /// 查询 PHP 扩展预设详情。
  /// POST /api/v2/runtimes/php/extensions/detail
  Future<Map<String, dynamic>> getPhpExtensionPreset(int id) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/extensions/detail',
      data: {'id': id},
    );
    return ApiResponseParser.map(resp);
  }

  /// 新建 PHP 扩展预设。
  /// POST /api/v2/runtimes/php/extensions
  Future<void> createPhpExtensionPreset({
    required String name,
    required String extensions,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/extensions',
      data: {'name': name, 'extensions': extensions},
    );
  }

  /// 更新 PHP 扩展预设。
  /// POST /api/v2/runtimes/php/extensions/update
  Future<void> updatePhpExtensionPreset({
    required int id,
    required String extensions,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/extensions/update',
      data: {'id': id, 'extensions': extensions},
    );
  }

  /// 删除 PHP 扩展预设。
  /// POST /api/v2/runtimes/php/extensions/del
  Future<void> deletePhpExtensionPreset(int id) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/extensions/del',
      data: {'id': id},
    );
  }

  /// 导入 PHP 扩展预设，返回 created/skipped。
  /// POST /api/v2/runtimes/php/extensions/import
  Future<String> importPhpExtensionPreset({
    required String name,
    required String extensions,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/extensions/import',
      data: {'name': name, 'extensions': extensions},
    );
    final data = resp.data?['data'];
    return data?.toString() ?? '';
  }

  /// 推送 PHP 扩展预设到多节点。
  /// POST /api/v2/runtimes/php/extensions/push
  Future<void> pushPhpExtensionPreset({
    required int id,
    required String sourceNode,
    required List<String> targetNodes,
    required String taskID,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/php/extensions/push',
      data: {
        'id': id,
        'sourceNode': sourceNode,
        'targetNodes': targetNodes,
        'taskID': taskID,
      },
    );
  }

  /// 更新运行时备注。
  /// POST /api/v2/runtimes/remark
  Future<void> updateRuntimeRemark(int id, String remark) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/remark',
      data: {'id': id, 'remark': remark},
    );
  }

  /// 查询 PHP 运行时 Supervisor 进程。
  /// GET /api/v2/runtimes/supervisor/process/:id
  Future<List<Map<String, dynamic>>> getSupervisorProcesses(int id) async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/runtimes/supervisor/process/$id',
    );
    return ApiResponseParser.list(resp, (json) => json);
  }

  /// 操作 PHP 运行时 Supervisor 进程。
  /// POST /api/v2/runtimes/supervisor/process
  Future<void> operateSupervisorProcess(
    int id,
    Map<String, dynamic> body,
  ) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/supervisor/process',
      data: {'id': id, ...body},
    );
  }

  /// 读取或修改 Supervisor 进程文件。
  /// POST /api/v2/runtimes/supervisor/process/file
  Future<String> supervisorProcessFile({
    required int id,
    required String name,
    required String operate,
    required String file,
    String content = '',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/runtimes/supervisor/process/file',
      data: {
        'id': id,
        'name': name,
        'operate': operate,
        'file': file,
        'content': content,
      },
    );
    final data = resp.data?['data'];
    return data?.toString() ?? '';
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
