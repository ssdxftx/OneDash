import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/container/container_resource_stats_dto.dart';
import '../../../../data/dto/container/container_search_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';

class ContainersState {
  const ContainersState({
    required this.total,
    required this.items,
    required this.stats,
  });

  final int total;
  final List<ContainerItemDto> items;
  final Map<String, ContainerResourceStatsDto> stats;

  ContainersState copyWith({
    int? total,
    List<ContainerItemDto>? items,
    Map<String, ContainerResourceStatsDto>? stats,
  }) {
    return ContainersState(
      total: total ?? this.total,
      items: items ?? this.items,
      stats: stats ?? this.stats,
    );
  }
}

final containersProvider =
    AsyncNotifierProvider.autoDispose<ContainersController, ContainersState>(
      ContainersController.new,
      name: 'containersProvider',
    );

class ContainersController extends AutoDisposeAsyncNotifier<ContainersState> {
  String _state = 'all';
  String _name = '';

  @override
  Future<ContainersState> build() => _fetch();

  Future<ContainersState> _fetch() async {
    final repository = await ref.read(containerRepositoryProvider.future);
    final result = await repository.searchContainers(
      state: _state,
      pageSize: 100,
      name: _name,
    );
    Map<String, ContainerResourceStatsDto> stats = const {};
    try {
      final list = await repository.getContainerResourceStats();
      stats = {for (final item in list) item.containerID: item};
    } catch (_) {
      // 资源统计失败不影响列表。
    }
    return ContainersState(
      total: result.total,
      items: result.items,
      stats: stats,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<ContainersState>().copyWithPrevious(state);
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> setFilter(String value) async {
    _state = value;
    state = const AsyncLoading<ContainersState>().copyWithPrevious(state);
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> search(String value) async {
    _name = value.trim();
    state = const AsyncLoading<ContainersState>().copyWithPrevious(state);
    state = await AsyncValue.guard(_fetch);
  }
}

final dockerStatusProvider = FutureProvider.autoDispose((ref) async {
  final repository = await ref.watch(containerRepositoryProvider.future);
  return repository.getDockerStatus();
}, name: 'dockerStatusProvider');

final dockerDaemonConfigProvider = FutureProvider.autoDispose((ref) async {
  final repository = await ref.watch(containerRepositoryProvider.future);
  return repository.getDaemonConfig();
}, name: 'dockerDaemonConfigProvider');
