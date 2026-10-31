import '../entities/server.dart';

/// 面板服务器仓库抽象。
///
/// 封装服务器元数据 + API Key 的读写，屏蔽底层存储细节。
abstract class ServerRepository {
  Future<List<Server>> list();

  Future<Server?> find(int id);

  Future<String?> getApiKey(int id);

  /// 新增一个面板（写入元数据 + 安全存储 API Key）。
  Future<Server> add({
    String? name,
    required String host,
    required int port,
    required bool isHttps,
    required bool allowInsecureConnections,
    required String apiKey,
  });

  /// 更新服务器元数据（可选更新 API Key）。
  Future<void> update(Server server, {String? apiKey});

  Future<void> remove(int id);

  /// 按新顺序持久化排序索引。
  Future<void> reorder(List<int> orderedIds);
}
