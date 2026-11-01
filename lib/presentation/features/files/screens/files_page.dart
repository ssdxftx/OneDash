import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/file_type_utils.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../providers/files_provider.dart';
import '../widgets/file_permission_sheet.dart';
import '../../../common/states/error_toast.dart';

class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({
    super.key,
    required this.serverId,
    required this.initialPath,
  });

  final int serverId;
  final String initialPath;

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
  final _searchController = TextEditingController();
  bool _searching = false;
  bool _uploading = false;
  final Set<String> _selected = {};
  final Map<String, int> _dirSizes = {};
  final Set<String> _calculating = {};

  bool get _selectionMode => _selected.isNotEmpty;

  String get _path => widget.initialPath.isEmpty ? '/' : widget.initialPath;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPath(String path) {
    context.push(
      '/s/${widget.serverId}/files?path=${Uri.encodeComponent(path)}',
    );
  }

  String _parentOf(String path) {
    if (path == '/' || path.isEmpty) return '/';
    final normalized = path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
    final index = normalized.lastIndexOf('/');
    if (index <= 0) return '/';
    return normalized.substring(0, index);
  }

  String _join(String dir, String name) {
    if (dir == '/') return '/$name';
    return '$dir/$name';
  }

  Future<void> _upload() async {
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;
    setState(() => _uploading = true);
    var uploadedAny = false;
    try {
      for (final file in result.files) {
        if (!mounted) return;
        final localPath = file.path;
        if (localPath == null) continue;
        final uploaded = await showAppSheet<bool>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          builder: (sheetContext) => _UploadSheet(
            filePath: localPath,
            fileName: file.name,
            fileSize: file.size,
            targetPath: _path,
          ),
        );
        if (uploaded == true) uploadedAny = true;
        if (uploaded != true) break;
      }
      if (!mounted) return;
      if (uploadedAny) {
        AppToast.success(context, AppLocalizations.of(context).action_done);
        ref.invalidate(filesProvider(_path));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _create({required bool isDir}) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await showAppSheet<String>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isDir ? l10n.files_new_folder : l10n.files_new_file,
            style: AppTextStyles.titleL,
          ),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            controller: controller,
            hint: l10n.files_nameHint,
            autofocus: true,
          ),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_create,
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.createFileOrDir(path: _join(_path, name), isDir: isDir);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(filesProvider(_path));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _compress(FileItemDto item) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: '${item.name}.zip');
    final name = await showAppSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.files_compress, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(controller: controller, label: l10n.files_archiveName),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_create,
            onPressed: () =>
                Navigator.of(sheetContext).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.compressFiles(
        files: [item.path],
        type: 'zip',
        dst: _path,
        name: name,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(filesProvider(_path));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _extract(FileItemDto item) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.files_extractTitle,
      message: l10n.files_extractMessage(item.name),
      confirmLabel: l10n.files_actionDecompress,
      danger: false,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final type = item.extension.replaceFirst('.', '');
      await repository.decompressFile(
        path: item.path,
        type: type.isEmpty ? 'zip' : type,
        dst: _path,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(filesProvider(_path));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _rename(FileItemDto item) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: item.name);
    final name = await showAppSheet<String>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.files_rename, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          AppTextField(controller: controller, autofocus: true),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_save,
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || name == item.name) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.renameFile(
        oldPath: item.path,
        newPath: _join(_path, name),
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(filesProvider(_path));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(FileItemDto item) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.files_delete,
      message: item.name,
      confirmLabel: l10n.action_delete,
    );
    if (!confirmed) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.deleteFile(path: item.path, isDir: item.isDir);
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(filesProvider(_path));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _previewImage(FileItemDto item) async {
    if (item.size > 30 * 1024 * 1024) {
      AppToast.warning(
        context,
        AppLocalizations.of(context).files_imageTooLarge,
      );
      return;
    }
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final bytes = await repository.downloadBytes(item.path);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black,
        builder: (dialogContext) => Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 6,
                  child: Center(child: Image.memory(bytes)),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(dialogContext).top + 8,
                right: 8,
                child: IconButton.filledTonal(
                  tooltip: AppLocalizations.of(context).action_close,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _download(FileItemDto item) async {
    if (item.size > 50 * 1024 * 1024) {
      AppToast.warning(
        context,
        AppLocalizations.of(context).files_downloadTooLarge,
      );
      return;
    }
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final bytes = await repository.downloadBytes(item.path);
      if (!mounted) return;
      final savePath = await FilePicker.saveFile(
        fileName: item.name,
        bytes: bytes,
      );
      if (savePath == null) return;
      if (!mounted) return;
      AppToast.success(
        context,
        AppLocalizations.of(context).files_savedTo(savePath),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _share(FileItemDto item) async {
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final share = await repository.createFileShare(
        path: item.path,
        expireMinutes: 60,
      );
      if (!mounted) return;
      await Clipboard.setData(ClipboardData(text: share.code));
      if (!mounted) return;
      AppToast.success(context, share.code);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  void _toggleSelection(FileItemDto item) {
    setState(() {
      if (!_selected.remove(item.path)) _selected.add(item.path);
    });
  }

  void _clearSelection() => setState(_selected.clear);

  void _selectAll(List<FileItemDto> items) {
    setState(() {
      _selected
        ..clear()
        ..addAll(items.map((item) => item.path));
    });
  }

  Future<void> _permission(FileItemDto item) async {
    final updated = await showFilePermissionSheet(context, item: item);
    if (updated && mounted) {
      ref.invalidate(filesProvider(_path));
    }
  }

  Future<void> _calculateDirSize(FileItemDto item) async {
    if (_calculating.contains(item.path)) return;
    setState(() => _calculating.add(item.path));
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final size = await repository.getDepthSize(item.path);
      if (!mounted) return;
      setState(() => _dirSizes[item.path] = size);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _calculating.remove(item.path));
    }
  }

  Future<void> _batchDelete(List<FileItemDto> items) async {
    final l10n = AppLocalizations.of(context);
    final selected = items
        .where((item) => _selected.contains(item.path))
        .toList(growable: false);
    if (selected.isEmpty) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.files_batchDelete,
      message: l10n.files_batchDeleteMessage(selected.length),
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final dirs = selected
          .where((item) => item.isDir)
          .map((item) => item.path)
          .toList(growable: false);
      final files = selected
          .where((item) => !item.isDir)
          .map((item) => item.path)
          .toList(growable: false);
      if (dirs.isNotEmpty) {
        await repository.batchDeleteFiles(paths: dirs, isDir: true);
      }
      if (files.isNotEmpty) {
        await repository.batchDeleteFiles(paths: files, isDir: false);
      }
      if (!mounted) return;
      _clearSelection();
      AppToast.success(context, l10n.action_done);
      ref.invalidate(filesProvider(_path));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _showActions(FileItemDto item) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            item.isDir
                ? l10n.files_itemCount(item.itemTotal)
                : '${formatBytes(item.size)} · ${item.modTime}',
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              if (!item.isDir && FileTypeUtils.isEditable(item))
                SplitListTile(
                  leading: const Icon(TablerIcons.edit),
                  title: l10n.action_edit,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      '/s/${widget.serverId}/files/edit?path=${Uri.encodeComponent(item.path)}',
                    );
                  },
                ),
              if (FileTypeUtils.isImage(item))
                SplitListTile(
                  leading: const Icon(TablerIcons.photo),
                  title: l10n.files_actionPreviewImage,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _previewImage(item);
                  },
                ),
              SplitListTile(
                leading: const Icon(TablerIcons.download),
                title: l10n.files_download,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _download(item);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.share),
                title: l10n.files_share,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _share(item);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.file_zip),
                title: l10n.files_compress,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _compress(item);
                },
              ),
              if (FileTypeUtils.isArchive(item))
                SplitListTile(
                  leading: const Icon(TablerIcons.package_export),
                  title: l10n.files_extractToCurrent,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _extract(item);
                  },
                ),
              SplitListTile(
                leading: const Icon(TablerIcons.shield_lock),
                title: l10n.files_permission,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _permission(item);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.checkbox),
                title: l10n.files_selectAll,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _toggleSelection(item);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.pencil),
                title: l10n.files_rename,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _rename(item);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.files_delete,
                danger: true,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _delete(item);
                },
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final files = ref.watch(filesProvider(_path));
    final folderName = _path == '/'
        ? l10n.files_rootDirectory
        : _path.split('/').where((e) => e.isNotEmpty).last;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? l10n.files_selectCount(_selected.length)
              : folderName,
          style: AppTextStyles.titleM,
        ),
        leading: _selectionMode
            ? IconButton(
                tooltip: l10n.files_cancelSelection,
                icon: const Icon(TablerIcons.x),
                onPressed: _clearSelection,
              )
            : _path == '/'
            ? null
            : IconButton(
                tooltip: l10n.files_parent,
                icon: const Icon(TablerIcons.arrow_up),
                onPressed: () => _openPath(_parentOf(_path)),
              ),
        actions: _selectionMode
            ? [
                TextButton(
                  onPressed: () => _selectAll(
                    ref.read(filesProvider(_path)).valueOrNull?.items ??
                        const [],
                  ),
                  child: Text(l10n.files_selectAll),
                ),
                TextButton(
                  onPressed: _clearSelection,
                  child: Text(l10n.files_cancelSelection),
                ),
              ]
            : [
                AppIconButton(
                  icon: TablerIcons.sparkles,
                  tooltip: l10n.files_aiSearch,
                  onPressed: () => context.push(
                    '/s/${widget.serverId}/files/ai-search'
                    '?path=${Uri.encodeComponent(_path)}',
                  ),
                ),
                AppIconButton(
                  icon: _searching ? TablerIcons.x : TablerIcons.search,
                  tooltip: l10n.action_search,
                  onPressed: () {
                    setState(() => _searching = !_searching);
                    if (!_searching) {
                      _searchController.clear();
                      ref.read(filesProvider(_path).notifier).search('');
                    }
                  },
                ),
                PopupMenuButton<String>(
                  tooltip: l10n.files_sort,
                  icon: const Icon(TablerIcons.arrows_sort),
                  onSelected: (value) =>
                      ref.read(filesProvider(_path).notifier).setSort(value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'name',
                      child: Text(l10n.files_sortName),
                    ),
                    PopupMenuItem(
                      value: 'size',
                      child: Text(l10n.files_sortSize),
                    ),
                    PopupMenuItem(
                      value: 'modTime',
                      child: Text(l10n.files_sortModifiedTime),
                    ),
                  ],
                ),
              ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_searching ? 60 : 44),
          child: Column(
            children: [
              if (_searching)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.s16,
                    0,
                    AppTokens.s16,
                    AppTokens.s8,
                  ),
                  child: SearchField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (value) =>
                        ref.read(filesProvider(_path).notifier).search(value),
                  ),
                ),
              _Breadcrumb(path: _path, onTap: _openPath),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
              tooltip: l10n.files_upload,
              onPressed: _uploading ? null : _upload,
              child: _uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(TablerIcons.upload),
            ),
      body: AsyncStateView(
        value: files,
        onRetry: () => ref.read(filesProvider(_path).notifier).refresh(),
        loading: const SkeletonList(itemCount: 10, itemHeight: 56),
        isEmpty: (state) => state.items.isEmpty,
        empty: EmptyState(
          icon: TablerIcons.folder_open,
          title: l10n.files_empty_title,
          message: l10n.files_empty_message,
          actionLabel: l10n.files_upload,
          onAction: _upload,
        ),
        builder: (state) => RefreshIndicator(
          onRefresh: () => ref.read(filesProvider(_path).notifier).refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 400) {
                ref.read(filesProvider(_path).notifier).loadMore();
              }
              return false;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemExtent: 72,
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _FileTile(
                  item: item,
                  selected: _selected.contains(item.path),
                  dirSize: _dirSizes[item.path],
                  calculating: _calculating.contains(item.path),
                  onTap: _selectionMode
                      ? () => _toggleSelection(item)
                      : item.isDir
                      ? () => _openPath(item.path)
                      : FileTypeUtils.isEditable(item)
                      ? () => context.push(
                          '/s/${widget.serverId}/files/edit?path=${Uri.encodeComponent(item.path)}',
                        )
                      : () => _showActions(item),
                  onLongPress: () => _toggleSelection(item),
                  onMore: () => _showActions(item),
                  onCalculateSize: item.isDir
                      ? () => _calculateDirSize(item)
                      : null,
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: _selectionMode
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.s16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.files_selectCount(_selected.length),
                            style: AppTextStyles.caption.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _selectAll(
                            ref.read(filesProvider(_path)).valueOrNull?.items ??
                                const [],
                          ),
                          child: Text(l10n.files_selectAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.s8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _batchDelete(
                          ref.read(filesProvider(_path)).valueOrNull?.items ??
                              const [],
                        ),
                        icon: const Icon(TablerIcons.trash),
                        label: Text(
                          '${l10n.files_batchDelete} (${_selected.length})',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      persistentFooterButtons: _selectionMode
          ? null
          : [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _create(isDir: true),
                    icon: const Icon(TablerIcons.folder_plus),
                    label: Text(l10n.files_new_folder),
                  ),
                  TextButton.icon(
                    onPressed: () => _create(isDir: false),
                    icon: const Icon(TablerIcons.file_plus),
                    label: Text(l10n.files_new_file),
                  ),
                  const Spacer(),
                  Text(
                    l10n.files_itemCount(files.valueOrNull?.total ?? 0),
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.path, required this.onTap});

  final String path;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final segments = path.split('/').where((e) => e.isNotEmpty).toList();
    final scheme = context.scheme;
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
        children: [
          InkWell(
            onTap: () => onTap('/'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.s4),
              child: Center(
                child: Text(
                  l10n.files_rootDirectory,
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          for (var i = 0; i < segments.length; i++)
            InkWell(
              onTap: () => onTap('/${segments.take(i + 1).join('/')}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.s4),
                child: Center(
                  child: Text(
                    segments[i],
                    style: AppTextStyles.bodyS.copyWith(
                      color: i == segments.length - 1
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                      fontWeight: i == segments.length - 1
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.item,
    required this.onTap,
    required this.onLongPress,
    required this.onMore,
    this.selected = false,
    this.dirSize,
    this.calculating = false,
    this.onCalculateSize,
  });

  final FileItemDto item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMore;
  final bool selected;
  final int? dirSize;
  final bool calculating;
  final VoidCallback? onCalculateSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final icon = item.isDir
        ? TablerIcons.folder
        : FileTypeUtils.isImage(item)
        ? TablerIcons.photo
        : FileTypeUtils.isArchive(item)
        ? TablerIcons.file_zip
        : FileTypeUtils.isEditable(item)
        ? TablerIcons.file_text
        : TablerIcons.file;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: selected ? scheme.primaryContainer.withValues(alpha: 0.5) : null,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
        child: Row(
          children: [
            if (selected)
              Padding(
                padding: const EdgeInsets.only(right: AppTokens.s8),
                child: Icon(
                  TablerIcons.circle_check_filled,
                  size: AppTokens.iconList,
                  color: scheme.primary,
                ),
              ),
            Icon(
              icon,
              size: AppTokens.iconLeading,
              color: item.isDir ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.isDir
                        ? l10n.files_itemCount(item.itemTotal)
                        : '${formatBytes(item.size)} · ${item.modTime}',
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (item.isDir)
              const Icon(TablerIcons.chevron_right, size: AppTokens.iconList)
            else
              IconButton(
                tooltip: l10n.action_more,
                icon: const Icon(TablerIcons.dots, size: AppTokens.iconList),
                onPressed: onLongPress,
              ),
          ],
        ),
      ),
    );
  }
}

enum _UploadStatus { uploading, paused, failed }

class _UploadSheet extends ConsumerStatefulWidget {
  const _UploadSheet({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.targetPath,
  });

  final String filePath;
  final String fileName;
  final int fileSize;
  final String targetPath;

  @override
  ConsumerState<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<_UploadSheet> {
  static const _chunkThreshold = 10 * 1024 * 1024;
  late final bool _chunked;
  late final String? _uploadId;

  CancelToken? _cancelToken;
  _UploadStatus _status = _UploadStatus.uploading;
  double _progress = 0;
  int _offset = 0;
  String? _error;

  String _newUploadId() {
    final random = Random.secure();
    return List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  void initState() {
    super.initState();
    _chunked = widget.fileSize > _chunkThreshold;
    _uploadId = _chunked ? _newUploadId() : null;
    unawaited(_start());
  }

  Future<void> _start() async {
    final token = CancelToken();
    _cancelToken = token;
    setState(() {
      _status = _UploadStatus.uploading;
      _error = null;
    });
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.uploadFile(
        filePath: widget.filePath,
        targetPath: widget.targetPath,
        uploadId: _uploadId,
        startOffset: _offset,
        cancelToken: token,
        onProgress: (value) {
          if (mounted) setState(() => _progress = value);
        },
        onChunkUploaded: (value) {
          _offset = value;
        },
      );
      if (!mounted || token.isCancelled) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted || token.isCancelled) return;
      setState(() {
        _status = _UploadStatus.failed;
        _error = describeError(error, AppLocalizations.of(context));
      });
    }
  }

  void _pause() {
    setState(() => _status = _UploadStatus.paused);
    _cancelToken?.cancel();
  }

  void _resume() {
    unawaited(_start());
  }

  Future<void> _cancel() async {
    _cancelToken?.cancel();
    final uploadId = _uploadId;
    if (uploadId != null) {
      try {
        final repository = await ref.read(fileRepositoryProvider.future);
        await repository.stopChunkUpload(uploadId);
      } catch (_) {
        // The panel may have already cleaned the temporary chunks.
      }
    }
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusText = switch (_status) {
      _UploadStatus.uploading => l10n.files_uploading,
      _UploadStatus.paused => l10n.files_uploadPaused,
      _UploadStatus.failed => l10n.files_uploadFailed,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.files_upload, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s4),
        Text(
          widget.fileName,
          style: AppTextStyles.bodyS.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.s20),
        LinearProgressIndicator(
          value: _status == _UploadStatus.failed ? null : _progress,
        ),
        const SizedBox(height: AppTokens.s8),
        Text(
          '${(_progress * 100).toStringAsFixed(0)}% · $statusText',
          style: AppTextStyles.bodyS.copyWith(
            color: _status == _UploadStatus.failed
                ? context.scheme.error
                : context.scheme.onSurfaceVariant,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppTokens.s8),
          Text(
            _error!,
            style: AppTextStyles.bodyS.copyWith(color: context.scheme.error),
          ),
        ],
        const SizedBox(height: AppTokens.s24),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: l10n.action_cancel,
                onPressed: _cancel,
              ),
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: _status == _UploadStatus.uploading
                  ? PrimaryButton(
                      label: _chunked
                          ? l10n.files_uploadPause
                          : l10n.files_uploading,
                      onPressed: _chunked ? _pause : null,
                    )
                  : _status == _UploadStatus.paused
                  ? PrimaryButton(
                      label: l10n.files_uploadResume,
                      onPressed: _resume,
                    )
                  : PrimaryButton(label: l10n.action_retry, onPressed: _resume),
            ),
          ],
        ),
      ],
    );
  }
}
