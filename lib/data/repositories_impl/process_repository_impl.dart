import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/entities/process_info.dart';
import '../../domain/repositories/process_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/process_api.dart';

class ProcessRepositoryImpl implements ProcessRepository {
  ProcessRepositoryImpl(this._api);

  final ProcessApi _api;

  @override
  Future<List<ProcessInfo>> listListening() async {
    final raw = await _api.getListeningProcesses();
    return raw.map(_map).toList(growable: false);
  }

  @override
  Future<void> stopProcess(int pid) => _api.stopProcess(pid);

  ProcessInfo _map(Map<String, dynamic> json) {
    final pidRaw = json['PID'] ?? json['pid'] ?? 0;
    return ProcessInfo(
      pid: pidRaw is num ? pidRaw.toInt() : int.tryParse('$pidRaw') ?? 0,
      name: (json['Name'] ?? json['name'] ?? '').toString(),
      user: (json['User'] ?? json['user'] ?? '').toString(),
      command: (json['Cmd'] ?? json['cmd'] ?? json['Command'] ?? '').toString(),
      port: _ports(json['Port'] ?? json['port']),
      protocol: _protocol(json['Protocol'] ?? json['protocol']),
      address: (json['Address'] ?? json['address'] ?? '').toString(),
    );
  }

  static String _ports(Object? raw) {
    if (raw is Map) return raw.keys.map((key) => '$key').join(', ');
    if (raw is List) return raw.map((item) => '$item').join(', ');
    return raw?.toString() ?? '';
  }

  static String _protocol(Object? raw) {
    final value = raw is num ? raw.toInt() : int.tryParse('$raw');
    return switch (value) {
      6 => 'TCP',
      17 => 'UDP',
      _ => raw?.toString() ?? '',
    };
  }
}

final processRepositoryProvider = FutureProvider.autoDispose<ProcessRepository>(
  (ref) async {
    final serverId = ref.watch(activeServerIdProvider);
    final client = await ref.watch(dioClientProvider(serverId).future);
    return ProcessRepositoryImpl(ProcessApi(client));
  },
  name: 'processRepositoryProvider',
);
