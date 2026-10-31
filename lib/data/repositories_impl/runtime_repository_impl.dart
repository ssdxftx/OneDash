import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/runtime_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/file_api.dart';
import '../api/runtime_api.dart';
import '../dto/common/page_result.dart';
import '../dto/common/task_log_dto.dart';
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
  Future<TaskLogDto> readRuntimeLog({required int id, required String type}) =>
      _fileApi.readRuntimeLog(id: id, type: type);
}

/// 基于当前激活服务器的仓库 Provider。
@Riverpod()
Future<RuntimeRepository> runtimeRepository(Ref ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return RuntimeRepositoryImpl(RuntimeApi(client), FileApi(client));
}
