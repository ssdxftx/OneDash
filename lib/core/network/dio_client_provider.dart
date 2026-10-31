import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/storage_service.dart';
import '../../presentation/features/settings/providers/app_settings_provider.dart';
import 'dio_client.dart';

part 'dio_client_provider.g.dart';

/// 指定服务器的 DioClient（按 id 缓存，生命周期内复用）。
///
/// 使用 `keepAlive` 避免 Provider 销毁触发重建连接池。
@Riverpod(keepAlive: true)
Future<DioClient> dioClient(Ref ref, int serverId) async {
  final storage = ref.watch(storageServiceProvider);
  final server = await storage.getServer(serverId);
  if (server == null) {
    throw StateError('服务器不存在: $serverId');
  }
  final apiKey = await storage.getApiKey(serverId) ?? '';
  final settings = await ref.watch(appSettingsControllerProvider.future);
  final userAgent = await DioClient.defaultUserAgent();

  final client = DioClient(
    baseUrl: server.baseUrl.toString(),
    apiKey: apiKey,
    requestTimeout: Duration(seconds: settings.requestTimeoutSeconds),
    customHeaders: settings.customHeaders,
    userAgent: userAgent,
    allowInsecureConnections: server.allowInsecureConnections,
  );
  ref.onDispose(client.dispose);
  return client;
}

/// 一次性构建的"裸" DioClient，用于添加服务器时的连通性测试。
///
/// 不缓存、不持久化，测试完直接 dispose。
Future<DioClient> createProbeClient({
  required String host,
  required int port,
  required String apiKey,
  required bool isHttps,
  int requestTimeoutSeconds =
      AppSettingsController.defaultRequestTimeoutSeconds,
  Map<String, String> customHeaders = const {},
  bool allowInsecureConnections = false,
}) async {
  final scheme = isHttps ? 'https' : 'http';
  final userAgent = await DioClient.defaultUserAgent();
  return DioClient(
    baseUrl: '$scheme://$host:$port',
    apiKey: apiKey,
    requestTimeout: Duration(seconds: requestTimeoutSeconds),
    customHeaders: customHeaders,
    userAgent: userAgent,
    allowInsecureConnections: allowInsecureConnections,
  );
}
