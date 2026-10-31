import 'dart:async';

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
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;
    setState(() => _uploading = true);
    final progress = ValueNotifier<double>(0);
    if (mounted) {
      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: ValueListenableBuilder<double>(
              valueListenable: progress,
              builder: (context, value, _) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.files_upload, style: AppTextStyles.titleM),
                  const SizedBox(height: AppTokens.s16),
                  LinearProgressIndicator(value: value),
                  const SizedBox(height: AppTokens.s8),
                  Text('${(value * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ),
        ),
      );
    }
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      for (final file in result.files) {
        final localPath = file.path;
        if (localPath == null) continue;
        await repository.uploadFile(
          filePath: localPath,
          targetPath: _path,
          onProgress: (value) => progress.value = value,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.success(context, l10n.action_done);
      ref.invalidate(filesProvider(_path));
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showErrorToast(context, error);
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
        title: Text(folderName, style: AppTextStyles.titleM),
        leading: _path == '/'
            ? null
            : IconButton(
                tooltip: l10n.files_parent,
                icon: const Icon(TablerIcons.arrow_up),
                onPressed: () => _openPath(_parentOf(_path)),
              ),
        actions: [
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
              PopupMenuItem(value: 'name', child: Text(l10n.files_sortName)),
              PopupMenuItem(value: 'size', child: Text(l10n.files_sortSize)),
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
      floatingActionButton: FloatingActionButton(
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
                  onTap: item.isDir
                      ? () => _openPath(item.path)
                      : FileTypeUtils.isEditable(item)
                      ? () => context.push(
                          '/s/${widget.serverId}/files/edit?path=${Uri.encodeComponent(item.path)}',
                        )
                      : () => _showActions(item),
                  onLongPress: () => _showActions(item),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: null,
      persistentFooterButtons: [
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
              stateText(files),
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String stateText(AsyncValue<FilesState> value) {
    final data = value.valueOrNull;
    if (data == null) return '';
    return '${data.items.length} / ${data.total}';
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
  });

  final FileItemDto item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
        child: Row(
          children: [
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
