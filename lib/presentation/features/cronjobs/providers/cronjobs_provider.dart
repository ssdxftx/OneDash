import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/common/page_result.dart';
import '../../../../data/dto/cronjob/cronjob_dto.dart';
import '../../../../data/repositories_impl/cronjob_repository_impl.dart';

final cronjobsProvider =
    AsyncNotifierProvider.autoDispose<
      CronjobsController,
      PageResult<CronjobDto>
    >(CronjobsController.new, name: 'cronjobsProvider');

class CronjobsController
    extends AutoDisposeAsyncNotifier<PageResult<CronjobDto>> {
  static const _pageSize = 100;

  int _page = 1;
  bool _loadingMore = false;
  bool _disposed = false;

  @override
  Future<PageResult<CronjobDto>> build() async {
    _disposed = false;
    _page = 1;
    ref.onDispose(() => _disposed = true);
    return _fetch(1);
  }

  Future<PageResult<CronjobDto>> _fetch(int page) async {
    final repository = await ref.watch(cronjobRepositoryProvider.future);
    return repository.searchCronjobs({
      'page': page,
      'pageSize': _pageSize,
      'info': '',
      'orderBy': 'createdAt',
      'order': 'descending',
    });
  }

  Future<void> refresh() async {
    _page = 1;
    state = const AsyncLoading<PageResult<CronjobDto>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() => _fetch(1));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || _loadingMore) return;
    if (current.items.length >= current.total) return;
    _loadingMore = true;
    try {
      final next = await _fetch(_page + 1);
      if (_disposed) return;
      _page++;
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        PageResult<CronjobDto>(
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

final cronjobRecordsProvider = FutureProvider.autoDispose
    .family<PageResult<CronjobRecordDto>, int>((ref, id) {
      final now = DateTime.now();
      return ref
          .watch(cronjobRepositoryProvider.future)
          .then(
            (repository) => repository.searchRecords({
              'page': 1,
              'pageSize': 50,
              'cronjobID': id,
              'startTime': now
                  .subtract(const Duration(days: 30))
                  .toUtc()
                  .toIso8601String(),
              'endTime': now.toUtc().toIso8601String(),
              'status': '',
            }),
          );
    }, name: 'cronjobRecordsProvider');
