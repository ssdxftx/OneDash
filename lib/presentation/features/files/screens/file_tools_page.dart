import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/file/file_favorite_dto.dart';
import '../../../../data/dto/file/file_share_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
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

class FileToolsPage extends ConsumerStatefulWidget {
  const FileToolsPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<FileToolsPage> createState() => _FileToolsPageState();
}

class _FileToolsPageState extends ConsumerState<FileToolsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.files_tools,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () {
              ref.invalidate(_favoritesProvider);
              ref.invalidate(_recycleProvider);
              ref.invalidate(_sharesProvider);
              ref.invalidate(_wgetProvider);
            },
          ),
        ],
      ),
      body: SegmentedTabsView(
        labels: [
          l10n.files_favorites,
          l10n.files_recycleBin,
          l10n.files_shares,
          l10n.files_remoteDownload,
        ],
        children: [
          _FavoritesTab(serverId: widget.serverId),
          const _RecycleTab(),
          const _SharesTab(),
          _RemoteDownloadTab(serverId: widget.serverId),
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
        padding: const EdgeInsets.all(AppTokens.pagePadding),
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
                        style: AppTextStyles.caption.copyWith(
                          color: context.scheme.onSurfaceVariant,
                          fontFamily: 'monospace',
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
                child: Text(l10n.files_recycleBin, style: AppTextStyles.titleS),
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
              padding: const EdgeInsets.all(AppTokens.pagePadding),
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
        padding: const EdgeInsets.all(AppTokens.pagePadding),
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
              padding: const EdgeInsets.all(AppTokens.pagePadding),
              itemCount: data.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s8),
              itemBuilder: (context, index) {
                final key = data[index];
                return TonalCard(
                  child: Row(
                    children: [
                      const Icon(TablerIcons.download),
                      const SizedBox(width: AppTokens.s12),
                      Expanded(
                        child: Text(
                          key,
                          style: AppTextStyles.bodyM.copyWith(
                            fontFamily: 'monospace',
                          ),
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
