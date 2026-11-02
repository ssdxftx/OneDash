import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/dto/app/app_catalog_dto.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/refreshable_empty_state.dart';
import '../../servers/providers/servers_provider.dart';
import '../../../common/states/error_toast.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../providers/app_store_provider.dart';

class AppStorePage extends ConsumerStatefulWidget {
  const AppStorePage({super.key, required this.serverId, this.initialTab = 0});

  final int serverId;
  final int initialTab;

  @override
  ConsumerState<AppStorePage> createState() => _AppStorePageState();
}

class _AppStorePageState extends ConsumerState<AppStorePage> {
  final _searchController = TextEditingController();
  final _searchDebouncer = Debouncer();
  String _query = '';

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _storeSettings(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final config = await repository.getStoreConfig();
      if (!context.mounted) return;
      final values = <String, bool>{
        'uninstallDeleteImage': config.uninstallDeleteImage,
        'upgradeBackup': config.upgradeBackup,
        'uninstallDeleteBackup': config.uninstallDeleteBackup,
        'installAllowPort': config.installAllowPort,
      };
      final saved = await showAppSheet<bool>(
        context: context,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.apps_storeSettings, style: AppTextStyles.titleL),
              const SizedBox(height: AppTokens.s16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.apps_uninstallDeleteImage),
                value: values['uninstallDeleteImage']!,
                onChanged: (v) =>
                    setState(() => values['uninstallDeleteImage'] = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.apps_upgradeBackup),
                value: values['upgradeBackup']!,
                onChanged: (v) => setState(() => values['upgradeBackup'] = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.apps_uninstallDeleteBackup),
                value: values['uninstallDeleteBackup']!,
                onChanged: (v) =>
                    setState(() => values['uninstallDeleteBackup'] = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.apps_installAllowPort),
                value: values['installAllowPort']!,
                onChanged: (v) =>
                    setState(() => values['installAllowPort'] = v),
              ),
              const SizedBox(height: AppTokens.s16),
              PrimaryButton(
                label: l10n.action_save,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
            ],
          ),
        ),
      );
      if (saved != true || !context.mounted) return;
      for (final entry in values.entries) {
        await repository.updateStoreConfig(
          scope: entry.key,
          enable: entry.value,
        );
      }
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _sync(
    BuildContext context,
    WidgetRef ref, {
    required bool remote,
  }) async {
    final l10n = AppLocalizations.of(context);
    final repository = await ref.read(appRepositoryProvider.future);
    if (!context.mounted) return;
    final taskID = const Uuid().v4();
    final success = await TaskProgressSheet.run(
      context,
      title: remote ? l10n.apps_syncRemote : l10n.apps_syncLocal,
      task: (controller) async {
        if (remote) {
          await repository.syncRemoteApps(taskID);
        } else {
          await repository.syncLocalApps(taskID);
        }
        for (var attempt = 0; attempt < 120; attempt++) {
          final log = await repository.readTaskLog(taskID);
          if (log.lines.isNotEmpty) controller.log(log.lines.last);
          final status = log.taskStatus.toLowerCase();
          if (status == 'success') return;
          if (status == 'failed' || status == 'error' || status == 'canceled') {
            throw Exception(log.lines.isEmpty ? 'Task failed' : log.lines.last);
          }
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      },
    );
    if (!success || !context.mounted) return;
    ref.invalidate(appCatalogProvider(_query));
    ref.invalidate(installedAppsProvider);
    AppToast.success(context, l10n.action_done);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final server = ref.watch(serverByIdProvider(widget.serverId)).valueOrNull;
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.apps_title,
        subtitle: server?.displayName,
        onTitleLongPress: () =>
            showServerSwitcher(context, ref, currentServerId: widget.serverId),
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () {
              ref.invalidate(appCatalogProvider(_query));
              ref.invalidate(installedAppsProvider);
            },
          ),
          PopupMenuButton<String>(
            tooltip: l10n.action_more,
            onSelected: (value) {
              if (value == 'remote') _sync(context, ref, remote: true);
              if (value == 'local') _sync(context, ref, remote: false);
              if (value == 'settings') _storeSettings(context, ref);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'remote', child: Text(l10n.apps_syncRemote)),
              PopupMenuItem(value: 'local', child: Text(l10n.apps_syncLocal)),
              PopupMenuItem(
                value: 'settings',
                child: Text(l10n.apps_storeSettings),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s16,
              vertical: AppTokens.s8,
            ),
            child: SearchField(
              controller: _searchController,
              hint: l10n.apps_search_hint,
              onChanged: (value) {
                _searchDebouncer(() {
                  setState(() => _query = value.trim());
                }, delay: const Duration(milliseconds: 300));
              },
            ),
          ),
          Expanded(
            child: SegmentedTabsView(
              initialIndex: widget.initialTab,
              labels: [l10n.apps_title, l10n.apps_installed],
              children: [
                _CatalogTab(serverId: widget.serverId, query: _query),
                _InstalledTab(serverId: widget.serverId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogTab extends ConsumerWidget {
  const _CatalogTab({required this.serverId, required this.query});

  final int serverId;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(appCatalogProvider(query));
    return AsyncStateView(
      value: catalog,
      onRetry: () => ref.invalidate(appCatalogProvider(query)),
      loading: const SkeletonList(itemCount: 8),
      isEmpty: (data) => data.items.isEmpty,
      empty: RefreshableEmptyState(
        onRefresh: () => ref.refresh(appCatalogProvider(query).future),
        child: EmptyState(
          icon: TablerIcons.apps,
          title: l10n.apps_emptyTitle,
          message: l10n.apps_emptyMessage,
        ),
      ),
      builder: (data) {
        final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
        return RefreshIndicator(
          onRefresh: () => ref.refresh(appCatalogProvider(query).future),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTokens.s16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppTokens.s12,
              crossAxisSpacing: AppTokens.s12,
              mainAxisExtent: 150 + (scale - 1) * 55,
            ),
            itemCount: data.items.length,
            itemBuilder: (context, index) {
              final app = data.items[index];
              return _AppCard(
                app: app,
                onTap: () => context.push(
                  '/s/$serverId/more/apps/${Uri.encodeComponent(app.key)}',
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _InstalledTab extends ConsumerWidget {
  const _InstalledTab({required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final installed = ref.watch(installedAppsProvider);
    return AsyncStateView(
      value: installed,
      onRetry: () => ref.invalidate(installedAppsProvider),
      loading: const SkeletonList(itemCount: 8),
      isEmpty: (data) => data.items.isEmpty,
      empty: RefreshableEmptyState(
        onRefresh: () => ref.refresh(installedAppsProvider.future),
        child: EmptyState(
          icon: TablerIcons.package,
          title: l10n.apps_installedEmptyTitle,
          message: l10n.apps_installedEmptyMessage,
        ),
      ),
      builder: (data) => RefreshIndicator(
        onRefresh: () => ref.refresh(installedAppsProvider.future),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTokens.s16),
          itemCount: data.items.length,
          itemBuilder: (context, index) {
            final app = data.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s12),
              child: TonalCard(
                onTap: () =>
                    context.push('/s/$serverId/more/apps/installed/${app.id}'),
                child: Row(
                  children: [
                    StatusDot(status: app.status.toLowerCase()),
                    const SizedBox(width: AppTokens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.displayName,
                            style: AppTextStyles.titleM,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${app.version} · ${app.httpPort}',
                            style: AppTextStyles.bodyS.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (app.canUpdate)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.s8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.warning.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(AppTokens.rXs),
                        ),
                        child: Text(
                          l10n.apps_update_available,
                          style: AppTextStyles.caption.copyWith(
                            color: context.appColors.warning,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.app, required this.onTap});

  final AppCatalogDto app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return TonalCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTokens.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppTokens.iconBadge,
                height: AppTokens.iconBadge,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTokens.rSm),
                ),
                child: Center(
                  child: Text(
                    app.name.isEmpty ? '?' : app.name.substring(0, 1),
                    style: AppTextStyles.titleS.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  app.name,
                  style: AppTextStyles.titleS,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (app.installed)
                Icon(
                  TablerIcons.circle_check,
                  size: 16,
                  color: context.appColors.success,
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Text(
            app.description,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            app.versions.isEmpty ? '-' : app.versions.first,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
