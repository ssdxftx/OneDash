import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/mcp_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/mcp_api.dart';

class McpRepositoryImpl implements McpRepository {
  McpRepositoryImpl(this._api);

  final McpApi _api;

  @override
  Future<Map<String, dynamic>> getStatus() => _api.getStatus();

  @override
  Future<Map<String, dynamic>> getSettings() => _api.getSettings();

  @override
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> body) =>
      _api.updateSettings(body);

  @override
  Future<Map<String, dynamic>> getCatalog() => _api.getCatalog();

  @override
  Future<List<Map<String, dynamic>>> getNodes() => _api.getNodes();

  @override
  Future<Map<String, dynamic>> operateService(String operation) =>
      _api.operateService(operation);

  @override
  Future<Map<String, dynamic>> installService(Map<String, dynamic> body) =>
      _api.installService(body);

  @override
  Future<String> getServiceLogs() => _api.getServiceLogs();

  @override
  Future<Map<String, dynamic>> getWebsiteStatus() => _api.getWebsiteStatus();

  @override
  Future<Map<String, dynamic>> bindWebsite(Map<String, dynamic> body) =>
      _api.bindWebsite(body);

  @override
  Future<Map<String, dynamic>> updateWebsite(Map<String, dynamic> body) =>
      _api.updateWebsite(body);

  @override
  Future<Map<String, dynamic>> unbindWebsite(Map<String, dynamic> body) =>
      _api.unbindWebsite(body);

  @override
  Future<Map<String, dynamic>> searchCredentials({
    int page = 1,
    int pageSize = 50,
    bool excludeRevoked = false,
  }) => _api.searchCredentials(
    page: page,
    pageSize: pageSize,
    excludeRevoked: excludeRevoked,
  );

  @override
  Future<Map<String, dynamic>> createCredential(Map<String, dynamic> body) =>
      _api.createCredential(body);

  @override
  Future<void> updateCredential(Map<String, dynamic> body) =>
      _api.updateCredential(body);

  @override
  Future<void> setCredentialStatus({
    required String id,
    required int revision,
    required String status,
  }) => _api.setCredentialStatus(id: id, revision: revision, status: status);

  @override
  Future<void> revokeCredential({required String id, required int revision}) =>
      _api.revokeCredential(id: id, revision: revision);

  @override
  Future<void> deleteCredential({required String id, required int revision}) =>
      _api.deleteCredential(id: id, revision: revision);

  @override
  Future<String> revealCredential({
    required String id,
    required int revision,
  }) => _api.revealCredential(id: id, revision: revision);

  @override
  Future<String> rotateCredential({
    required String id,
    required int revision,
  }) => _api.rotateCredential(id: id, revision: revision);

  @override
  Future<Map<String, dynamic>> exportCredential({
    required String id,
    required int revision,
    required String client,
  }) => _api.exportCredential(id: id, revision: revision, client: client);

  @override
  Future<Map<String, dynamic>> searchInvocations({
    int page = 1,
    int pageSize = 50,
    String credentialId = '',
    String toolId = '',
    String status = '',
  }) => _api.searchInvocations(
    page: page,
    pageSize: pageSize,
    credentialId: credentialId,
    toolId: toolId,
    status: status,
  );
}

final mcpRepositoryProvider = FutureProvider<McpRepository>((ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return McpRepositoryImpl(McpApi(client));
}, name: 'mcpRepositoryProvider');
