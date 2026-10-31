import '../../data/dto/alert/alert_dto.dart';
import '../../data/dto/common/page_result.dart';

abstract interface class AlertRepository {
  Future<PageResult<AlertInfo>> searchAlerts(AlertSearchReq req);
  Future<void> createAlert(AlertCreateReq req);
  Future<void> updateAlert(int id, AlertCreateReq req);
  Future<void> deleteAlert(int id);
  Future<void> updateAlertStatus(int id, String status);
  Future<PageResult<AlertLogInfo>> searchAlertLogs(AlertLogSearchReq req);
  Future<void> cleanAlertLogs();
  Future<AlertConfigInfo> getAlertConfig();
  Future<void> updateAlertConfig(AlertConfigUpdateReq req);
  Future<bool> testAlertConfig(AlertConfigTestReq req);
  Future<void> deleteAlertConfig(int id);
  Future<List<Map<String, dynamic>>> listDisks();
}
