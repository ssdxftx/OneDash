import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/common/page_result.dart';
import '../../../../data/dto/website/website_detail_dto.dart';
import '../../../../data/dto/website/website_create_metadata.dart';
import '../../../../data/dto/website/website_dto.dart';
import '../../../../data/dto/website/website_proxy_dto.dart';
import '../../../../data/dto/website/website_search_req.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';

final websitesProvider =
    AsyncNotifierProvider.autoDispose<
      WebsitesController,
      PageResult<WebsiteDto>
    >(WebsitesController.new, name: 'websitesProvider');

class WebsitesController
    extends AutoDisposeAsyncNotifier<PageResult<WebsiteDto>> {
  String _name = '';
  String _type = '';
  int _page = 1;
  int _generation = 0;
  bool _loadingMore = false;
  bool _disposed = false;

  bool get loadingMore => _loadingMore;

  @override
  Future<PageResult<WebsiteDto>> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _generation++;
    return _fetch(page: 1);
  }

  Future<PageResult<WebsiteDto>> _fetch({required int page}) async {
    final repository = await ref.read(websiteRepositoryProvider.future);
    return repository.searchWebsites(
      WebsiteSearchReq(name: _name, type: _type, page: page, pageSize: 20),
    );
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    _page = 1;
    state = const AsyncLoading<PageResult<WebsiteDto>>().copyWithPrevious(
      state,
    );
    final result = await AsyncValue.guard(() => _fetch(page: 1));
    if (!_disposed && generation == _generation) state = result;
  }

  Future<void> search(String value) async {
    _name = value.trim();
    _page = 1;
    final generation = ++_generation;
    state = const AsyncLoading<PageResult<WebsiteDto>>().copyWithPrevious(
      state,
    );
    final result = await AsyncValue.guard(() => _fetch(page: 1));
    if (!_disposed && generation == _generation) state = result;
  }

  Future<void> setType(String type) async {
    _type = type;
    _page = 1;
    final generation = ++_generation;
    state = const AsyncLoading<PageResult<WebsiteDto>>().copyWithPrevious(
      state,
    );
    final result = await AsyncValue.guard(() => _fetch(page: 1));
    if (!_disposed && generation == _generation) state = result;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || _loadingMore) return;
    if (current.items.length >= current.total) return;
    _loadingMore = true;
    final generation = _generation;
    try {
      final next = await _fetch(page: _page + 1);
      if (_disposed || generation != _generation) return;
      _page++;
      state = AsyncData(
        PageResult<WebsiteDto>(
          total: next.total,
          items: [...current.items, ...next.items],
        ),
      );
    } catch (_) {
      if (!_disposed && generation == _generation) state = AsyncData(current);
    } finally {
      _loadingMore = false;
    }
  }
}

final websiteDetailProvider = FutureProvider.autoDispose
    .family<WebsiteDetailDto, int>((ref, websiteId) {
      return ref
          .watch(websiteRepositoryProvider.future)
          .then((repository) => repository.getWebsite(websiteId));
    }, name: 'websiteDetailProvider');

final websiteCreateMetadataProvider =
    FutureProvider.autoDispose<WebsiteCreateMetadata>((ref) {
      return ref
          .watch(websiteRepositoryProvider.future)
          .then((repository) => repository.getCreateMetadata());
    }, name: 'websiteCreateMetadataProvider');

final websiteProxiesProvider = FutureProvider.autoDispose
    .family<List<WebsiteProxyDto>, int>((ref, websiteId) async {
      final repository = await ref.watch(websiteRepositoryProvider.future);
      return repository.listWebsiteProxies(websiteId);
    }, name: 'websiteProxiesProvider');
