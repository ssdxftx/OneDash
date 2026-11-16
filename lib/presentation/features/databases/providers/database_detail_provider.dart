import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';

typedef DatabaseKey = ({String name, String type, String instance});

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
      final page = switch (key.type) {
        'postgresql' ||
        'postgresql-cluster' => await repository.searchPgDatabases(
          database: key.instance,
          page: 1,
          pageSize: 100,
          info: key.name,
        ),
        'mongodb' => await repository.searchMongoDatabases(
          database: key.instance,
          page: 1,
          pageSize: 100,
          info: key.name,
        ),
        _ => await repository.searchDatabases(
          database: key.instance,
          page: 1,
          pageSize: 100,
          info: key.name,
        ),
      };
      DatabaseSearchItemDto? item;
      for (final candidate in page.items) {
        if (candidate.name == key.name) {
          item = candidate;
          break;
        }
      }
      if (item == null) {
        throw const RecordNotFoundException();
      }
      final extras = await Future.wait<Object>([
        _optional(
          repository.getConnInfo(type: key.type, name: key.instance),
          const <String, dynamic>{},
        ),
        _optional(
          repository.getRemoteAccess(type: key.type, name: key.instance),
          false,
        ),
      ]);
      return DatabaseDetailState(
        item: item,
        connection: extras[0] as Map<String, dynamic>,
        remoteAccess: extras[1] as bool,
      );
    }, name: 'databaseDetailProvider');

Future<T> _optional<T>(Future<T> future, T fallback) async {
  try {
    return await future;
  } catch (_) {
    return fallback;
  }
}
