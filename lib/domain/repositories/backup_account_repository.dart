abstract interface class BackupAccountRepository {
  Future<Map<String, dynamic>> searchAccounts({
    required int page,
    required int pageSize,
    String type = '',
    String name = '',
  });
  Future<void> createAccount(Map<String, dynamic> data);
  Future<void> updateAccount(Map<String, dynamic> data);
  Future<void> deleteAccount({
    required int id,
    required String name,
    required bool isPublic,
  });

  Future<void> checkName(String name);
  Future<Map<String, dynamic>> checkConnection(Map<String, dynamic> data);
  Future<List<dynamic>> listBuckets(Map<String, dynamic> data);
  Future<void> refreshToken({
    required int id,
    required String name,
    required bool isPublic,
  });
  Future<Map<String, dynamic>> getClientInfo(String clientType);
  Future<String> getLocalDir();
}
