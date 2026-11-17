import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/container_file_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class ContainerFilesPage extends ConsumerStatefulWidget {
  const ContainerFilesPage({
    super.key,
    required this.containerName,
    this.initialPath = '/',
  });

  final String containerName;
  final String initialPath;

  @override
  ConsumerState<ContainerFilesPage> createState() => _ContainerFilesPageState();
}

class _ContainerFilesPageState extends ConsumerState<ContainerFilesPage> {
  late String _path = widget.initialPath;
  AsyncValue<List<ContainerFileDto>>? _files;
  int _requestId = 0;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final requestId = ++_requestId;
    final requestedPath = _path;
    setState(() => _files = const AsyncValue.loading());
    ref
        .read(containerRepositoryProvider.future)
        .then(
          (repository) => repository.listContainerFiles(
            containerId: widget.containerName,
            path: requestedPath,
          ),
        )
        .then(
          (items) {
            if (mounted && requestId == _requestId) {
              setState(() => _files = AsyncValue.data(items));
            }
          },
          onError: (Object error, StackTrace stack) {
            if (mounted && requestId == _requestId) {
              setState(() => _files = AsyncValue.error(error, stack));
            }
          },
        );
  }

  String get _parent {
    final normalized = _path.endsWith('/') && _path.length > 1
        ? _path.substring(0, _path.length - 1)
        : _path;
    final index = normalized.lastIndexOf('/');
    if (index <= 0) return '/';
    return normalized.substring(0, index);
  }

  void _openDir(ContainerFileDto file) {
    setState(() => _path = file.path);
    _reload();
  }

  void _goParent() {
    if (_path == '/') return;
    setState(() => _path = _parent);
    _reload();
  }

  Future<void> _upload() async {
    if (_uploading) return;
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.pickFiles(allowMultiple: false);
    final filePath = result?.files.single.path;
    if (filePath == null || !mounted) return;
    final targetPath = _path;
    setState(() => _uploading = true);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.uploadContainerFile(
        containerId: widget.containerName,
        path: targetPath,
        filePath: filePath,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      _reload();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _download(ContainerFileDto file) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final bytes = await repository.downloadContainerFile(
        containerId: widget.containerName,
        path: file.path,
      );
      final tempDir = await getTemporaryDirectory();
      final safeName = file.name.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_');
      final path = '${tempDir.path}/onedash_$safeName';
      await File(path).writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path, name: file.name)]),
      );
      if (!mounted) return;
      AppToast.success(context, l10n.files_downloadReady);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _preview(ContainerFileDto file) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      final results = await Future.wait<Object>([
        repository.getContainerFileContent(
          containerId: widget.containerName,
          path: file.path,
        ),
        repository.getContainerFileSize(
          containerId: widget.containerName,
          path: file.path,
        ),
      ]);
      final content = results[0] as ContainerFileContentDto;
      final exactSize = results[1] as int;
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.9,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(file.name, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s4),
            Text(formatBytes(exactSize), style: AppTextStyles.bodyS),
            const SizedBox(height: AppTokens.s12),
            if (content.isBinary)
              Text(l10n.containers_binaryFile, style: AppTextStyles.bodyM)
            else
              Flexible(
                child: SingleChildScrollView(
                  child: SelectableText(
                    content.truncated
                        ? '${content.content}\n...'
                        : content.content,
                    style: AppTextStyles.mono.copyWith(),
                  ),
                ),
              ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _delete(ContainerFileDto file) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.action_delete,
      message: file.name,
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(containerRepositoryProvider.future);
      await repository.deleteContainerFiles(
        containerId: widget.containerName,
        paths: [file.path],
      );
      if (!mounted) return;
      AppToast.success(context, l10n.containers_fileDeleted);
      _reload();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: _path == '/',
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goParent();
      },
      child: Scaffold(
        appBar: AppBarLarge(
          title: l10n.containers_fileBrowser,
          subtitle: _path,
          actions: [
            AppIconButton(
              icon: TablerIcons.refresh,
              tooltip: l10n.action_refresh,
              onPressed: _reload,
            ),
            AppIconButton(
              icon: TablerIcons.upload,
              tooltip: l10n.containers_uploadFile,
              onPressed: _upload,
            ),
          ],
        ),
        body: AsyncStateView(
          value: _files ?? const AsyncValue<List<ContainerFileDto>>.loading(),
          onRetry: _reload,
          loading: const SkeletonList(itemCount: 6),
          isEmpty: (items) => items.isEmpty,
          empty: EmptyState(
            icon: TablerIcons.folder,
            title: l10n.containers_fileEmpty,
          ),
          builder: (items) => ListView(
            padding: EdgeInsets.all(context.pagePadding),
            children: [
              if (_path != '/')
                TonalCard(
                  onTap: _goParent,
                  child: Row(
                    children: [
                      Icon(
                        TablerIcons.arrow_up,
                        color: context.scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppTokens.s12),
                      Text(
                        l10n.containers_parentDir,
                        style: AppTextStyles.titleM,
                      ),
                    ],
                  ),
                ),
              if (_path != '/') const SizedBox(height: AppTokens.s12),
              SplitListGroup(
                children: [
                  for (final file in items)
                    SplitListTile(
                      leading: Icon(
                        file.isDir ? TablerIcons.folder : TablerIcons.file_text,
                      ),
                      title: file.name,
                      value: file.isDir ? null : formatBytes(file.size),
                      onTap: file.isDir
                          ? () => _openDir(file)
                          : () => _preview(file),
                      onLongPress: () => _delete(file),
                      trailing: file.isDir
                          ? null
                          : IconButton(
                              tooltip: l10n.files_download,
                              icon: const Icon(TablerIcons.download),
                              onPressed: () => _download(file),
                            ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
