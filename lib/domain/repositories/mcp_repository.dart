abstract interface class McpRepository {
  Future<Map<String, dynamic>> getStatus();

  Future<Map<String, dynamic>> getSettings();

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> body);

  Future<Map<String, dynamic>> getCatalog();

  Future<List<Map<String, dynamic>>> getNodes();

  Future<Map<String, dynamic>> operateService(String operation);

  Future<Map<String, dynamic>> installService(Map<String, dynamic> body);

  Future<String> getServiceLogs();

  Future<Map<String, dynamic>> getWebsiteStatus();

  Future<Map<String, dynamic>> bindWebsite(Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateWebsite(Map<String, dynamic> body);

  Future<Map<String, dynamic>> unbindWebsite(Map<String, dynamic> body);

  Future<Map<String, dynamic>> searchCredentials({
    int page,
    int pageSize,
    bool excludeRevoked,
  });

  Future<Map<String, dynamic>> createCredential(Map<String, dynamic> body);

  Future<void> updateCredential(Map<String, dynamic> body);

  Future<void> setCredentialStatus({
    required String id,
    required int revision,
    required String status,
  });

  Future<void> revokeCredential({required String id, required int revision});

  Future<void> deleteCredential({required String id, required int revision});

  Future<String> revealCredential({required String id, required int revision});

  Future<String> rotateCredential({required String id, required int revision});

  Future<Map<String, dynamic>> exportCredential({
    required String id,
    required int revision,
    required String client,
  });

  Future<Map<String, dynamic>> searchInvocations({
    int page,
    int pageSize,
    String credentialId,
    String toolId,
    String status,
  });
}
