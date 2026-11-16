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
  Future<List<Map<String, dynamic>>> checkRuntimeDelete(int id);
  Future<void> deleteRuntime(int id, {bool forceDelete = false});
  Future<void> operateRuntime(int id, String operate);
  Future<void> syncRuntimes();
  Future<List<PhpExtensionGroupDto>> searchPhpExtensions();
  Future<Map<String, dynamic>> getPhpExtensionPreset(int id);
  Future<void> createPhpExtensionPreset({
    required String name,
    required String extensions,
  });
  Future<void> updatePhpExtensionPreset({
    required int id,
    required String extensions,
  });
  Future<void> deletePhpExtensionPreset(int id);
  Future<String> importPhpExtensionPreset({
    required String name,
    required String extensions,
  });
  Future<void> pushPhpExtensionPreset({
    required int id,
    required String sourceNode,
    required List<String> targetNodes,
    required String taskID,
  });
  Future<void> updateRuntimeRemark(int id, String remark);
  Future<List<Map<String, dynamic>>> getSupervisorProcesses(int id);
  Future<void> operateSupervisorProcess(int id, Map<String, dynamic> body);
  Future<String> supervisorProcessFile({
    required int id,
    required String name,
    required String operate,
    required String file,
    String content,
  });
  Future<List<NodeScriptDto>> getNodeScripts(String codeDir);
  Future<FileLogDto> readRuntimeLog({required int id, required String type});
  Future<Map<String, dynamic>> getPhpExtensions(int id);
  Future<void> installPhpExtension(int id, String name, String taskId);
  Future<void> uninstallPhpExtension(int id, String name);
  Future<String> getPhpFile(int id, String type);
  Future<void> updatePhpFile(int id, String type, String content);
  Future<Map<String, dynamic>> getPhpConfig(int id);
  Future<void> updatePhpConfig({
    required int id,
    required String scope,
    Map<String, String> params,
    List<String> disableFunctions,
    String uploadMaxSize,
    String maxExecutionTime,
  });
  Future<Map<String, dynamic>> getPhpContainer(int id);
  Future<void> updatePhpContainer(Map<String, dynamic> body);
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
