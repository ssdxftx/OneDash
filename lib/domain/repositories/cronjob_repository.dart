import '../../data/dto/common/page_result.dart';
import '../../data/dto/cronjob/cronjob_dto.dart';

/// 计划任务数据仓库接口。
abstract interface class CronjobRepository {
  Future<PageResult<CronjobDto>> searchCronjobs(Map<String, dynamic> req);
  Future<void> createCronjob(CronjobCreateReq req);
  Future<CronjobDto> getCronjobInfo(int id);
  Future<void> updateCronjob(CronjobCreateReq req);
  Future<void> deleteCronjob(List<int> ids, {bool cleanData = false});
  Future<void> updateStatus(int id, String status);
  Future<void> handleOnce(int id);
  Future<void> stopCronjob(int id);
  Future<PageResult<CronjobRecordDto>> searchRecords(Map<String, dynamic> req);
  Future<String> getRecordLog(int recordId);
  Future<void> cleanRecords({
    required int cronjobID,
    bool cleanData = false,
    bool cleanRemoteData = false,
  });
}
