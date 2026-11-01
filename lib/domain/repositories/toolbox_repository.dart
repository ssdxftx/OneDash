abstract interface class ToolboxRepository {
  Future<Map<String, dynamic>> getDeviceBase();
  Future<Map<String, dynamic>> getFail2banBase();
  Future<Map<String, dynamic>> getFtpBase();
  Future<Map<String, dynamic>> getClamBase();
  Future<Map<String, dynamic>> scanClean();
  Future<List<String>> loadUsers();
  Future<List<String>> getZoneOptions();
  Future<void> updateDeviceConf(String key, String value);
  Future<void> updateSwap({
    required String path,
    required int size,
    bool isNew,
  });
  Future<List<String>> searchFail2ban(String status);
  Future<void> operateFail2ban(String operation);
  Future<void> operateFail2banSshd(List<String> ips, String operate);
  Future<void> updateFail2banConf(String key, String value);
  Future<List<Map<String, dynamic>>> searchFtp({int page, int pageSize});
  Future<void> createFtp({
    required String user,
    required String password,
    required String path,
    String description,
  });
  Future<void> deleteFtp(List<int> ids);
  Future<List<Map<String, dynamic>>> searchClam({int page, int pageSize});
  Future<void> createClam({
    required String name,
    required String path,
    String infectedStrategy,
    String infectedDir,
  });
  Future<void> operateClam(String operation);
  Future<void> handleClam(int id);
  Future<List<Map<String, dynamic>>> searchClamRecords({
    required int clamId,
    int page,
    int pageSize,
  });
}
