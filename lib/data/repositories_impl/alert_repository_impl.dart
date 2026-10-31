import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/alert_api.dart';
import '../dto/alert/alert_dto.dart';
import '../dto/common/page_result.dart';

class AlertRepositoryImpl implements AlertRepository {
  AlertRepositoryImpl(this._api);

  final AlertApi _api;

  @override
  Future<PageResult<AlertInfo>> searchAlerts(AlertSearchReq req) =>
      _api.searchAlerts(req);

  @override
  Future<void> createAlert(AlertCreateReq req) => _api.createAlert(req);

  @override
  Future<void> updateAlert(int id, AlertCreateReq req) =>
      _api.updateAlert(id, req);

  @override
  Future<void> deleteAlert(int id) => _api.deleteAlert(id);

  @override
  Future<void> updateAlertStatus(int id, String status) =>
      _api.updateAlertStatus(id, status);

  @override
  Future<PageResult<AlertLogInfo>> searchAlertLogs(AlertLogSearchReq req) =>
      _api.searchAlertLogs(req);

  @override
  Future<void> cleanAlertLogs() => _api.cleanAlertLogs();

  @override
  Future<AlertConfigInfo> getAlertConfig() => _api.getAlertConfig();

  @override
  Future<void> updateAlertConfig(AlertConfigUpdateReq req) =>
      _api.updateAlertConfig(req);

  @override
  Future<bool> testAlertConfig(AlertConfigTestReq req) =>
      _api.testAlertConfig(req);

  @override
  Future<void> deleteAlertConfig(int id) => _api.deleteAlertConfig(id);

  @override
  Future<List<Map<String, dynamic>>> listDisks() => _api.listDisks();
}

final alertRepositoryProvider = FutureProvider<AlertRepository>((ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return AlertRepositoryImpl(AlertApi(client));
}, dependencies: [activeServerIdProvider]);
