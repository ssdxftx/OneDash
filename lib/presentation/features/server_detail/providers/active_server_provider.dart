import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前激活服务器的 id。
///
/// 由 appRouter 的 redirect 在每次导航时写入，早于页面构建，
/// 所以首屏拿到的就是正确的 serverId。
final activeServerIdStateProvider = StateProvider<int>((ref) => 0);

final activeServerIdProvider = Provider<int>(
  (ref) => ref.watch(activeServerIdStateProvider),
  name: 'activeServerIdProvider',
);
