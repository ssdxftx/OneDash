/// 设置相关数据仓库接口。
abstract interface class SettingRepository {
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

  /// 更新 Core 侧面板配置。
  Future<void> updateCoreSetting({required String key, required String value});

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
  Future<void> bindMFA({
    required String secret,
    required String code,
    required String interval,
  });
  Future<List<Map<String, dynamic>>> listPasskeys();
  Future<void> deletePasskey(int id);

  // ── API 接口配置 ──

  Future<String> generateApiKey();
  Future<void> updateApiConfig(Map<String, dynamic> config);

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
