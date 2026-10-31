import 'dart:typed_data';

import '../../data/dto/app/app_catalog_dto.dart';
import '../../data/dto/app/app_catalog_search_req.dart';
import '../../data/dto/app/app_installed_dto.dart';
import '../../data/dto/app/app_installed_check_req.dart';
import '../../data/dto/app/app_installed_check_res.dart';
import '../../data/dto/app/app_installed_info_dto.dart';
import '../../data/dto/app/app_installed_search_req.dart';
import '../../data/dto/app/app_detail_dto.dart';
import '../../data/dto/app/app_install_config_dto.dart';
import '../../data/dto/app/app_install_req.dart';
import '../../data/dto/app/app_tag_dto.dart';
import '../../data/dto/app/app_update_version_dto.dart';
import '../../data/dto/app/app_ignored_dto.dart';
import '../../data/dto/app/app_store_config_dto.dart';
import '../../data/dto/app/app_installed_params_dto.dart';
import '../../data/dto/common/page_result.dart';
import '../../data/dto/common/task_log_dto.dart';

/// App管理数据仓库接口。
abstract interface class AppRepository {
  /// 检查应用是否安装
  Future<AppInstalledCheckRes> checkAppInstalled(AppInstalledCheckReq req);

  /// 查询已安装应用
  Future<PageResult<AppInstalledDto>> searchInstalledApps(
    AppInstalledSearchReq req,
  );

  /// 查询已安装应用详情
  Future<AppInstalledInfoDto> getInstalledInfo(int id);

  /// 查询应用商店全部应用
  Future<PageResult<AppCatalogDto>> searchApps(AppCatalogSearchReq req);

  /// 查询应用标签
  Future<List<AppTagDto>> listAppTags();

  /// 获取应用详情（应用商店）
  Future<AppDetailDto> getAppDetail(String key);

  /// 获取应用安装配置。
  Future<AppInstallConfigDto> getAppInstallConfig(int appId, String version);

  /// 安装应用。
  Future<void> installApp(AppInstallReq req);

  /// 已安装应用收藏状态
  Future<void> operateInstalled({
    required int installId,
    required int detailId,
    required bool favorite,
  });

  /// 重建已安装应用
  Future<void> rebuildInstalled({
    required int installId,
    required int detailId,
  });

  /// 重启 / 停止 / 启动已安装应用
  Future<void> restartInstalled({
    required int installId,
    required int detailId,
  });

  Future<void> stopInstalled({required int installId, required int detailId});

  Future<void> startInstalled({required int installId, required int detailId});

  Future<void> reloadInstalled({required int installId, required int detailId});

  /// 获取应用图标
  Future<Uint8List> getAppIcon(String appName);

  /// 同步远程应用，返回接口提示信息（若有）
  Future<String?> syncRemoteApps(String taskID);

  /// 同步本地应用
  Future<void> syncLocalApps(String taskID);

  /// 读取任务日志
  Future<TaskLogDto> readTaskLog(String taskID);

  /// 获取应用安装日志
  Future<TaskLogDto> getAppInstallLog(int resourceID);

  /// 卸载应用
  Future<void> uninstallApp({
    required int installId,
    required int detailId,
    required String taskID,
    bool forceDelete = false,
    bool deleteBackup = false,
    bool deleteImage = false,
    bool deleteDB = true,
  });

  /// 获取可升级版本
  Future<List<AppUpdateVersionDto>> getUpdateVersions(
    int appInstallID, {
    String? updateVersion,
  });

  Future<void> upgradeApp({
    required int installId,
    required int detailId,
    required String version,
    required String dockerCompose,
    required String taskID,
    bool backup = true,
    bool pullImage = true,
  });

  /// 忽略更新
  Future<void> ignoreUpdate({
    required int appId,
    required int appDetailId,
    required String scope,
  });

  /// 获取忽略的应用列表
  Future<List<AppIgnoredDto>> getIgnoredApps();

  /// 取消忽略
  Future<void> cancelIgnore(int id);

  /// 获取已安装应用参数
  Future<AppInstalledParamsDto> getInstalledParams(int installId);

  /// 更新已安装应用参数
  Future<void> updateInstalledParams(AppInstalledParamsUpdateReq req);

  /// 修改已安装应用端口
  Future<void> changePort({
    required String key,
    required String name,
    required int port,
  });

  /// 获取应用商店配置
  Future<AppStoreConfigDto> getStoreConfig();

  /// 更新应用商店配置
  Future<void> updateStoreConfig({required String scope, required bool enable});
}
