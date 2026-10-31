import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前激活服务器的 id。
///
/// 在服务器详情壳入口通过 `ProviderScope.overrides` 注入，
/// 子树内任意 Tab / Provider 可 `ref.watch(activeServerIdProvider)` 获取。
final activeServerIdProvider = Provider<int>(
  (ref) => throw UnimplementedError(
    'activeServerIdProvider must be overridden at the ServerShell entry',
  ),
  name: 'activeServerIdProvider',
);
