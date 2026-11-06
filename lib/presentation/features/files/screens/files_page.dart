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
import '../../../shell/nav_visibility.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/file_type_utils.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/refreshable_empty_state.dart';
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
  final _searchDebouncer = Debouncer();
  bool _searching = false;
  bool _selecting = false;
  bool _uploading = false;
  final Set<String> _selected = {};
  final Map<String, int> _dirSizes = {};
  final Set<String> _calculating = {};

  bool get _selectionMode => _selecting;

  String get _path => widget.initialPath.isEmpty ? '/' : widget.initialPath;

  @override
  void deactivate() {
    ref.read(bottomNavSuppressedProvider.notifier).state = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
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

  Future<void> _checkSelection() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final items = await repository.batchCheckFilesExists(_selected.toList());
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.files_checkExistence, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            if (items.isEmpty)
              EmptyState(
                compact: true,
                icon: TablerIcons.file_off,
                title: l10n.state_empty,
              )
            else
              SplitListGroup(
                children: [
                  for (final item in items)
                    SplitListTile(
                      leading: Icon(
                        item.isDir ? TablerIcons.folder : TablerIcons.file,
                      ),
                      title: item.name,
                      subtitle: item.path,
                    ),
                ],
              ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _create({required bool isDir}) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: isDir ? l10n.files_new_folder : l10n.files_new_file,
          saveLabel: l10n.action_create,
          onSave: () async =>
              Navigator.of(pageContext).pop(controller.text.trim()),
          children: [
            AppTextField(
              controller: controller,
              hint: l10n.files_nameHint,
              autofocus: true,
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final target = _join(_path, name);
      if (await repository.checkFileExists(target)) {
        if (!mounted) return;
        AppToast.warning(context, l10n.files_alreadyExists(name));
        return;
      }
      await repository.createFileOrDir(path: target, isDir: isDir);
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
    final name = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.files_compress,
          saveLabel: l10n.action_create,
          onSave: () async =>
              Navigator.of(pageContext).pop(controller.text.trim()),
          children: [
            AppTextField(controller: controller, label: l10n.files_archiveName),
          ],
        ),
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
    final name = await pushFormPage<String>(
      context,
      Builder(
        builder: (pageContext) => SimpleFormPage(
          title: l10n.files_rename,
          onSave: () async =>
              Navigator.of(pageContext).pop(controller.text.trim()),
          children: [AppTextField(controller: controller, autofocus: true)],
        ),
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
        builder: (dialogContext) {
          final decodeWidth =
              (MediaQuery.sizeOf(dialogContext).width *
                      MediaQuery.devicePixelRatioOf(dialogContext) *
                      2)
                  .round()
                  .clamp(480, 4096);
          return Dialog.fullscreen(
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 6,
                    child: Center(
                      child: Image.memory(bytes, cacheWidth: decodeWidth),
                    ),
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
          );
        },
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
      _selecting = true;
      if (!_selected.remove(item.path)) _selected.add(item.path);
    });
    ref.read(bottomNavSuppressedProvider.notifier).state = true;
  }

  void _clearSelection() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
    ref.read(bottomNavSuppressedProvider.notifier).state = false;
  }

  void _selectAll(List<FileItemDto> items) {
    setState(() {
      _selecting = true;
      _selected
        ..clear()
        ..addAll(items.map((item) => item.path));
    });
    ref.read(bottomNavSuppressedProvider.notifier).state = true;
  }

  Future<void> _permission(FileItemDto item) async {
    final updated = await showFilePermissionSheet(context, item: item);
    if (updated && mounted) {
      ref.invalidate(filesProvider(_path));
    }
  }

  Future<void> _favorite(FileItemDto item) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.favoriteFile(item.path);
      if (!mounted) return;
      AppToast.success(context, l10n.files_favoriteAdded);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _moveCopy(FileItemDto item) async {
    final l10n = AppLocalizations.of(context);
    final request = await pushFormPage<_MoveRequest>(
      context,
      _MoveSheet(sourcePath: item.path, sourceDir: _path),
    );
    if (request == null || !mounted) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.moveCopyFiles(
        oldPaths: [item.path],
        newPath: request.target,
        type: request.copy ? 'copy' : 'cut',
        cover: request.cover,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      ref.invalidate(filesProvider(_path));
      if (request.target != _path) {
        ref.invalidate(filesProvider(request.target));
      }
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _batchPermission() async {
    final l10n = AppLocalizations.of(context);
    final paths = _selected.toList(growable: false);
    if (paths.isEmpty) return;
    final request = await pushFormPage<_BatchRoleRequest>(
      context,
      const _BatchRoleSheet(),
    );
    if (request == null || !mounted) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      await repository.updatePermissions(
        paths: paths,
        mode: request.mode,
        user: request.user,
        group: request.group,
        sub: request.sub,
      );
      if (!mounted) return;
      setState(_selected.clear);
      AppToast.success(context, l10n.action_done);
      ref.invalidate(filesProvider(_path));
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
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
                ? (item.itemTotal > 0
                      ? l10n.files_itemCount(item.itemTotal)
                      : l10n.files_folder)
                : '${formatBytes(item.size)} · ${formatListTime(DateTime.tryParse(item.modTime), l10n, fallback: item.modTime)}',
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
              if (!item.isDir)
                SplitListTile(
                  leading: const Icon(TablerIcons.ruler_measure),
                  title: l10n.files_exactSize,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    try {
                      final repository = await ref.read(
                        fileRepositoryProvider.future,
                      );
                      final size = await repository.getFileSize(item.path);
                      if (!mounted) return;
                      AppToast.success(context, formatBytes(size));
                    } catch (error) {
                      if (!mounted) return;
                      showErrorToast(context, error);
                    }
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
                leading: const Icon(TablerIcons.arrows_move),
                title: l10n.files_moveCopy,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _moveCopy(item);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.star),
                title: l10n.files_addFavorite,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _favorite(item);
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
                PopupMenuButton<String>(
                  tooltip: l10n.action_more,
                  icon: const Icon(TablerIcons.dots),
                  onSelected: (value) {
                    if (value == 'all') {
                      _selectAll(
                        ref.read(filesProvider(_path)).valueOrNull?.items ??
                            const [],
                      );
                    } else if (value == 'check') {
                      _checkSelection();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'all',
                      child: Text(l10n.files_selectAll),
                    ),
                    PopupMenuItem(
                      value: 'check',
                      child: Text(l10n.files_checkExistence),
                    ),
                  ],
                ),
              ]
            : [
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
                AppIconButton(
                  icon: TablerIcons.upload,
                  tooltip: l10n.files_upload,
                  onPressed: _uploading ? null : _upload,
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
                PopupMenuButton<String>(
                  tooltip: l10n.action_more,
                  icon: const Icon(TablerIcons.dots),
                  onSelected: (value) async {
                    if (value == 'root') {
                      try {
                        final repository = await ref.read(
                          fileRepositoryProvider.future,
                        );
                        final root = await repository.getWebsiteRootDir();
                        if (!context.mounted || root.isEmpty) return;
                        _openPath(root);
                      } catch (error) {
                        if (!context.mounted) return;
                        showErrorToast(context, error);
                      }
                    } else if (value == 'tools') {
                      await context.push('/s/${widget.serverId}/files/tools');
                    } else if (value == 'ai') {
                      await context.push(
                        '/s/${widget.serverId}/files/ai-search'
                        '?path=${Uri.encodeComponent(_path)}',
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'root',
                      child: Text(l10n.files_websiteRoot),
                    ),
                    PopupMenuItem(
                      value: 'tools',
                      child: Text(l10n.files_tools),
                    ),
                    PopupMenuItem(
                      value: 'ai',
                      child: Text(l10n.files_aiSearch),
                    ),
                  ],
                ),
              ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_searching ? 64 : 48),
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
                    onChanged: (value) {
                      _clearSelection();
                      _searchDebouncer(() {
                        ref.read(filesProvider(_path).notifier).search(value);
                      }, delay: const Duration(milliseconds: 300));
                    },
                  ),
                ),
              _Breadcrumb(path: _path, onTap: _openPath),
            ],
          ),
        ),
      ),
      body: AsyncStateView(
        value: files,
        onRetry: () => ref.read(filesProvider(_path).notifier).refresh(),
        loading: const SkeletonList(itemCount: 10, itemHeight: 56),
        isEmpty: (state) => state.items.isEmpty,
        empty: RefreshableEmptyState(
          onRefresh: () => ref.read(filesProvider(_path).notifier).refresh(),
          child: EmptyState(
            icon: TablerIcons.folder_open,
            title: l10n.files_empty_title,
            message: l10n.files_empty_message,
            actionLabel: l10n.files_upload,
            onAction: _upload,
          ),
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
              padding: EdgeInsets.only(
                bottom:
                    AppTokens.bottomNavClearance +
                    MediaQuery.paddingOf(context).bottom,
              ),
              itemExtent:
                  72 *
                  MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.8),
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
                      : () => _showActions(item),
                  onLongPress: () => _toggleSelection(item),
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
                            style: AppTextStyles.bodyM,
                          ),
                        ),
                        DangerButton(
                          expanded: false,
                          icon: TablerIcons.trash,
                          label: l10n.action_delete,
                          onPressed: () => _batchDelete(
                            ref.read(filesProvider(_path)).valueOrNull?.items ??
                                const [],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.s8),
                    SizedBox(
                      width: double.infinity,
                      child: SecondaryButton(
                        label: l10n.files_batchPermission,
                        icon: TablerIcons.shield_lock,
                        onPressed: _batchPermission,
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
                  AppIconButton(
                    icon: TablerIcons.folder_plus,
                    tooltip: l10n.files_new_folder,
                    onPressed: () => _create(isDir: true),
                  ),
                  AppIconButton(
                    icon: TablerIcons.file_plus,
                    tooltip: l10n.files_new_file,
                    onPressed: () => _create(isDir: false),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      l10n.files_itemCount(files.valueOrNull?.total ?? 0),
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
    );
  }
}

class _MoveRequest {
  const _MoveRequest({
    required this.target,
    required this.copy,
    required this.cover,
  });

  final String target;
  final bool copy;
  final bool cover;
}

class _MoveSheet extends StatefulWidget {
  const _MoveSheet({required this.sourcePath, required this.sourceDir});

  final String sourcePath;
  final String sourceDir;

  @override
  State<_MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends State<_MoveSheet> {
  late final TextEditingController _target = TextEditingController(
    text: widget.sourceDir,
  );
  bool _copy = false;
  bool _cover = false;

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleFormPage(
      title: l10n.files_moveCopy,
      subtitle: widget.sourcePath,
      saveLabel: _copy ? l10n.files_copy : l10n.files_move,
      onSave: () async {
        final target = _target.text.trim();
        if (target.isEmpty) return;
        Navigator.of(
          context,
        ).pop(_MoveRequest(target: target, copy: _copy, cover: _cover));
      },
      children: [
        AppTextField(
          controller: _target,
          label: l10n.files_targetDirectory,
          hint: '/opt',
          autofocus: true,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.files_copyMode),
          value: _copy,
          onChanged: (value) => setState(() => _copy = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.files_overwrite),
          value: _cover,
          onChanged: (value) => setState(() => _cover = value),
        ),
      ],
    );
  }
}

class _BatchRoleRequest {
  const _BatchRoleRequest({
    required this.mode,
    required this.user,
    required this.group,
    required this.sub,
  });

  final int mode;
  final String user;
  final String group;
  final bool sub;
}

class _BatchRoleSheet extends StatefulWidget {
  const _BatchRoleSheet();

  @override
  State<_BatchRoleSheet> createState() => _BatchRoleSheetState();
}

class _BatchRoleSheetState extends State<_BatchRoleSheet> {
  final _mode = TextEditingController(text: '0644');
  final _user = TextEditingController();
  final _group = TextEditingController();
  bool _sub = true;

  @override
  void dispose() {
    _mode.dispose();
    _user.dispose();
    _group.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleFormPage(
      title: l10n.files_batchPermission,
      onSave: () async {
        final text = _mode.text.trim();
        if (!RegExp(r'^[0-7]{3,4}$').hasMatch(text)) return;
        final mode = int.parse(text.padLeft(4, '0'), radix: 8);
        Navigator.of(context).pop(
          _BatchRoleRequest(
            mode: mode,
            user: _user.text.trim(),
            group: _group.text.trim(),
            sub: _sub,
          ),
        );
      },
      children: [
        AppTextField(
          controller: _mode,
          label: l10n.files_permissionMode,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _user, label: l10n.files_permissionUser),
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: _group, label: l10n.files_permissionGroupName),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.files_recursive),
          value: _sub,
          onChanged: (value) => setState(() => _sub = value),
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
      height: AppTokens.minTapTarget,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
        children: [
          InkWell(
            onTap: () => onTap('/'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8),
              child: Center(
                child: Text(
                  l10n.files_homeDirectory,
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
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8),
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
    this.selected = false,
    this.dirSize,
    this.calculating = false,
    this.onCalculateSize,
  });

  final FileItemDto item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
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
                        ? (item.itemTotal > 0
                              ? l10n.files_itemCount(item.itemTotal)
                              : l10n.files_folder)
                        : '${formatBytes(item.size)} · ${formatListTime(DateTime.tryParse(item.modTime), l10n, fallback: item.modTime)}',
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              TablerIcons.chevron_right,
              size: AppTokens.iconList,
              color: scheme.onSurfaceVariant,
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
