import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/container/container_resource_stats_dto.dart';
import '../../../../data/dto/container/container_search_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';

class ContainersState {
  const ContainersState({
    required this.total,
    required this.items,
    required this.stats,
    this.loadingMore = false,
  });

  final int total;
  final List<ContainerItemDto> items;
  final Map<String, ContainerResourceStatsDto> stats;
  final bool loadingMore;

  ContainersState copyWith({
    int? total,
    List<ContainerItemDto>? items,
    Map<String, ContainerResourceStatsDto>? stats,
    bool? loadingMore,
  }) {
    return ContainersState(
      total: total ?? this.total,
      items: items ?? this.items,
      stats: stats ?? this.stats,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

final containersProvider =
    AsyncNotifierProvider.autoDispose<ContainersController, ContainersState>(
      ContainersController.new,
      name: 'containersProvider',
    );

class ContainersController extends AutoDisposeAsyncNotifier<ContainersState> {
  static const _pageSize = 40;

  String _state = 'all';
  String _name = '';
  int _page = 1;
  int _generation = 0;
  bool _loadingMore = false;
  bool _polling = false;
  bool _disposed = false;

  @override
  Future<ContainersState> build() async {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _generation++;
    _page = 1;
    final generation = _generation;
    final data = await _fetch(page: 1);
    unawaited(_loadStats(data.items, generation));
    return data;
  }

  Future<ContainersState> _fetch({required int page}) async {
    final repository = await ref.read(containerRepositoryProvider.future);
    final result = await repository.searchContainers(
      state: _state,
      page: page,
      pageSize: _pageSize,
      name: _name,
    );
    return ContainersState(
      total: result.total,
      items: result.items,
      stats: const {},
    );
  }

  Future<void> _loadStats(List<ContainerItemDto> items, int generation) async {
    final runningIds = items
        .where((item) => item.state.toLowerCase() == 'running')
        .map((item) => item.containerID)
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    if (runningIds.isEmpty) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final list = await repository.getContainerResourceStats(ids: runningIds);
      if (_disposed || generation != _generation) return;
      var current = state.valueOrNull;
      if (current == null) {
        await Future<void>.delayed(Duration.zero);
        if (_disposed || generation != _generation) return;
        current = state.valueOrNull;
      }
      if (current == null) return;
      final incoming = {for (final item in list) item.containerID: item};
      state = AsyncData(
        current.copyWith(stats: {...current.stats, ...incoming}),
      );
    } catch (_) {
      // 资源统计失败不影响列表。
    }
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    _page = 1;
    state = const AsyncLoading<ContainersState>().copyWithPrevious(state);
    final result = await AsyncValue.guard(() => _fetch(page: 1));
    if (!_disposed && generation == _generation) {
      state = result;
      final data = result.valueOrNull;
      if (data != null) unawaited(_loadStats(data.items, generation));
    }
  }

  Future<void> poll() async {
    if (_disposed || _polling) return;
    final current = state.valueOrNull;
    if (current == null || state.isLoading) return;
    final generation = _generation;
    final filter = _state;
    final name = _name;
    final loaded = current.items.length;
    final pageSize = loaded < _pageSize ? _pageSize : loaded;
    _polling = true;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final results = await Future.wait<Object>([
        repository.searchContainers(
          state: filter,
          page: 1,
          pageSize: pageSize,
          name: name,
        ),
        repository.getContainerResourceStats(),
      ]);
      if (_disposed ||
          generation != _generation ||
          filter != _state ||
          name != _name) {
        return;
      }
      final latest = state.valueOrNull;
      if (latest == null || latest.items.length != loaded) return;
      final search = results[0] as ContainerSearchDto;
      final stats = results[1] as List<ContainerResourceStatsDto>;
      state = AsyncData(
        latest.copyWith(
          total: search.total,
          items: search.items,
          stats: {for (final item in stats) item.containerID: item},
        ),
      );
    } catch (_) {
      // 自动轮询失败静默，保留上一帧数据。
    } finally {
      _polling = false;
    }
  }

  Future<void> setFilter(String value) async {
    _state = switch (value) {
      'stopped' => 'exited',
      'abnormal' => 'dead',
      _ => value,
    };
    _page = 1;
    final generation = ++_generation;
    state = const AsyncLoading<ContainersState>().copyWithPrevious(state);
    final result = await AsyncValue.guard(() => _fetch(page: 1));
    if (!_disposed && generation == _generation) {
      state = result;
      final data = result.valueOrNull;
      if (data != null) unawaited(_loadStats(data.items, generation));
    }
  }

  Future<void> search(String value) async {
    _name = value.trim();
    _page = 1;
    final generation = ++_generation;
    state = const AsyncLoading<ContainersState>().copyWithPrevious(state);
    final result = await AsyncValue.guard(() => _fetch(page: 1));
    if (!_disposed && generation == _generation) {
      state = result;
      final data = result.valueOrNull;
      if (data != null) unawaited(_loadStats(data.items, generation));
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || _loadingMore) return;
    if (current.items.length >= current.total) return;
    _loadingMore = true;
    final generation = _generation;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await _fetch(page: _page + 1);
      if (_disposed || generation != _generation) return;
      _page++;
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        latest.copyWith(
          total: next.total,
          items: [...latest.items, ...next.items],
          loadingMore: false,
        ),
      );
      unawaited(_loadStats(next.items, generation));
    } catch (_) {
      if (!_disposed && generation == _generation) {
        final latest = state.valueOrNull ?? current;
        state = AsyncData(latest.copyWith(loadingMore: false));
      }
    } finally {
      _loadingMore = false;
    }
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
