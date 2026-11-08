import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/container/container_compose_dto.dart';
import '../../../../data/dto/container/container_item_stats_dto.dart';
import '../../../../data/dto/container/container_limit_dto.dart';
import '../../../../data/dto/container/container_option_dto.dart';
import '../../../../data/dto/container/container_status_dto.dart';
import '../../../../data/dto/container/image_dtos.dart';
import '../../../../data/dto/container/network_dtos.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';

export '../../../../data/repositories_impl/container_repository_impl.dart'
    show containerRepositoryProvider;

final containerStatusProvider = FutureProvider.autoDispose<ContainerStatusDto>((
  ref,
) async {
  final repository = await ref.watch(containerRepositoryProvider.future);
  return repository.getStatus();
}, name: 'containerStatusProvider');

final containerItemStatsProvider =
    FutureProvider.autoDispose<ContainerItemStatsDto?>((ref) async {
      final repository = await ref.watch(containerRepositoryProvider.future);
      try {
        return await repository.getItemStats();
      } catch (_) {
        return null;
      }
    }, name: 'containerItemStatsProvider');

final containerImagesProvider =
    FutureProvider.autoDispose<List<DockerImageInfo>>((ref) async {
      final repository = await ref.watch(containerRepositoryProvider.future);
      final page = await repository.searchImages(
        const PageImageReq(page: 1, pageSize: 100),
      );
      return page.items;
    }, name: 'containerImagesProvider');

final containerReposProvider = FutureProvider.autoDispose<List<ImageRepoDto>>((
  ref,
) async {
  final repository = await ref.watch(containerRepositoryProvider.future);
  return repository.listImageRepos();
}, name: 'containerImageReposProvider');

final containerNetworksProvider = FutureProvider.autoDispose<List<NetworkDto>>((
  ref,
) async {
  final repository = await ref.watch(containerRepositoryProvider.future);
  final page = await repository.searchNetworks(pageSize: 100);
  return page.items;
}, name: 'containerNetworksProvider');

final containerComposeProvider =
    FutureProvider.autoDispose<ContainerComposeSearchDto>((ref) async {
      final repository = await ref.watch(containerRepositoryProvider.future);
      return repository.searchCompose();
    }, name: 'composeProvider');

final containerVolumesProvider =
    FutureProvider.autoDispose<List<ContainerOptionDto>>((ref) async {
      final repository = await ref.watch(containerRepositoryProvider.future);
      return repository.getVolumes();
    }, name: 'containerVolumesProvider');

final containerLimitProvider = FutureProvider.autoDispose<ContainerLimitDto>((
  ref,
) async {
  final repository = await ref.watch(containerRepositoryProvider.future);
  return repository.getContainerLimit();
}, name: 'containerLimitProvider');
