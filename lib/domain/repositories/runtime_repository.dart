import '../../data/dto/file/file_log_dto.dart';
import '../../data/api/runtime_api.dart';
import '../../data/dto/common/page_result.dart';
import '../../data/dto/runtime/node_script_dto.dart';
import '../../data/dto/runtime/runtime_dto.dart';

/// 运行环境数据仓库接口。
abstract interface class RuntimeRepository {
  Future<PageResult<RuntimeDto>> searchRuntimes(Map<String, dynamic> req);
  Future<void> createRuntime(RuntimeCreateReq req);
  Future<RuntimeDetailDto> getRuntime(int id);
  Future<void> updateRuntime(RuntimeCreateReq req);
  Future<void> deleteRuntime(int id, {bool forceDelete = false});
  Future<void> operateRuntime(int id, String operate);
  Future<void> syncRuntimes();
  Future<List<PhpExtensionGroupDto>> searchPhpExtensions();
  Future<List<NodeScriptDto>> getNodeScripts(String codeDir);
  Future<FileLogDto> readRuntimeLog({required int id, required String type});
  Future<Map<String, dynamic>> getPhpExtensions(int id);
  Future<void> installPhpExtension(int id, String name, String taskId);
  Future<void> uninstallPhpExtension(int id, String name);
  Future<String> getPhpFile(int id, String type);
  Future<void> updatePhpFile(int id, String type, String content);
  Future<List<Map<String, dynamic>>> getFpmStatus(int id);
  Future<Map<String, dynamic>> getFpmConfig(int id);
  Future<void> updateFpmConfig(int id, Map<String, dynamic> params);
  Future<List<Map<String, dynamic>>> getNodeModules(int id);
  Future<void> operateNodeModule({
    required int id,
    required String operate,
    required String module,
    required String packageManager,
  });
}
