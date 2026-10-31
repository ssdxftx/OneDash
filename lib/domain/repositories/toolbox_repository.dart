abstract interface class ToolboxRepository {
  Future<Map<String, dynamic>> getDeviceBase();
  Future<Map<String, dynamic>> getFail2banBase();
  Future<Map<String, dynamic>> getFtpBase();
  Future<Map<String, dynamic>> getClamBase();
  Future<Map<String, dynamic>> scanClean();
  Future<List<String>> loadUsers();
}
