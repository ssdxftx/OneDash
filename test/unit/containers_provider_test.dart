import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onedash/data/dto/container/container_resource_stats_dto.dart';
import 'package:onedash/data/dto/container/container_search_dto.dart';
import 'package:onedash/data/repositories_impl/container_repository_impl.dart';
import 'package:onedash/domain/repositories/container_repository.dart';
import 'package:onedash/presentation/features/containers/providers/containers_provider.dart';

class _FakeContainerRepository implements ContainerRepository {
  final stats = Completer<List<ContainerResourceStatsDto>>();
  int statsCalls = 0;
  int searchCalls = 0;
  List<String>? lastIds;

  @override
  Future<ContainerSearchDto> searchContainers({
    String state = 'all',
    int page = 1,
    int pageSize = 20,
    String filters = '',
    String orderBy = 'createdAt',
    String order = 'null',
    bool excludeAppStore = false,
    String name = '',
  }) async {
    searchCalls++;
    return const ContainerSearchDto(
      total: 1,
      items: [
        ContainerItemDto(
          containerID: 'container-1',
          name: 'web',
          imageID: 'image-1',
          imageName: 'nginx:latest',
          createTime: '',
          state: 'running',
          runTime: '',
          isFromApp: false,
          isFromCompose: false,
          isPinned: false,
          description: '',
        ),
      ],
    );
  }

  @override
  Future<List<ContainerResourceStatsDto>> getContainerResourceStats({
    List<String>? ids,
  }) {
    statsCalls++;
    lastIds = ids;
    return stats.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('container list renders before resource stats complete', () async {
    final repository = _FakeContainerRepository();
    final container = ProviderContainer(
      overrides: [
        containerRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      containersProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final first = await container.read(containersProvider.future);

    expect(first.items, hasLength(1));
    expect(first.items.single.state, 'running');
    expect(first.stats, isEmpty);
    expect(repository.statsCalls, 1);
    expect(repository.lastIds, const ['container-1']);

    repository.stats.complete(const [
      ContainerResourceStatsDto(
        containerID: 'container-1',
        cpuTotalUsage: 1,
        systemUsage: 1,
        cpuPercent: 12.5,
        percpuUsage: 1,
        memoryCache: 0,
        memoryUsage: 1024,
        memoryLimit: 4096,
        memoryPercent: 25,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final updated = container.read(containersProvider).valueOrNull;
    expect(updated?.stats['container-1']?.cpuPercent, 12.5);
  });

  test('poll refreshes stats without switching to loading', () async {
    final repository = _FakeContainerRepository();
    repository.stats.complete(const [
      ContainerResourceStatsDto(
        containerID: 'container-1',
        cpuTotalUsage: 1,
        systemUsage: 1,
        cpuPercent: 12.5,
        percpuUsage: 1,
        memoryCache: 0,
        memoryUsage: 1024,
        memoryLimit: 4096,
        memoryPercent: 25,
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        containerRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      containersProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container.read(containersProvider.future);
    final searchBefore = repository.searchCalls;

    await container.read(containersProvider.notifier).poll();

    final state = container.read(containersProvider);
    expect(state.isLoading, isFalse);
    expect(state.valueOrNull?.stats['container-1']?.cpuPercent, 12.5);
    expect(repository.searchCalls, searchBefore + 1);
  });
}
