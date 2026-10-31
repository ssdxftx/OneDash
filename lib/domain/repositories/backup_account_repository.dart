abstract interface class BackupAccountRepository {
  Future<Map<String, dynamic>> searchAccounts({
    required int page,
    required int pageSize,
    String type = '',
    String name = '',
  });
  Future<void> createAccount(Map<String, dynamic> data);
  Future<void> updateAccount(Map<String, dynamic> data);
  Future<void> deleteAccount(int id);
  Future<Map<String, dynamic>> checkConnection(Map<String, dynamic> data);
  Future<List<dynamic>> listBuckets(Map<String, dynamic> data);
  Future<void> refreshToken(int id);
  Future<String> getLocalDir();
}
