import '../../data/api/runtime_api.dart';
import '../../data/dto/common/page_result.dart';
import '../../data/dto/common/task_log_dto.dart';
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
  Future<TaskLogDto> readRuntimeLog({required int id, required String type});
}
