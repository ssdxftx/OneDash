import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/cronjob_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/cronjob_api.dart';
import '../dto/common/page_result.dart';
import '../dto/cronjob/cronjob_dto.dart';
import '../dto/cronjob/cronjob_form_data_dto.dart';

part 'cronjob_repository_impl.g.dart';

/// [CronjobRepository] 的默认实现。
class CronjobRepositoryImpl implements CronjobRepository {
  CronjobRepositoryImpl(this._api);

  final CronjobApi _api;

  @override
  Future<PageResult<CronjobDto>> searchCronjobs(Map<String, dynamic> req) =>
      _api.searchCronjobs(req);

  @override
  Future<void> createCronjob(CronjobCreateReq req) => _api.createCronjob(req);

  @override
  Future<CronjobDto> getCronjobInfo(int id) => _api.getCronjobInfo(id);

  @override
  Future<List<ScriptOptionDto>> loadScriptOptions() => _api.loadScriptOptions();

  @override
  Future<void> updateCronjob(CronjobCreateReq req) => _api.updateCronjob(req);

  @override
  Future<List<String>> getNextRun(String spec) => _api.getNextRun(spec);

  @override
  Future<void> updateCronjobGroup({required int id, required int groupId}) =>
      _api.updateCronjobGroup(id: id, groupId: groupId);

  @override
  Future<String> exportCronjobs(List<int> ids) => _api.exportCronjobs(ids);

  @override
  Future<void> importCronjobs(List<Map<String, dynamic>> items) =>
      _api.importCronjobs(items);

  @override
  Future<void> deleteCronjob(List<int> ids, {bool cleanData = false}) =>
      _api.deleteCronjob(ids, cleanData: cleanData);

  @override
  Future<void> updateStatus(int id, String status) =>
      _api.updateStatus(id, status);

  @override
  Future<void> handleOnce(int id) => _api.handleOnce(id);

  @override
  Future<void> stopCronjob(int id) => _api.stopCronjob(id);

  @override
  Future<PageResult<CronjobRecordDto>> searchRecords(
    Map<String, dynamic> req,
  ) => _api.searchRecords(req);

  @override
  Future<String> getRecordLog(int recordId) => _api.getRecordLog(recordId);

  @override
  Future<void> cleanRecords({
    required int cronjobID,
    bool cleanData = false,
    bool cleanRemoteData = false,
  }) => _api.cleanRecords(
    cronjobID: cronjobID,
    cleanData: cleanData,
    cleanRemoteData: cleanRemoteData,
  );
}

/// 基于当前激活服务器的仓库 Provider。
@Riverpod()
Future<CronjobRepository> cronjobRepository(Ref ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return CronjobRepositoryImpl(CronjobApi(client));
}
