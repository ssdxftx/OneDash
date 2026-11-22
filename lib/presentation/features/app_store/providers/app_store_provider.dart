import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/app/app_catalog_dto.dart';
import '../../../../data/dto/app/app_catalog_search_req.dart';
import '../../../../data/dto/app/app_tag_dto.dart';
import '../../../../data/dto/app/app_detail_dto.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/dto/app/app_installed_info_dto.dart';
import '../../../../data/dto/app/app_ignored_dto.dart';
import '../../../../data/dto/app/app_installed_search_req.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../server_detail/providers/active_server_provider.dart';

final appCatalogProvider = AsyncNotifierProvider.autoDispose
    .family<AppCatalogController, PageResult<AppCatalogDto>, String>(
      AppCatalogController.new,
      name: 'appCatalogProvider',
    );

class AppCatalogController
    extends AutoDisposeFamilyAsyncNotifier<PageResult<AppCatalogDto>, String> {
  static const _pageSize = 100;

  int _page = 1;
  int _generation = 0;
  bool _loadingMore = false;
  bool _disposed = false;

  @override
  Future<PageResult<AppCatalogDto>> build(String query) async {
    _disposed = false;
    _page = 1;
    _loadingMore = false;
    _generation++;
    ref.watch(activeServerIdProvider);
    ref.onDispose(() => _disposed = true);
    if (query.isEmpty) {
      final link = ref.keepAlive();
      final timer = Timer(const Duration(minutes: 5), link.close);
      ref.onDispose(() {
        timer.cancel();
        link.close();
      });
    }
    return _fetch(query, 1);
  }

  Future<PageResult<AppCatalogDto>> _fetch(String query, int page) async {
    final repository = await ref.read(appRepositoryProvider.future);
    return repository.searchApps(
      AppCatalogSearchReq(page: page, pageSize: _pageSize, name: query),
    );
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    _page = 1;
    state = const AsyncLoading<PageResult<AppCatalogDto>>().copyWithPrevious(
      state,
    );
    final result = await AsyncValue.guard(() => _fetch(arg, 1));
    if (!_disposed && generation == _generation) state = result;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || _loadingMore) return;
    if (current.items.length >= current.total) return;
    _loadingMore = true;
    final generation = _generation;
    try {
      final next = await _fetch(arg, _page + 1);
      if (_disposed || generation != _generation) return;
      _page++;
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        PageResult<AppCatalogDto>(
          total: next.total,
          items: [...latest.items, ...next.items],
        ),
      );
    } catch (_) {
      if (!_disposed) state = AsyncData(current);
    } finally {
      _loadingMore = false;
    }
  }
}

final appTagsProvider = FutureProvider.autoDispose<List<AppTagDto>>((ref) {
  ref.watch(activeServerIdProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(() {
    timer.cancel();
    link.close();
  });
  return ref
      .watch(appRepositoryProvider.future)
      .then((repository) => repository.listAppTags());
}, name: 'appTagsProvider');

final installedAppsProvider =
    AsyncNotifierProvider.autoDispose<
      InstalledAppsController,
      PageResult<AppInstalledDto>
    >(InstalledAppsController.new, name: 'installedAppsProvider');

class InstalledAppsController
    extends AutoDisposeAsyncNotifier<PageResult<AppInstalledDto>> {
  static const _pageSize = 100;

  int _page = 1;
  int _generation = 0;
  bool _loadingMore = false;
  bool _disposed = false;

  @override
  Future<PageResult<AppInstalledDto>> build() async {
    _disposed = false;
    _page = 1;
    _loadingMore = false;
    _generation++;
    ref.watch(activeServerIdProvider);
    ref.onDispose(() => _disposed = true);
    final link = ref.keepAlive();
    final timer = Timer(const Duration(minutes: 5), link.close);
    ref.onDispose(() {
      timer.cancel();
      link.close();
    });
    return _fetch(1);
  }

  Future<PageResult<AppInstalledDto>> _fetch(int page) async {
    final repository = await ref.read(appRepositoryProvider.future);
    return repository.searchInstalledApps(
      AppInstalledSearchReq(page: page, pageSize: _pageSize),
    );
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    _page = 1;
    state = const AsyncLoading<PageResult<AppInstalledDto>>().copyWithPrevious(
      state,
    );
    final result = await AsyncValue.guard(() => _fetch(1));
    if (!_disposed && generation == _generation) state = result;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || _loadingMore) return;
    if (current.items.length >= current.total) return;
    _loadingMore = true;
    final generation = _generation;
    try {
      final next = await _fetch(_page + 1);
      if (_disposed || generation != _generation) return;
      _page++;
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        PageResult<AppInstalledDto>(
          total: next.total,
          items: [...latest.items, ...next.items],
        ),
      );
    } catch (_) {
      if (!_disposed) state = AsyncData(current);
    } finally {
      _loadingMore = false;
    }
  }
}

final upgradableAppsProvider =
    AsyncNotifierProvider.autoDispose<
      UpgradableAppsController,
      PageResult<AppInstalledDto>
    >(UpgradableAppsController.new, name: 'upgradableAppsProvider');

class UpgradableAppsController
    extends AutoDisposeAsyncNotifier<PageResult<AppInstalledDto>> {
  static const _pageSize = 100;

  int _page = 1;
  int _generation = 0;
  bool _loadingMore = false;
  bool _disposed = false;

  @override
  Future<PageResult<AppInstalledDto>> build() async {
    _disposed = false;
    _page = 1;
    _loadingMore = false;
    _generation++;
    ref.watch(activeServerIdProvider);
    ref.onDispose(() => _disposed = true);
    final link = ref.keepAlive();
    final timer = Timer(const Duration(minutes: 2), link.close);
    ref.onDispose(() {
      timer.cancel();
      link.close();
    });
    return _fetch(1);
  }

  Future<PageResult<AppInstalledDto>> _fetch(int page) async {
    final repository = await ref.read(appRepositoryProvider.future);
    return repository.searchInstalledApps(
      AppInstalledSearchReq(page: page, pageSize: _pageSize, update: true),
    );
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    _page = 1;
    state = const AsyncLoading<PageResult<AppInstalledDto>>().copyWithPrevious(
      state,
    );
    final result = await AsyncValue.guard(() => _fetch(1));
    if (!_disposed && generation == _generation) state = result;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || _loadingMore) return;
    if (current.items.length >= current.total) return;
    _loadingMore = true;
    final generation = _generation;
    try {
      final next = await _fetch(_page + 1);
      if (_disposed || generation != _generation) return;
      _page++;
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        PageResult<AppInstalledDto>(
          total: next.total,
          items: [...latest.items, ...next.items],
        ),
      );
    } catch (_) {
      if (!_disposed) state = AsyncData(current);
    } finally {
      _loadingMore = false;
    }
  }
}

void invalidateInstalledAppLists(WidgetRef ref) {
  ref.invalidate(installedAppsProvider);
  ref.invalidate(upgradableAppsProvider);
}

final appDetailProvider = FutureProvider.autoDispose
    .family<AppDetailDto, String>((ref, key) {
      ref.watch(activeServerIdProvider);
      return ref
          .watch(appRepositoryProvider.future)
          .then((repository) => repository.getAppDetail(key));
    }, name: 'appDetailProvider');

final installedInfoProvider = FutureProvider.autoDispose
    .family<AppInstalledInfoDto, int>((ref, id) {
      ref.watch(activeServerIdProvider);
      return ref
          .watch(appRepositoryProvider.future)
          .then((repository) => repository.getInstalledInfo(id));
    }, name: 'installedInfoProvider');

final ignoredAppsProvider = FutureProvider.autoDispose<List<AppIgnoredDto>>((
  ref,
) async {
  ref.watch(activeServerIdProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(seconds: 60), link.close);
  ref.onDispose(() {
    timer.cancel();
    link.close();
  });
  final repository = await ref.watch(appRepositoryProvider.future);
  return repository.getIgnoredApps();
}, name: 'ignoredAppsProvider');

final installedIgnoredProvider = FutureProvider.autoDispose
    .family<AppIgnoredDto?, int>((ref, appDetailId) async {
      final ignored = await ref.watch(ignoredAppsProvider.future);
      for (final item in ignored) {
        if (item.appDetailId == appDetailId) return item;
      }
      return null;
    }, name: 'installedIgnoredProvider');
