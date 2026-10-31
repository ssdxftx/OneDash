import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/app_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/app_api.dart';
import '../api/file_api.dart';
import '../dto/app/app_catalog_dto.dart';
import '../dto/app/app_catalog_search_req.dart';
import '../dto/app/app_installed_dto.dart';
import '../dto/app/app_installed_check_req.dart';
import '../dto/app/app_installed_check_res.dart';
import '../dto/app/app_installed_info_dto.dart';
import '../dto/app/app_installed_search_req.dart';
import '../dto/app/app_detail_dto.dart';
import '../dto/app/app_install_config_dto.dart';
import '../dto/app/app_install_req.dart';
import '../dto/app/app_tag_dto.dart';
import '../dto/app/app_update_version_dto.dart';
import '../dto/app/app_ignored_dto.dart';
import '../dto/app/app_store_config_dto.dart';
import '../dto/app/app_installed_params_dto.dart';
import '../dto/common/page_result.dart';
import '../dto/common/task_log_dto.dart';

part 'app_repository_impl.g.dart';

/// [AppRepository] 的默认实现。
class AppRepositoryImpl implements AppRepository {
  AppRepositoryImpl(this._appApi, this._fileApi);

  final AppApi _appApi;
  final FileApi _fileApi;

  @override
  Future<AppInstalledCheckRes> checkAppInstalled(AppInstalledCheckReq req) =>
      _appApi.checkAppInstalled(req);

  @override
  Future<PageResult<AppInstalledDto>> searchInstalledApps(
    AppInstalledSearchReq req,
  ) => _appApi.searchInstalledApps(req);

  @override
  Future<AppInstalledInfoDto> getInstalledInfo(int id) =>
      _appApi.getInstalledInfo(id);

  @override
  Future<PageResult<AppCatalogDto>> searchApps(AppCatalogSearchReq req) =>
      _appApi.searchApps(req);

  @override
  Future<List<AppTagDto>> listAppTags() => _appApi.listAppTags();

  @override
  Future<AppDetailDto> getAppDetail(String key) => _appApi.getAppDetail(key);

  @override
  Future<AppInstallConfigDto> getAppInstallConfig(int appId, String version) =>
      _appApi.getAppInstallConfig(appId, version);

  @override
  Future<void> installApp(AppInstallReq req) => _appApi.installApp(req);

  @override
  Future<void> operateInstalled({
    required int installId,
    required int detailId,
    required bool favorite,
  }) => _appApi.operateInstalled(
    installId: installId,
    detailId: detailId,
    favorite: favorite,
  );

  @override
  Future<void> rebuildInstalled({
    required int installId,
    required int detailId,
  }) => _appApi.rebuildInstalled(installId: installId, detailId: detailId);

  @override
  Future<void> restartInstalled({
    required int installId,
    required int detailId,
  }) => _appApi.restartInstalled(installId: installId, detailId: detailId);

  @override
  Future<void> stopInstalled({required int installId, required int detailId}) =>
      _appApi.stopInstalled(installId: installId, detailId: detailId);

  @override
  Future<void> startInstalled({
    required int installId,
    required int detailId,
  }) => _appApi.startInstalled(installId: installId, detailId: detailId);

  @override
  Future<void> reloadInstalled({
    required int installId,
    required int detailId,
  }) => _appApi.reloadInstalled(installId: installId, detailId: detailId);

  @override
  Future<Uint8List> getAppIcon(String appName) => _appApi.getAppIcon(appName);

  @override
  Future<String?> syncRemoteApps(String taskID) =>
      _appApi.syncRemoteApps(taskID);

  @override
  Future<void> syncLocalApps(String taskID) => _appApi.syncLocalApps(taskID);

  @override
  Future<TaskLogDto> readTaskLog(String taskID) => _fileApi.readFile(
    id: 0,
    type: 'task',
    name: '',
    taskID: taskID,
    fromJson: TaskLogDto.fromJson,
  );

  @override
  Future<TaskLogDto> getAppInstallLog(int resourceID) => _fileApi.readFile(
    id: 0,
    type: 'task',
    name: '',
    page: 1,
    pageSize: 500,
    latest: true,
    taskType: 'App',
    taskOperate: 'TaskInstall',
    resourceID: resourceID,
    fromJson: TaskLogDto.fromJson,
  );

  @override
  Future<void> uninstallApp({
    required int installId,
    required int detailId,
    required String taskID,
    bool forceDelete = false,
    bool deleteBackup = false,
    bool deleteImage = false,
    bool deleteDB = true,
  }) => _appApi.uninstallApp(
    installId: installId,
    detailId: detailId,
    taskID: taskID,
    forceDelete: forceDelete,
    deleteBackup: deleteBackup,
    deleteImage: deleteImage,
    deleteDB: deleteDB,
  );

  @override
  Future<List<AppUpdateVersionDto>> getUpdateVersions(
    int appInstallID, {
    String? updateVersion,
  }) async {
    final api = _appApi;
    return api.getUpdateVersions(appInstallID, updateVersion: updateVersion);
  }

  @override
  Future<void> upgradeApp({
    required int installId,
    required int detailId,
    required String version,
    required String dockerCompose,
    required String taskID,
    bool backup = true,
    bool pullImage = true,
  }) async {
    final api = _appApi;
    return api.upgradeApp(
      installId: installId,
      detailId: detailId,
      version: version,
      dockerCompose: dockerCompose,
      taskID: taskID,
      backup: backup,
      pullImage: pullImage,
    );
  }

  @override
  Future<void> ignoreUpdate({
    required int appId,
    required int appDetailId,
    required String scope,
  }) async {
    final api = _appApi;
    return api.ignoreUpdate(
      appId: appId,
      appDetailId: appDetailId,
      scope: scope,
    );
  }

  @override
  Future<List<AppIgnoredDto>> getIgnoredApps() async {
    final api = _appApi;
    return api.getIgnoredApps();
  }

  @override
  Future<void> cancelIgnore(int id) async {
    final api = _appApi;
    return api.cancelIgnore(id);
  }

  @override
  Future<AppStoreConfigDto> getStoreConfig() async {
    final api = _appApi;
    return api.getStoreConfig();
  }

  @override
  Future<AppInstalledParamsDto> getInstalledParams(int installId) async {
    final api = _appApi;
    return api.getInstalledParams(installId);
  }

  @override
  Future<void> updateInstalledParams(AppInstalledParamsUpdateReq req) async {
    final api = _appApi;
    return api.updateInstalledParams(req);
  }

  @override
  Future<void> updateStoreConfig({
    required String scope,
    required bool enable,
  }) async {
    final api = _appApi;
    return api.updateStoreConfig(scope: scope, enable: enable);
  }

  @override
  Future<void> changePort({
    required String key,
    required String name,
    required int port,
  }) => _appApi.changePort(key: key, name: name, port: port);
}

/// 基于当前激活服务器的仓库 Provider。
@Riverpod()
Future<AppRepository> appRepository(Ref ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return AppRepositoryImpl(AppApi(client), FileApi(client));
}
