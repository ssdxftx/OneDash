import 'dart:typed_data';

import '../../core/network/panel_session.dart';
import '../../data/dto/common/page_result.dart';
import '../../data/dto/setting/api_key_dto.dart';
import '../../data/dto/setting/script_library_dto.dart';
import '../../data/dto/setting/command_library_dto.dart';
import '../../data/dto/setting/group_dto.dart';
import '../../data/dto/setting/passkey_dto.dart';

/// 设置相关数据仓库接口。
abstract interface class SettingRepository {
  Future<bool> getFileDownloadPreference();
  Future<void> updateFileDownloadPreference({required bool useServerFilename});
  Future<Uint8List> downloadPanelSsl();

  /// 获取面板安装根目录。
  Future<String> getBaseDir();

  /// 更新系统设置。
  Future<void> updateSetting({required String key, required String value});

  /// 搜索系统设置。
  Future<Map<String, dynamic>> searchSettings();

  /// 获取系统 IP 地址。
  Future<String> getSystemIP();

  /// 获取当前服务器的主机地址（用于 systemIP 为空时的回退）。
  String getServerHost();

  /// 搜索 Core 侧面板配置（用户名、主题、语言、会话超时等）。
  Future<Map<String, dynamic>> searchCoreSettings();

  // ── 面板登录会话 ──

  Future<bool> hasPanelSession();

  Future<Map<String, dynamic>> getLoginSetting();

  Future<Map<String, dynamic>> loadLoginCaptcha();

  Future<PanelLoginResult> loginPanel({
    required String name,
    required String password,
    required String language,
    String captcha = '',
    String captchaId = '',
    String entrance = '',
  });

  Future<PanelLoginResult> loginPanelMfa({
    required String sessionId,
    required String code,
  });

  Future<void> logoutPanel();

  /// 更新面板服务器代理。
  Future<void> updatePanelProxy({
    required String proxyUrl,
    required String proxyType,
    required String proxyPort,
    String proxyUser,
    String proxyPasswd,
    bool proxyPasswdKeep,
    bool proxyDocker,
    bool withDockerRestart,
  });

  /// 更新 Core 侧面板配置。
  Future<void> updateCoreSetting({required String key, required String value});
  Future<String> getMemo();

  // ── 终端/文件 AI 与文件历史 ──
  Future<Map<String, dynamic>> getTerminalAppearanceSettings();
  Future<void> updateTerminalAppearanceSettings(Map<String, String> data);

  Future<Map<String, dynamic>> getTerminalAiSetting();
  Future<void> updateTerminalAiSetting({
    required String aiStatus,
    required String aiPrefix,
    String aiAccountId,
    String aiRiskCommands,
  });
  Future<Map<String, dynamic>> getFileAiSetting();
  Future<void> updateFileAiSetting({
    required String aiStatus,
    String aiAccountId,
  });
  Future<Map<String, dynamic>> getFileHistorySetting();
  Future<void> updateFileHistorySetting({
    required String enable,
    required int maxPerPath,
    required int diskQuotaMB,
  });

  // ── 本地 SSH 与菜单 ──

  Future<Map<String, dynamic>> getLocalSshConn();
  Future<void> saveLocalSshConn(Map<String, dynamic> data);
  Future<bool> checkLocalSshConn(Map<String, dynamic> data);
  Future<void> setSshDefaultConn({required String defaultConn, bool withReset});
  Future<void> resetMenuSetting();
  Future<void> updateMenuSetting(String value);

  Future<Map<String, dynamic>> getUpgradeInfo();
  Future<List<Map<String, dynamic>>> getUpgradeReleases();
  Future<String> getUpgradeNotes(String version);
  Future<void> upgradePanel(String version);

  /// 保存资源描述与置顶状态。
  Future<void> saveDescription({
    required String id,
    required String type,
    String detailType,
    required bool isPinned,
    required String description,
  });

  /// 保存面板备忘录。
  Future<void> saveMemo(String content);

  /// 更新面板登录密码。
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  });

  // ── 安全设置 ──

  Future<void> updatePort(int serverPort);
  Future<List<String>> loadInterfaceAddr();
  Future<void> updateBindInfo({
    required String ipv6,
    required String bindAddress,
  });
  Future<void> updateSSL(Map<String, dynamic> data);
  Future<Map<String, dynamic>> loadSSLInfo();
  Future<Map<String, dynamic>> loadMFA({
    required String title,
    required int interval,
  });

  /// 搜索面板分组。
  Future<List<CoreGroupDto>> searchGroups({required String type});

  /// 创建面板分组。
  Future<void> createGroup({required String name, required String type});

  /// 更新面板分组。
  Future<void> updateGroup({
    required int id,
    required String name,
    required String type,
    bool isDefault = false,
  });

  /// 删除面板分组。
  Future<void> deleteGroup(int id);

  /// 搜索命令库。
  Future<List<CommandTreeDto>> searchCommandTree({String type});
  Future<List<Map<String, dynamic>>> uploadCommandCsv({
    required Uint8List bytes,
    required String filename,
  });
  Future<void> importCommands(List<Map<String, dynamic>> items);
  Future<String> exportCommands();

  Future<PageResult<CommandLibraryDto>> searchCommands({
    String type = 'command',
    String info = '',
    int page = 1,
    int pageSize = 50,
    int groupID = 0,
    String orderBy = 'createdAt',
    String order = 'descending',
  });

  /// 创建命令。
  Future<void> createCommand(Map<String, dynamic> data);

  /// 更新命令。
  Future<void> updateCommand(Map<String, dynamic> data);

  /// 删除命令。
  Future<void> deleteCommands({
    required List<int> ids,
    String type = 'command',
  });

  /// 搜索脚本库。
  Future<PageResult<ScriptLibraryDto>> searchScripts({
    String info = '',
    int page = 1,
    int pageSize = 50,
    int groupID = 0,
  });

  /// 创建脚本。
  Future<void> createScript(Map<String, dynamic> data);

  /// 更新脚本。
  Future<void> updateScript(Map<String, dynamic> data);

  /// 删除脚本。
  Future<void> deleteScripts(List<int> ids);

  /// 同步脚本库。
  Future<void> syncScripts(String taskID);

  /// 关闭双因素认证。
  Future<void> closeMFA();

  /// 密码过期时重置密码。
  Future<void> resetExpiredPassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<void> bindMFA({
    required String secret,
    required String code,
    required int interval,
  });
  Future<PasskeyChallenge> passkeyBeginLogin({String entrance = ''});
  Future<PanelLoginResult> passkeyFinishLogin({
    required Map<String, dynamic> payload,
    required String sessionId,
    String entrance = '',
  });
  Future<PasskeyChallenge> passkeyBeginRegister(String name);
  Future<void> passkeyFinishRegister({
    required Map<String, dynamic> payload,
    required String sessionId,
  });
  Future<List<Map<String, dynamic>>> listPasskeys();
  Future<void> deletePasskey(String id);

  // ── API 接口配置 ──

  Future<String> generateApiKey();
  Future<void> updateApiConfig(Map<String, dynamic> config);

  // ── 独立 API Key ──

  Future<PageResult<ApiKeyItemDto>> searchApiKeys({
    int page,
    int pageSize,
    bool excludeRevoked,
  });

  Future<ApiKeyCreatedDto> createApiKey({
    required String requestId,
    required String name,
    String description,
    String ipWhiteList,
    String apiTrustedProxies,
    int apiKeyValidityTime,
    DateTime? expiresAt,
    bool allowAppBinding,
  });

  Future<void> updateApiKey({
    required String id,
    required int revision,
    required String name,
    String description,
    String ipWhiteList,
    String apiTrustedProxies,
    int apiKeyValidityTime,
    DateTime? expiresAt,
    bool allowAppBinding,
  });

  Future<void> setApiKeyStatus({
    required String id,
    required int revision,
    required String status,
  });

  Future<void> revokeApiKey({required String id, required int revision});

  Future<void> deleteApiKey({required String id, required int revision});

  Future<String> revealApiKey({required String id, required int revision});

  // ── 快照 ──

  Future<void> createSnapshot(Map<String, dynamic> data);
  Future<void> importSnapshot(Map<String, dynamic> data);

  Future<Map<String, dynamic>> searchSnapshots({
    required int page,
    required int pageSize,
    String info = '',
    String orderBy = 'createdAt',
    String order = 'null',
  });
  Future<Map<String, dynamic>> loadSnapshotData();
  Future<void> deleteSnapshots({
    required List<int> ids,
    bool deleteWithFile = false,
  });
  Future<void> recoverSnapshot({
    required int id,
    bool isNew = false,
    bool reDownload = false,
    String taskID = '',
    String secret = '',
  });
  Future<void> rollbackSnapshot({
    required int id,
    String taskID = '',
    String secret = '',
  });
  Future<void> recreateSnapshot(int id);
  Future<void> updateSnapshotDescription(int id, String description);
}
