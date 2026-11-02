import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/file/file_item_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';

class FilesState {
  const FilesState({
    required this.folder,
    required this.items,
    required this.total,
    this.loadingMore = false,
  });

  final FileItemDto folder;
  final List<FileItemDto> items;
  final int total;
  final bool loadingMore;

  FilesState copyWith({
    FileItemDto? folder,
    List<FileItemDto>? items,
    int? total,
    bool? loadingMore,
  }) {
    return FilesState(
      folder: folder ?? this.folder,
      items: items ?? this.items,
      total: total ?? this.total,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

final filesProvider = AsyncNotifierProvider.autoDispose
    .family<FilesController, FilesState, String>(
      FilesController.new,
      name: 'filesProvider',
    );

class FilesController
    extends AutoDisposeFamilyAsyncNotifier<FilesState, String> {
  int _page = 1;
  String _search = '';
  String _sortBy = 'name';
  bool _loadingMore = false;

  @override
  Future<FilesState> build(String path) async {
    final repository = await ref.read(fileRepositoryProvider.future);
    final folder = await repository.searchFiles(
      path: path,
      page: 1,
      pageSize: 100,
      search: _search,
      sortBy: _sortBy,
    );
    return FilesState(
      folder: folder,
      items: _sort(folder.items ?? const []),
      total: folder.itemTotal,
    );
  }

  List<FileItemDto> _sort(List<FileItemDto> items) {
    final sorted = List<FileItemDto>.of(items);
    sorted.sort((a, b) {
      if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
      return switch (_sortBy) {
        'size' => b.size.compareTo(a.size),
        'modTime' => b.modTime.compareTo(a.modTime),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
    });
    return sorted;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<FilesState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => build(arg));
    _page = 1;
  }

  Future<void> search(String value) async {
    _search = value.trim();
    _page = 1;
    state = const AsyncLoading<FilesState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => build(arg));
  }

  Future<void> setSort(String sortBy) async {
    _sortBy = sortBy;
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(items: _sort(current.items)));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || _loadingMore) return;
    if (current.items.length >= current.total) return;
    _loadingMore = true;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final folder = await repository.searchFiles(
        path: arg,
        page: _page + 1,
        pageSize: 100,
        search: _search,
        sortBy: _sortBy,
      );
      _page++;
      state = AsyncData(
        current.copyWith(
          items: _sort([...current.items, ...?folder.items]),
          total: folder.itemTotal,
          loadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    } finally {
      _loadingMore = false;
    }
  }
}
