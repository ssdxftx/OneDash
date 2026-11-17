import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/file/file_convert_dto.dart';
import '../../../../data/dto/file/file_favorite_dto.dart';
import '../../../../data/dto/file/file_share_dto.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../../domain/repositories/file_repository.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_bar_actions.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

final _favoritesProvider = FutureProvider.autoDispose<List<FileFavoriteDto>>((
  ref,
) async {
  final repository = await ref.watch(fileRepositoryProvider.future);
  return repository.searchFavorites();
}, name: 'fileFavoritesProvider');

final _recycleProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async {
    final repository = await ref.watch(fileRepositoryProvider.future);
    final result = await repository.searchRecycleBin(pageSize: 100);
    return (result['items'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const [];
  },
  name: 'fileRecycleProvider',
);

final _recycleStatusProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repository = await ref.watch(fileRepositoryProvider.future);
  return repository.getRecycleStatus();
}, name: 'fileRecycleStatusProvider');

final _sharesProvider = FutureProvider.autoDispose<List<FileShareDto>>((
  ref,
) async {
  final repository = await ref.watch(fileRepositoryProvider.future);
  final result = await repository.searchFileShares(pageSize: 100);
  return (result['items'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(FileShareDto.fromJson)
          .toList() ??
      const [];
}, name: 'fileSharesProvider');

final _wgetProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final repository = await ref.watch(fileRepositoryProvider.future);
  return repository.wgetProcessKeys();
}, name: 'fileWgetProvider');

final _uploadRecordsProvider = FutureProvider.autoDispose
    .family<PageResult<FileUploadDto>, String>((ref, path) async {
      final repository = await ref.watch(fileRepositoryProvider.future);
      return repository.searchUploadFiles(path: path, page: 1, pageSize: 100);
    }, name: 'fileUploadRecordsProvider');

final _convertLogsProvider =
    FutureProvider.autoDispose<PageResult<FileConvertLogDto>>((ref) async {
      final repository = await ref.watch(fileRepositoryProvider.future);
      return repository.convertLogs(page: 1, pageSize: 50);
    }, name: 'fileConvertLogsProvider');

class FileToolsPage extends ConsumerStatefulWidget {
  const FileToolsPage({
    super.key,
    required this.serverId,
    this.initialPath = '/',
  });

  final int serverId;
  final String initialPath;

  @override
  ConsumerState<FileToolsPage> createState() => _FileToolsPageState();
}

class _FileToolsPageState extends ConsumerState<FileToolsPage> {
  Future<void> _showMounts() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final mounts = await repository.getHostMounts();
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        maxHeightFactor: 0.85,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.files_mounts, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s12),
            if (mounts.isEmpty)
              Text(l10n.state_empty, style: AppTextStyles.bodyM)
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final mount in mounts)
                      ListTile(
                        leading: const Icon(TablerIcons.device_sd_card),
                        title: Text(
                          '${mount['mountPoint'] ?? mount['path'] ?? ''}',
                        ),
                        subtitle: Text(
                          '${mount['device'] ?? ''} ${mount['type'] ?? ''}'
                              .trim(),
                        ),
                      ),
                  ],
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

  Future<void> _openShare() async {
    final request = await pushFormPage<_ShareOpenRequest>(
      context,
      const _ShareOpenForm(),
    );
    if (request == null || !mounted) return;
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final info = await repository.getPublicShareInfo(request.code);
      if (!mounted) return;
      await showAppSheet<void>(
        context: context,
        builder: (sheetContext) => _SharePublicSheet(
          code: request.code,
          password: request.password,
          info: info,
          onDownload: () async {
            final tempDir = await getTemporaryDirectory();
            final name = '${info['fileName'] ?? 'share'}';
            final savePath =
                '${tempDir.path}/onedash_${DateTime.now().microsecondsSinceEpoch}_$name';
            await repository.checkFileShare(
              code: request.code,
              password: request.password,
            );
            await repository.downloadSharedFile(
              code: request.code,
              savePath: savePath,
              password: request.password,
            );
            await SharePlus.instance.share(
              ShareParams(files: [XFile(savePath, name: name)]),
            );
          },
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.files_tools,
        actions: [
          AppBarActions(
            actions: [
              AppBarAction(
                icon: TablerIcons.refresh,
                tooltip: l10n.action_refresh,
                onPressed: () {
                  ref.invalidate(_favoritesProvider);
                  ref.invalidate(_recycleProvider);
                  ref.invalidate(_sharesProvider);
                  ref.invalidate(_wgetProvider);
                  ref.invalidate(_convertLogsProvider);
                  ref.invalidate(_uploadRecordsProvider);
                },
              ),
              AppBarAction(
                icon: TablerIcons.link,
                tooltip: l10n.files_openShare,
                onPressed: _openShare,
              ),
              AppBarAction(
                icon: TablerIcons.server,
                tooltip: l10n.files_mounts,
                onPressed: _showMounts,
              ),
            ],
          ),
        ],
      ),
      body: SegmentedTabsView(
        labels: [
          l10n.files_favorites,
          l10n.files_recycleBin,
          l10n.files_shares,
          l10n.files_remoteDownload,
          l10n.files_uploadRecords,
          l10n.files_convertLogs,
        ],
        children: [
          _FavoritesTab(serverId: widget.serverId),
          const _RecycleTab(),
          const _SharesTab(),
          _RemoteDownloadTab(serverId: widget.serverId),
          _UploadRecordsTab(path: widget.initialPath),
          const _ConvertLogsTab(),
        ],
      ),
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab({required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final favorites = ref.watch(_favoritesProvider);
    return AsyncStateView(
      value: favorites,
      onRetry: () => ref.invalidate(_favoritesProvider),
      loading: const SkeletonList(itemCount: 6),
      isEmpty: (items) => items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.star_off,
        title: l10n.files_noFavorites,
        message: l10n.files_noFavoritesHint,
      ),
      builder: (items) => ListView.separated(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
        itemBuilder: (context, index) {
          final item = items[index];
          return TonalCard(
            onTap: () => context.push(
              '/s/$serverId/files?path=${Uri.encodeComponent(item.path)}',
            ),
            child: Row(
              children: [
                Icon(
                  item.isDir ? TablerIcons.folder : TablerIcons.file,
                  color: context.scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTextStyles.titleM),
                      const SizedBox(height: 2),
                      Text(
                        item.path,
                        style: AppTextStyles.monoSmall.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.files_removeFavorite,
                  icon: Icon(
                    TablerIcons.star_off,
                    color: context.appColors.warning,
                  ),
                  onPressed: () async {
                    try {
                      final repository = await ref.read(
                        fileRepositoryProvider.future,
                      );
                      await repository.deleteFavorite(item.id);
                      ref.invalidate(_favoritesProvider);
                    } catch (error) {
                      if (!context.mounted) return;
                      showErrorToast(context, error);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecycleTab extends ConsumerWidget {
  const _RecycleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(_recycleProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.s16,
            AppTokens.s16,
            AppTokens.s16,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.files_recycleBin, style: AppTextStyles.titleS),
                    const SizedBox(height: AppTokens.s4),
                    ref
                        .watch(_recycleStatusProvider)
                        .when(
                          data: (enabled) => Text(
                            enabled
                                ? l10n.files_recycleEnabled
                                : l10n.files_recycleDisabled,
                            style: AppTextStyles.caption.copyWith(
                              color: enabled
                                  ? context.appColors.success
                                  : context.scheme.onSurfaceVariant,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                  ],
                ),
              ),
              SecondaryButton(
                label: l10n.files_clearRecycleBin,
                expanded: false,
                onPressed: () async {
                  final confirmed = await showConfirmSheet(
                    context,
                    title: l10n.files_clearRecycleBin,
                    message: l10n.files_clearRecycleBinConfirm,
                    confirmLabel: l10n.files_clearRecycleBin,
                  );
                  if (!confirmed || !context.mounted) return;
                  try {
                    final repository = await ref.read(
                      fileRepositoryProvider.future,
                    );
                    await repository.clearRecycleBin();
                    ref.invalidate(_recycleProvider);
                    if (!context.mounted) return;
                    AppToast.success(context, l10n.action_done);
                  } catch (error) {
                    if (!context.mounted) return;
                    showErrorToast(context, error);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncStateView(
            value: items,
            onRetry: () => ref.invalidate(_recycleProvider),
            loading: const SkeletonList(itemCount: 6),
            isEmpty: (data) => data.isEmpty,
            empty: EmptyState(
              icon: TablerIcons.trash_off,
              title: l10n.files_recycleEmpty,
              message: l10n.files_recycleEmptyHint,
            ),
            builder: (data) => ListView.separated(
              padding: EdgeInsets.all(context.pagePadding),
              itemCount: data.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
              itemBuilder: (context, index) {
                final item = data[index];
                final name = '${item['name'] ?? item['rName'] ?? ''}';
                final source = '${item['sourcePath'] ?? ''}';
                return TonalCard(
                  child: Row(
                    children: [
                      Icon(
                        item['isDir'] == true
                            ? TablerIcons.folder
                            : TablerIcons.file,
                        color: context.scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTextStyles.titleM),
                            const SizedBox(height: 2),
                            Text(
                              '$source · ${formatBytes(item['size'])}',
                              style: AppTextStyles.caption.copyWith(
                                color: context.scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            final repository = await ref.read(
                              fileRepositoryProvider.future,
                            );
                            await repository.restoreRecycleItem(
                              from: '${item['from'] ?? ''}',
                              rName: '${item['rName'] ?? ''}',
                              name: name,
                            );
                            ref.invalidate(_recycleProvider);
                            if (!context.mounted) return;
                            AppToast.success(context, l10n.action_done);
                          } catch (error) {
                            if (!context.mounted) return;
                            showErrorToast(context, error);
                          }
                        },
                        child: Text(l10n.files_restore),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SharesTab extends ConsumerWidget {
  const _SharesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final shares = ref.watch(_sharesProvider);
    return AsyncStateView(
      value: shares,
      onRetry: () => ref.invalidate(_sharesProvider),
      loading: const SkeletonList(itemCount: 5),
      isEmpty: (items) => items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.share_off,
        title: l10n.files_noShares,
        message: l10n.files_noSharesHint,
      ),
      builder: (items) => ListView.separated(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
        itemBuilder: (context, index) {
          final share = items[index];
          return TonalCard(
            onTap: () => _showDetail(context, ref, share),
            child: Row(
              children: [
                Icon(TablerIcons.share, color: context.scheme.onSurfaceVariant),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        share.fileName.isEmpty ? share.path : share.fileName,
                        style: AppTextStyles.titleM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        share.permanent
                            ? l10n.files_permanentShare
                            : l10n.files_shareCode(share.code),
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.files_cancelShare,
                  icon: Icon(
                    TablerIcons.link_off,
                    color: context.appColors.danger,
                  ),
                  onPressed: () async {
                    final confirmed = await showConfirmSheet(
                      context,
                      title: l10n.files_cancelShare,
                      message: l10n.files_cancelShareConfirm(share.fileName),
                      confirmLabel: l10n.files_cancelShare,
                    );
                    if (!confirmed || !context.mounted) return;
                    try {
                      final repository = await ref.read(
                        fileRepositoryProvider.future,
                      );
                      await repository.deleteFileShare(share.path);
                      ref.invalidate(_sharesProvider);
                    } catch (error) {
                      if (!context.mounted) return;
                      showErrorToast(context, error);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDetail(
    BuildContext context,
    WidgetRef ref,
    FileShareDto share,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final detail = await repository.getFileShareDetail(share.path);
      if (detail != null) share = detail;
    } catch (_) {
      // Fall back to the list row when detail lookup fails.
    }
    if (!context.mounted) return;
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.files_shareDetail, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(title: l10n.files_name, subtitle: share.fileName),
              SplitListTile(title: l10n.files_path, subtitle: share.path),
              SplitListTile(
                title: l10n.files_shareCodeLabel,
                subtitle: share.code,
              ),
              if (share.hasPassword)
                SplitListTile(
                  title: l10n.files_sharePassword,
                  subtitle: share.password ?? '••••••',
                ),
              SplitListTile(
                title: l10n.files_shareExpire,
                subtitle: share.permanent
                    ? l10n.files_permanentShare
                    : formatListTime(
                        DateTime.fromMillisecondsSinceEpoch(
                          share.expiresAt * 1000,
                        ),
                        l10n,
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s16),
          SecondaryButton(
            label: l10n.files_copyShareCode,
            icon: TablerIcons.copy,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: share.code));
              if (!context.mounted) return;
              AppToast.success(context, l10n.action_done);
            },
          ),
        ],
      ),
    );
  }
}

class _RemoteDownloadTab extends ConsumerWidget {
  const _RemoteDownloadTab({required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final keys = ref.watch(_wgetProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.s16,
            AppTokens.s16,
            AppTokens.s16,
            0,
          ),
          child: PrimaryButton(
            label: l10n.files_remoteDownload,
            icon: TablerIcons.download,
            onPressed: () async {
              final request = await showAppSheet<_WgetRequest>(
                context: context,
                builder: (sheetContext) => const _WgetSheet(),
              );
              if (request == null || !context.mounted) return;
              try {
                final repository = await ref.read(
                  fileRepositoryProvider.future,
                );
                await repository.wget(
                  url: request.url,
                  path: request.path,
                  name: request.name,
                  ignoreCertificate: request.ignoreCertificate,
                );
                ref.invalidate(_wgetProvider);
                if (!context.mounted) return;
                AppToast.success(context, l10n.files_remoteDownloadStarted);
              } catch (error) {
                if (!context.mounted) return;
                showErrorToast(context, error);
              }
            },
          ),
        ),
        const SizedBox(height: AppTokens.s12),
        Expanded(
          child: AsyncStateView(
            value: keys,
            onRetry: () => ref.invalidate(_wgetProvider),
            loading: const SkeletonList(itemCount: 3),
            isEmpty: (data) => data.isEmpty,
            empty: EmptyState(
              icon: TablerIcons.download_off,
              title: l10n.files_noRemoteDownloads,
              message: l10n.files_noRemoteDownloadsHint,
            ),
            builder: (data) => ListView.separated(
              padding: EdgeInsets.all(context.pagePadding),
              itemCount: data.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
              itemBuilder: (context, index) {
                final key = data[index];
                return TonalCard(
                  onTap: () => _showWgetDetails(context, ref, key),
                  child: Row(
                    children: [
                      const Icon(TablerIcons.download),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        child: Text(
                          key,
                          style: AppTextStyles.mono.copyWith(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            final repository = await ref.read(
                              fileRepositoryProvider.future,
                            );
                            await repository.wgetStop(key);
                            ref.invalidate(_wgetProvider);
                          } catch (error) {
                            if (!context.mounted) return;
                            showErrorToast(context, error);
                          }
                        },
                        child: Text(l10n.action_stop),
                      ),
                      IconButton(
                        tooltip: l10n.files_removeDownloadRecord,
                        icon: const Icon(TablerIcons.trash),
                        onPressed: () async {
                          try {
                            final repository = await ref.read(
                              fileRepositoryProvider.future,
                            );
                            await repository.removeWgetRecords([key]);
                            ref.invalidate(_wgetProvider);
                          } catch (error) {
                            if (!context.mounted) return;
                            showErrorToast(context, error);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showWgetDetails(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repository = await ref.read(fileRepositoryProvider.future);
    if (!context.mounted) return;
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.72,
      builder: (_) => _WgetProcessSheet(
        repository: repository,
        keys: [key],
        title: l10n.files_wgetDetails,
      ),
    );
  }
}

class _WgetProcessSheet extends StatefulWidget {
  const _WgetProcessSheet({
    required this.repository,
    required this.keys,
    required this.title,
  });

  final FileRepository repository;
  final List<String> keys;
  final String title;

  @override
  State<_WgetProcessSheet> createState() => _WgetProcessSheetState();
}

class _WgetProcessSheetState extends State<_WgetProcessSheet> {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _timer;
  List<Map<String, dynamic>> _items = const [];
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      final channel = await widget.repository.connectWgetProcessWebSocket();
      if (!mounted) {
        await channel.sink.close();
        return;
      }
      _channel = channel;
      _subscription = channel.stream.listen(
        (message) {
          if (!mounted) return;
          try {
            final decoded = jsonDecode('$message');
            if (decoded is! List) return;
            setState(() {
              _items = decoded
                  .whereType<Map>()
                  .map((item) => item.cast<String, dynamic>())
                  .toList(growable: false);
              _loading = false;
              _error = null;
            });
          } catch (error) {
            setState(() => _error = error);
          }
        },
        onError: (Object error) {
          if (mounted) setState(() => _error = error);
        },
      );
      _send();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _send());
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loading = false;
        });
      }
    }
  }

  void _send() {
    final channel = _channel;
    if (channel == null) return;
    channel.sink.add(
      jsonEncode({
        'type': 'wget',
        'downloadProgress': {'keys': widget.keys},
      }),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s12),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Text(describeError(_error!, l10n))
        else if (_items.isEmpty)
          Text(l10n.files_wgetWaiting, style: AppTextStyles.bodyM)
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
              itemBuilder: (context, index) {
                final item = _items[index];
                final percent = (item['percent'] as num?)?.toDouble() ?? 0;
                final written = item['written'];
                final total = item['total'];
                final error = '${item['error'] ?? ''}'.trim();
                return TonalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['name'] ?? item['key'] ?? ''}',
                        style: AppTextStyles.titleS,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTokens.s4),
                      Text(
                        l10n.files_wgetProgress(
                          percent.clamp(0, 100).toStringAsFixed(1),
                        ),
                        style: AppTextStyles.bodyS,
                      ),
                      Text(
                        '${formatBytes(written)} / ${formatBytes(total)}',
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                      if (error.isNotEmpty)
                        Text(
                          error,
                          style: AppTextStyles.caption.copyWith(
                            color: context.appColors.danger,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _UploadRecordsTab extends ConsumerWidget {
  const _UploadRecordsTab({required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final records = ref.watch(_uploadRecordsProvider(path));
    return AsyncStateView(
      value: records,
      onRetry: () => ref.invalidate(_uploadRecordsProvider(path)),
      loading: const SkeletonList(itemCount: 5),
      isEmpty: (result) => result.items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.upload,
        title: l10n.files_noUploadRecords,
        message: l10n.files_noUploadRecordsHint,
      ),
      builder: (result) => ListView.separated(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: result.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
        itemBuilder: (context, index) {
          final item = result.items[index];
          return TonalCard(
            child: Row(
              children: [
                const Icon(TablerIcons.file_upload),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTextStyles.titleM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatBytes(item.size)}  ${item.createdAt}',
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConvertLogsTab extends ConsumerWidget {
  const _ConvertLogsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logs = ref.watch(_convertLogsProvider);
    return AsyncStateView(
      value: logs,
      onRetry: () => ref.invalidate(_convertLogsProvider),
      loading: const SkeletonList(itemCount: 5),
      isEmpty: (result) => result.items.isEmpty,
      empty: EmptyState(
        icon: TablerIcons.transform,
        title: l10n.files_noConvertLogs,
        message: l10n.files_noConvertLogsHint,
      ),
      builder: (result) => ListView.separated(
        padding: EdgeInsets.all(context.pagePadding),
        itemCount: result.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
        itemBuilder: (context, index) {
          final item = result.items[index];
          final success = item.status.toUpperCase() == 'SUCCESS';
          return TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.type, style: AppTextStyles.titleM),
                    ),
                    StatusPill(
                      label: item.status,
                      tone: success
                          ? context.appColors.success
                          : context.appColors.danger,
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s4),
                Text(
                  item.log,
                  style: AppTextStyles.monoSmall.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTokens.s4),
                Text(
                  '${item.date}  ${item.message}',
                  style: AppTextStyles.caption.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WgetRequest {
  const _WgetRequest({
    required this.url,
    required this.path,
    required this.name,
    required this.ignoreCertificate,
  });

  final String url;
  final String path;
  final String name;
  final bool ignoreCertificate;
}

class _WgetSheet extends StatefulWidget {
  const _WgetSheet();

  @override
  State<_WgetSheet> createState() => _WgetSheetState();
}

class _WgetSheetState extends State<_WgetSheet> {
  final _url = TextEditingController();
  final _path = TextEditingController(text: '/opt');
  final _name = TextEditingController();
  bool _ignoreCertificate = false;

  @override
  void dispose() {
    _url.dispose();
    _path.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.files_remoteDownload, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          controller: _url,
          label: l10n.files_url,
          hint: 'https://example.com/file.zip',
          autofocus: true,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _path,
          label: l10n.files_targetDirectory,
          hint: '/opt',
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _name,
          label: l10n.files_name,
          hint: 'file.zip',
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.files_ignoreCertificate),
          value: _ignoreCertificate,
          onChanged: (value) => setState(() => _ignoreCertificate = value),
        ),
        const SizedBox(height: AppTokens.s16),
        PrimaryButton(
          label: l10n.files_startDownload,
          onPressed: () {
            final url = _url.text.trim();
            final path = _path.text.trim();
            if (url.isEmpty || path.isEmpty) return;
            Navigator.of(context).pop(
              _WgetRequest(
                url: url,
                path: path,
                name: _name.text.trim(),
                ignoreCertificate: _ignoreCertificate,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ShareOpenRequest {
  const _ShareOpenRequest({required this.code, this.password});

  final String code;
  final String? password;
}

class _ShareOpenForm extends StatefulWidget {
  const _ShareOpenForm();

  @override
  State<_ShareOpenForm> createState() => _ShareOpenFormState();
}

class _ShareOpenFormState extends State<_ShareOpenForm> {
  final _code = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleFormPage(
      title: l10n.files_openShare,
      onSave: () async {
        final code = _code.text.trim();
        if (code.isEmpty) return;
        Navigator.of(context).pop(
          _ShareOpenRequest(
            code: code,
            password: _password.text.isEmpty ? null : _password.text,
          ),
        );
      },
      children: [
        AppTextField(controller: _code, label: l10n.files_shareCodeLabel),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _password,
          label: l10n.files_sharePassword,
          obscure: true,
        ),
      ],
    );
  }
}

class _SharePublicSheet extends StatelessWidget {
  const _SharePublicSheet({
    required this.code,
    required this.password,
    required this.info,
    required this.onDownload,
  });

  final String code;
  final String? password;
  final Map<String, dynamic> info;
  final Future<void> Function() onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.files_shareDetail, style: AppTextStyles.titleL),
        const SizedBox(height: AppTokens.s12),
        SplitListGroup(
          children: [
            SplitListTile(
              title: l10n.files_name,
              subtitle: '${info['fileName'] ?? ''}',
            ),
            SplitListTile(title: l10n.files_shareCodeLabel, subtitle: code),
            SplitListTile(
              title: l10n.files_shareExpire,
              subtitle: info['permanent'] == true
                  ? l10n.files_permanentShare
                  : formatLocalDateTime(
                      DateTime.fromMillisecondsSinceEpoch(
                        ((info['expiresAt'] as num?)?.toInt() ?? 0) * 1000,
                      ).toIso8601String(),
                    ),
            ),
            if (info['hasPassword'] == true)
              SplitListTile(
                title: l10n.files_sharePassword,
                subtitle: password == null ? '******' : '******',
              ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: l10n.files_download,
            icon: TablerIcons.download,
            onPressed: () async {
              try {
                await onDownload();
                if (!context.mounted) return;
                AppToast.success(context, l10n.files_downloadReady);
              } catch (error) {
                if (!context.mounted) return;
                showErrorToast(context, error);
              }
            },
          ),
        ),
      ],
    );
  }
}
