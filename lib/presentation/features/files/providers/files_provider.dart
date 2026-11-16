import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/file/file_item_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';

class FilesState {
  const FilesState({
    required this.folder,
    required this.items,
    required this.total,
    this.remarks = const {},
    this.loadingMore = false,
  });

  final FileItemDto folder;
  final List<FileItemDto> items;
  final int total;
  final Map<String, String> remarks;
  final bool loadingMore;

  FilesState copyWith({
    FileItemDto? folder,
    List<FileItemDto>? items,
    int? total,
    Map<String, String>? remarks,
    bool? loadingMore,
  }) {
    return FilesState(
      folder: folder ?? this.folder,
      items: items ?? this.items,
      total: total ?? this.total,
      remarks: remarks ?? this.remarks,
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
  int _generation = 0;
  String _search = '';
  String _sortBy = 'name';
  bool _loadingMore = false;
  bool _disposed = false;

  @override
  Future<FilesState> build(String path) async {
    _disposed = false;
    _generation++;
    ref.onDispose(() => _disposed = true);
    return _fetch(path, page: 1);
  }

  Future<FilesState> _fetch(String path, {required int page}) async {
    final repository = await ref.read(fileRepositoryProvider.future);
    final folder = await repository.searchFiles(
      path: path,
      page: page,
      pageSize: 100,
      search: _search,
      sortBy: _sortBy,
    );
    final items = _sort(folder.items ?? const []);
    Map<String, String> remarks = const {};
    if (items.isNotEmpty) {
      try {
        remarks = await repository.getFileRemarks(
          items.map((item) => item.path).toList(growable: false),
        );
      } catch (_) {
        remarks = const {};
      }
    }
    return FilesState(
      folder: folder,
      items: items,
      total: folder.itemTotal,
      remarks: remarks,
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
    final generation = ++_generation;
    _page = 1;
    state = const AsyncLoading<FilesState>().copyWithPrevious(state);
    final result = await AsyncValue.guard(() => _fetch(arg, page: 1));
    if (!_disposed && generation == _generation) state = result;
  }

  Future<void> search(String value) async {
    _search = value.trim();
    _page = 1;
    final generation = ++_generation;
    state = const AsyncLoading<FilesState>().copyWithPrevious(state);
    final result = await AsyncValue.guard(() => _fetch(arg, page: 1));
    if (!_disposed && generation == _generation) state = result;
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
    final generation = _generation;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final folder = await _fetch(arg, page: _page + 1);
      if (_disposed || generation != _generation) return;
      final latest = state.valueOrNull ?? current;
      _page++;
      state = AsyncData(
        latest.copyWith(
          items: _sort([...latest.items, ...folder.items]),
          total: folder.total,
          remarks: {...latest.remarks, ...folder.remarks},
          loadingMore: false,
        ),
      );
    } catch (_) {
      if (!_disposed && generation == _generation) {
        state = AsyncData(current.copyWith(loadingMore: false));
      }
    } finally {
      _loadingMore = false;
    }
  }
}
