import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_service.dart';
import '../../../../data/repositories_impl/repository_providers.dart';
import '../../../../data/repositories_impl/server_repository_impl.dart';
import '../../../../domain/entities/server.dart';

final serversProvider = AsyncNotifierProvider<ServersController, List<Server>>(
  ServersController.new,
  name: 'serversProvider',
);

class ServersController extends AsyncNotifier<List<Server>> {
  @override
  Future<List<Server>> build() {
    return ref.watch(serverRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Server>>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(serverRepositoryProvider).list(),
    );
  }

  Future<void> delete(int id) async {
    await ref.read(serverRepositoryProvider).remove(id);
    await refresh();
  }

  Future<void> touch(int id) async {
    final repository = ref.read(serverRepositoryProvider);
    final server = await repository.find(id);
    if (server == null) return;
    server.lastUsedAt = DateTime.now();
    await repository.update(server);
    await ref.read(storageServiceProvider).setString('last_server_id', '$id');
    await refresh();
  }
}

class ServerHealth {
  const ServerHealth({
    required this.online,
    required this.latencyMs,
    this.cpuPercent,
    this.memoryPercent,
    this.diskPercent,
    this.hostname,
  });

  final bool online;
  final int latencyMs;
  final double? cpuPercent;
  final double? memoryPercent;
  final double? diskPercent;
  final String? hostname;

  static const offline = ServerHealth(online: false, latencyMs: 0);
}

final serverHealthProvider = FutureProvider.autoDispose
    .family<ServerHealth, int>((ref, serverId) async {
      final stopwatch = Stopwatch()..start();
      try {
        final repository = await ref.watch(
          dashboardRepositoryForServerProvider(serverId).future,
        );
        final dashboard = await repository.getDashboardBase(
          ioOption: 'all',
          netOption: 'all',
        );
        stopwatch.stop();
        final current = await repository.getDashboardCurrent(
          ioOption: 'all',
          netOption: 'all',
        );
        final disk = current.disks.isEmpty
            ? null
            : current.disks
                  .map((d) => d.usedPercent)
                  .reduce((a, b) => a > b ? a : b);
        return ServerHealth(
          online: true,
          latencyMs: stopwatch.elapsedMilliseconds,
          cpuPercent: current.cpuUsedPercent,
          memoryPercent: current.memoryUsedPercent,
          diskPercent: disk,
          hostname: dashboard.hostname,
        );
      } catch (_) {
        stopwatch.stop();
        return ServerHealth(
          online: false,
          latencyMs: stopwatch.elapsedMilliseconds,
        );
      }
    }, name: 'serverHealthProvider');

final lastServerIdProvider = Provider<int?>((ref) {
  final raw = ref.watch(storageServiceProvider).getString('last_server_id');
  return int.tryParse(raw ?? '');
});

final serverByIdProvider = FutureProvider.autoDispose.family<Server?, int>((
  ref,
  serverId,
) {
  return ref.watch(serverRepositoryProvider).find(serverId);
}, name: 'serverByIdProvider');
