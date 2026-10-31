import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/backup_account_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/backup_api.dart';

class BackupAccountRepositoryImpl implements BackupAccountRepository {
  BackupAccountRepositoryImpl(this._api);

  final BackupApi _api;

  @override
  Future<Map<String, dynamic>> searchAccounts({
    required int page,
    required int pageSize,
    String type = '',
    String name = '',
  }) => _api.searchBackupAccounts(
    page: page,
    pageSize: pageSize,
    type: type,
    name: name,
  );

  @override
  Future<void> createAccount(Map<String, dynamic> data) =>
      _api.createBackupAccount(data);

  @override
  Future<void> updateAccount(Map<String, dynamic> data) =>
      _api.updateBackupAccount(data);

  @override
  Future<void> deleteAccount(int id) => _api.deleteBackupAccount(id);

  @override
  Future<Map<String, dynamic>> checkConnection(Map<String, dynamic> data) =>
      _api.checkBackupConnection(data);

  @override
  Future<List<dynamic>> listBuckets(Map<String, dynamic> data) =>
      _api.listBuckets(data);

  @override
  Future<void> refreshToken(int id) => _api.refreshToken(id);

  @override
  Future<String> getLocalDir() => _api.getLocalDir();
}

final backupAccountRepositoryProvider = FutureProvider<BackupAccountRepository>(
  (ref) async {
    final serverId = ref.watch(activeServerIdProvider);
    final client = await ref.watch(dioClientProvider(serverId).future);
    return BackupAccountRepositoryImpl(BackupApi(client));
  },
  dependencies: [activeServerIdProvider],
);
