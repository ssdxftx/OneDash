import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';

typedef DatabaseKey = ({String name, String type});

class DatabaseDetailState {
  const DatabaseDetailState({
    required this.item,
    required this.connection,
    required this.remoteAccess,
  });

  final DatabaseSearchItemDto item;
  final Map<String, dynamic> connection;
  final bool remoteAccess;
}

final databaseDetailProvider = FutureProvider.autoDispose
    .family<DatabaseDetailState, DatabaseKey>((ref, key) async {
      final repository = await ref.watch(databaseRepositoryProvider.future);
      final page = await repository.searchDatabases(
        database: key.type,
        page: 1,
        pageSize: 100,
      );
      DatabaseSearchItemDto? item;
      for (final candidate in page.items) {
        if (candidate.name == key.name) {
          item = candidate;
          break;
        }
      }
      if (item == null) {
        throw StateError('数据库不存在: ${key.name}');
      }
      Map<String, dynamic> connection = const {};
      try {
        connection = await repository.getConnInfo(
          type: key.type,
          name: key.name,
        );
      } catch (_) {
        // 部分数据库类型不提供连接信息，保留空映射。
      }
      var remote = false;
      try {
        remote = await repository.getRemoteAccess(
          type: key.type,
          name: key.name,
        );
      } catch (_) {
        // 忽略不支持远程访问的类型。
      }
      return DatabaseDetailState(
        item: item,
        connection: connection,
        remoteAccess: remote,
      );
    }, name: 'databaseDetailProvider');
