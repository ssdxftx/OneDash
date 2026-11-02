import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/runtime_repository.dart';
import '../dto/file/file_log_dto.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/file_api.dart';
import '../api/runtime_api.dart';
import '../dto/common/page_result.dart';
import '../dto/runtime/node_script_dto.dart';
import '../dto/runtime/runtime_dto.dart';

part 'runtime_repository_impl.g.dart';

/// [RuntimeRepository] 的默认实现。
class RuntimeRepositoryImpl implements RuntimeRepository {
  RuntimeRepositoryImpl(this._api, this._fileApi);

  final RuntimeApi _api;
  final FileApi _fileApi;

  @override
  Future<PageResult<RuntimeDto>> searchRuntimes(Map<String, dynamic> req) =>
      _api.searchRuntimes(req);

  @override
  Future<void> createRuntime(RuntimeCreateReq req) => _api.createRuntime(req);

  @override
  Future<RuntimeDetailDto> getRuntime(int id) => _api.getRuntime(id);

  @override
  Future<void> updateRuntime(RuntimeCreateReq req) => _api.updateRuntime(req);

  @override
  Future<void> deleteRuntime(int id, {bool forceDelete = false}) =>
      _api.deleteRuntime(id, forceDelete: forceDelete);

  @override
  Future<void> operateRuntime(int id, String operate) =>
      _api.operateRuntime(id, operate);

  @override
  Future<void> syncRuntimes() => _api.syncRuntimes();

  @override
  Future<List<PhpExtensionGroupDto>> searchPhpExtensions() async {
    final result = await _api.searchPhpExtensions();
    return result.items;
  }

  @override
  Future<List<NodeScriptDto>> getNodeScripts(String codeDir) =>
      _api.getNodeScripts(codeDir);

  @override
  Future<FileLogDto> readRuntimeLog({required int id, required String type}) =>
      _fileApi.readRuntimeLog(id: id, type: type);

  @override
  Future<Map<String, dynamic>> getPhpExtensions(int id) =>
      _api.getPhpExtensions(id);

  @override
  Future<void> installPhpExtension(int id, String name, String taskId) =>
      _api.installPhpExtension(id, name, taskId);

  @override
  Future<void> uninstallPhpExtension(int id, String name) =>
      _api.uninstallPhpExtension(id, name);

  @override
  Future<String> getPhpFile(int id, String type) => _api.getPhpFile(id, type);

  @override
  Future<void> updatePhpFile(int id, String type, String content) =>
      _api.updatePhpFile(id, type, content);

  @override
  Future<List<Map<String, dynamic>>> getFpmStatus(int id) =>
      _api.getFpmStatus(id);

  @override
  Future<Map<String, dynamic>> getFpmConfig(int id) => _api.getFpmConfig(id);

  @override
  Future<void> updateFpmConfig(int id, Map<String, dynamic> params) =>
      _api.updateFpmConfig(id, params);

  @override
  Future<List<Map<String, dynamic>>> getNodeModules(int id) =>
      _api.getNodeModules(id);

  @override
  Future<void> operateNodeModule({
    required int id,
    required String operate,
    required String module,
    required String packageManager,
  }) => _api.operateNodeModule(
    id: id,
    operate: operate,
    module: module,
    packageManager: packageManager,
  );
}

/// 基于当前激活服务器的仓库 Provider。
@Riverpod()
Future<RuntimeRepository> runtimeRepository(Ref ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return RuntimeRepositoryImpl(RuntimeApi(client), FileApi(client));
}
