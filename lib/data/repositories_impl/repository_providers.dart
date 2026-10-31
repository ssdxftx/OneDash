import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../api/dashboard_api.dart';
import '../api/host_api.dart';
import 'dashboard_repository_impl.dart';

/// 按服务器 id 构建仪表盘仓库，供服务器列表的迷你指标使用。
///
/// 面板详情页内部仍然使用 `dashboardRepositoryProvider`（依赖 activeServerId）。
final dashboardRepositoryForServerProvider =
    FutureProvider.family<DashboardRepository, int>((ref, serverId) async {
      final client = await ref.watch(dioClientProvider(serverId).future);
      return DashboardRepositoryImpl(DashboardApi(client), HostApi(client));
    }, name: 'dashboardRepositoryForServerProvider');
