import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/storage/storage_service.dart';
import '../../domain/entities/server.dart';
import '../../domain/repositories/server_repository.dart';

part 'server_repository_impl.g.dart';

/// [ServerRepository] 的本地 JSON + SecureStorage 实现。
class ServerRepositoryImpl implements ServerRepository {
  ServerRepositoryImpl(this._storage);

  final StorageService _storage;

  @override
  Future<List<Server>> list() => _storage.getServers();

  @override
  Future<Server?> find(int id) => _storage.getServer(id);

  @override
  Future<String?> getApiKey(int id) => _storage.getApiKey(id);

  @override
  Future<Server> add({
    String? name,
    required String host,
    required int port,
    required bool isHttps,
    required bool allowInsecureConnections,
    required String apiKey,
  }) async {
    final existing = await _storage.getServers();
    final server = Server()
      ..name = name
      ..host = host
      ..port = port
      ..isHttps = isHttps
      ..allowInsecureConnections = allowInsecureConnections
      ..createdAt = DateTime.now()
      ..sortIndex = existing.length;

    await _storage.saveServer(server);
    await _storage.saveApiKey(server.id, apiKey);
    return server;
  }

  @override
  Future<void> update(Server server, {String? apiKey}) async {
    await _storage.saveServer(server);
    if (apiKey != null) {
      await _storage.saveApiKey(server.id, apiKey);
    }
  }

  @override
  Future<void> remove(int id) => _storage.deleteServer(id);

  @override
  Future<void> reorder(List<int> orderedIds) async {
    for (var i = 0; i < orderedIds.length; i++) {
      final s = await _storage.getServer(orderedIds[i]);
      if (s == null) continue;
      s.sortIndex = i;
      await _storage.saveServer(s);
    }
  }
}

/// 仓库 Provider（注入接口，便于测试替换）。
@Riverpod(keepAlive: true)
ServerRepository serverRepository(Ref ref) {
  return ServerRepositoryImpl(ref.watch(storageServiceProvider));
}
