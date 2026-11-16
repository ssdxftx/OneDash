abstract interface class ToolboxRepository {
  Future<Map<String, dynamic>> getDeviceBase();
  Future<String> loadDeviceConf(String name);
  Future<void> updateDeviceByFile({required String name, required String file});
  Future<void> updateDeviceHosts(List<Map<String, String>> hosts);
  Future<void> updateDevicePassword({
    required String user,
    required String password,
  });
  Future<bool> checkDns({String key, required String value});
  Future<void> cleanSystem(List<Map<String, dynamic>> items);
  Future<void> deleteClam({required List<int> ids, bool removeInfected});
  Future<void> cleanClamRecords(int id);
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
  Future<String> loadFail2banConf();
  Future<void> updateFail2banByFile(String file);
  Future<List<Map<String, dynamic>>> searchFtp({int page, int pageSize});
  Future<void> createFtp({
    required String user,
    required String password,
    required String path,
    String description,
  });
  Future<void> deleteFtp(List<int> ids);
  Future<void> operateFtp(String operation);
  Future<void> syncFtp();
  Future<void> updateFtp(Map<String, dynamic> data);
  Future<Map<String, dynamic>> searchFtpLogs({
    int page,
    int pageSize,
    String user,
    String operation,
  });
  Future<List<Map<String, dynamic>>> searchClam({int page, int pageSize});
  Future<void> createClam({
    required String name,
    required String path,
    String infectedStrategy,
    String infectedDir,
  });
  Future<void> operateClam(String operation);
  Future<void> handleClam(int id);
  Future<void> updateClam(Map<String, dynamic> data);
  Future<void> updateClamStatus(int id, String status);
  Future<String> loadClamFile(String name, {String tail});
  Future<void> updateClamFile({required String name, required String file});

  Future<List<Map<String, dynamic>>> searchClamRecords({
    required int clamId,
    int page,
    int pageSize,
  });
}
