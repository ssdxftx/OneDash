import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/toolbox_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/toolbox_api.dart';

class ToolboxRepositoryImpl implements ToolboxRepository {
  ToolboxRepositoryImpl(this._api);

  final ToolboxApi _api;

  @override
  Future<Map<String, dynamic>> getDeviceBase() => _api.getDeviceBase();

  @override
  Future<Map<String, dynamic>> getFail2banBase() => _api.getFail2banBase();

  @override
  Future<Map<String, dynamic>> getFtpBase() => _api.getFtpBase();

  @override
  Future<Map<String, dynamic>> getClamBase() => _api.getClamBase();

  @override
  Future<Map<String, dynamic>> scanClean() => _api.scanClean();

  @override
  Future<List<String>> loadUsers() => _api.loadUsers();
}

final toolboxRepositoryProvider = FutureProvider<ToolboxRepository>((
  ref,
) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return ToolboxRepositoryImpl(ToolboxApi(client));
}, dependencies: [activeServerIdProvider]);
