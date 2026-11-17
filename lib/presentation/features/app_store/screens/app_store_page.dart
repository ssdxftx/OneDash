import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/dto/app/app_catalog_dto.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/dto/common/page_result.dart';
import '../../../common/components/action_sheet.dart';
import '../../../common/formatters/status_labels.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_icon.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/task_progress_sheet.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/refreshable_empty_state.dart';
import '../../servers/providers/servers_provider.dart';
import '../../../common/states/error_toast.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../containers/widgets/container_log_page.dart';
import '../widgets/installed_app_actions.dart';
import '../widgets/installed_app_card.dart';
import '../widgets/installed_skeleton.dart';
import 'installed_app_page.dart';
import '../providers/app_store_provider.dart';
import 'app_detail_page.dart';

Future<bool> _isIgnored(WidgetRef ref, int installId) async {
  try {
    final ignored = await ref.read(installedIgnoredProvider(installId).future);
    return ignored != null;
  } catch (_) {
    return false;
  }
}

Future<String?> _newVersion(WidgetRef ref, AppInstalledDto app) async {
  if (!app.canUpdate) return null;
  try {
    final repository = await ref.read(appRepositoryProvider.future);
    final versions = await repository.getUpdateVersions(app.id);
    return versions.isEmpty ? null : versions.first.version;
  } catch (_) {
    return null;
  }
}

Future<void> _syncInstalledApps(WidgetRef ref) async {
  try {
    final repository = await ref.read(appRepositoryProvider.future);
    await repository.syncInstalledApps();
  } catch (_) {
    // Fall back to the local installed list when the panel is offline.
  }
  await ref.read(installedAppsProvider.notifier).refresh();
}

class AppStorePage extends ConsumerStatefulWidget {
  const AppStorePage({super.key, required this.serverId, this.initialTab = 0});

  final int serverId;
  final int initialTab;

  @override
  ConsumerState<AppStorePage> createState() => _AppStorePageState();
}

class _AppStorePageState extends ConsumerState<AppStorePage> {
  static const _busyStatuses = {'installing', 'rebuilding', 'upgrading'};

  final _searchController = TextEditingController();
  final _searchDebouncer = Debouncer();
  String _query = '';
  Timer? _statusTimer;

  void _syncStatusTimer(PageResult<AppInstalledDto>? data) {
    final busy =
        data?.items.any(
          (app) => _busyStatuses.contains(app.status.toLowerCase()),
        ) ??
        false;
    if (!busy) {
      _statusTimer?.cancel();
      _statusTimer = null;
      return;
    }
    _statusTimer ??= Timer.periodic(AppTokens.appStatusPoll, (_) {
      if (!mounted) return;
      invalidateInstalledAppLists(ref);
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _searchDebouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkUpdates(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(appRepositoryProvider.future);
      final result = await repository.checkAppUpdates();
      if (!context.mounted) return;
      if (result['canUpdate'] == true) {
        AppToast.success(context, l10n.apps_storeCanUpdate);
      } else {
        AppToast.success(context, l10n.apps_storeLatest);
      }
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
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
      final saved = await pushFormPage<bool>(
        context,
        StatefulBuilder(
          builder: (pageContext, setState) => SimpleFormPage(
            title: l10n.apps_storeSettings,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
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
            ],
          ),
        ),
      );
      if (saved != true || !context.mounted) return;
      await Future.wait([
        for (final entry in values.entries)
          repository.updateStoreConfig(scope: entry.key, enable: entry.value),
      ]);
      if (!context.mounted) return;
      AppToast.success(context, l10n.action_saved);
    } catch (error) {
      if (!context.mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _sortInstalled(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final data = await ref.read(installedAppsProvider.future);
      if (!context.mounted) return;
      final items = data.items;
      if (items.isEmpty) {
        AppToast.warning(context, l10n.apps_installedEmptyTitle);
        return;
      }
      final controllers = {
        for (final app in items)
          app.id: TextEditingController(text: '${app.sortOrder}'),
      };
      final saved = await pushFormPage<bool>(
        context,
        Builder(
          builder: (pageContext) => SimpleFormPage(
            title: l10n.apps_sort,
            onSave: () async => Navigator.of(pageContext).pop(true),
            children: [
              Text(
                l10n.apps_sortHint,
                style: AppTextStyles.bodyS.copyWith(
                  color: pageContext.scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTokens.s12),
              for (final app in items) ...[
                AppTextField(
                  controller: controllers[app.id]!,
                  label: app.displayName,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppTokens.s12),
              ],
            ],
          ),
        ),
      );
      final payload = [
        for (final app in items)
          {
            'installID': app.id,
            'sortOrder': int.tryParse(controllers[app.id]!.text.trim()) ?? 0,
          },
      ];
      for (final controller in controllers.values) {
        controller.dispose();
      }
      if (saved != true || !context.mounted) return;
      final repository = await ref.read(appRepositoryProvider.future);
      await repository.updateInstalledSort(payload);
      invalidateInstalledAppLists(ref);
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
    if (remote) {
      final message = await repository.syncRemoteApps(taskID);
      if (!context.mounted) return;
      if (message != null && message.isNotEmpty) {
        AppToast.show(context, message);
        ref.invalidate(appCatalogProvider(_query));
        invalidateInstalledAppLists(ref);
        return;
      }
    }
    final success = await TaskProgressSheet.run(
      context,
      title: remote ? l10n.apps_syncRemote : l10n.apps_syncLocal,
      task: (controller) async {
        if (!remote) await repository.syncLocalApps(taskID);
        await InstalledAppActions.waitTask(controller, repository, taskID);
      },
    );
    if (!success || !context.mounted) return;
    ref.invalidate(appCatalogProvider(_query));
    invalidateInstalledAppLists(ref);
    AppToast.success(context, l10n.action_done);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 预热：进入页面即发出已安装请求，而不是等用户点 tab。
    final installed = ref.watch(installedAppsProvider);
    _syncStatusTimer(installed.valueOrNull);
    final server = ref.watch(serverByIdProvider(widget.serverId)).valueOrNull;
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.apps_title,
        subtitle: server?.displayName,
        onTitleTap: () =>
            showServerSwitcher(context, ref, currentServerId: widget.serverId),
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () {
              ref.invalidate(appCatalogProvider(_query));
              invalidateInstalledAppLists(ref);
            },
          ),
          AppIconButton(
            icon: TablerIcons.dots,
            tooltip: l10n.action_more,
            onPressed: () async {
              final value = await showSelectionMenu<String>(
                context,
                options: [
                  SelectionOption(
                    label: l10n.apps_syncRemote,
                    value: 'remote',
                    icon: TablerIcons.cloud_download,
                  ),
                  SelectionOption(
                    label: l10n.apps_syncLocal,
                    value: 'local',
                    icon: TablerIcons.database_import,
                  ),
                  SelectionOption(
                    label: l10n.apps_checkUpdates,
                    value: 'updates',
                    icon: TablerIcons.refresh_alert,
                  ),
                  SelectionOption(
                    label: l10n.apps_sort,
                    value: 'sort',
                    icon: TablerIcons.sort_ascending,
                  ),
                  SelectionOption(
                    label: l10n.apps_storeSettings,
                    value: 'settings',
                    icon: TablerIcons.settings,
                  ),
                ],
              );
              if (!context.mounted) return;
              if (value == 'remote') {
                await _sync(context, ref, remote: true);
                return;
              }
              if (value == 'local') {
                await _sync(context, ref, remote: false);
                return;
              }
              if (value == 'updates') {
                await _checkUpdates(context, ref);
                return;
              }
              if (value == 'sort') {
                await _sortInstalled(context, ref);
                return;
              }
              if (value == 'settings') {
                await _storeSettings(context, ref);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.pagePadding,
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
              labels: [
                l10n.apps_allApps,
                l10n.apps_installed,
                l10n.apps_upgradable,
              ],
              children: [
                _CatalogTab(serverId: widget.serverId, query: _query),
                _InstalledTab(serverId: widget.serverId),
                _InstalledTab(serverId: widget.serverId, onlyUpgradable: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogTab extends ConsumerStatefulWidget {
  const _CatalogTab({required this.serverId, required this.query});

  final int serverId;
  final String query;

  @override
  ConsumerState<_CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends ConsumerState<_CatalogTab> {
  final Set<String> _tags = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(appCatalogProvider(widget.query));
    final tags = ref.watch(appTagsProvider);
    return Column(
      children: [
        tags.when(
          data: (items) => items.isEmpty
              ? const SizedBox.shrink()
              : AppFilterChips<String>(
                  options: [for (final tag in items) tag.key],
                  labelOf: (key) {
                    final item = items.firstWhere(
                      (tag) => tag.key == key,
                      orElse: () => items.first,
                    );
                    return item.name.isEmpty ? item.key : item.name;
                  },
                  selected: _tags,
                  multiSelect: true,
                  onChanged: (value) => setState(() {
                    _tags
                      ..clear()
                      ..addAll(value);
                  }),
                ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        Expanded(
          child: AsyncStateView(
            value: catalog,
            onRetry: () =>
                ref.read(appCatalogProvider(widget.query).notifier).refresh(),
            loading: const CatalogAppSkeletonList(),
            isEmpty: (data) => _visible(data.items).isEmpty,
            empty: RefreshableEmptyState(
              onRefresh: () =>
                  ref.read(appCatalogProvider(widget.query).notifier).refresh(),
              child: EmptyState(
                icon: TablerIcons.apps,
                title: l10n.apps_emptyTitle,
                message: l10n.apps_emptyMessage,
              ),
            ),
            builder: (data) {
              final visible = _visible(data.items);
              return RefreshIndicator(
                onRefresh: () => ref
                    .read(appCatalogProvider(widget.query).notifier)
                    .refresh(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.extentAfter < 400) {
                      ref
                          .read(appCatalogProvider(widget.query).notifier)
                          .loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(context.pagePadding),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final app = visible[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTokens.s12),
                        child: _AppRow(
                          app: app,
                          cacheKey: '${widget.serverId}:${app.key}',
                          onTap: () => showAppDetailSheet(
                            context,
                            serverId: widget.serverId,
                            appId: app.key,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<AppCatalogDto> _visible(List<AppCatalogDto> items) {
    if (_tags.isEmpty) return items;
    final names = <String>{
      for (final tag in ref.read(appTagsProvider).valueOrNull ?? const [])
        if (_tags.contains(tag.key)) tag.name,
    };
    return items
        .where(
          (app) =>
              app.tags.any((tag) => _tags.contains(tag) || names.contains(tag)),
        )
        .toList(growable: false);
  }
}

class _InstalledTab extends ConsumerWidget {
  const _InstalledTab({required this.serverId, this.onlyUpgradable = false});

  final int serverId;
  final bool onlyUpgradable;

  List<AppInstalledDto> _visible(List<AppInstalledDto> items) {
    if (!onlyUpgradable) return items;
    return items.where((item) => item.canUpdate).toList(growable: false);
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    AppInstalledDto app,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final running = app.status.toLowerCase() == 'running';
    final hasContainer = app.container.trim().isNotEmpty;
    final ignoredFuture = _isIgnored(ref, app.id);
    final versionFuture = _newVersion(ref, app);
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.9,
      builder: (sheetContext) => ActionSheetScaffold(
        infoCard: ActionSheetInfoCard(
          leading: AppIcon(
            name: app.displayName,
            icon: app.icon,
            size: 56,
            cacheKey: '$serverId:${app.appKey}',
            iconLoader: () => ref
                .read(appRepositoryProvider.future)
                .then((repository) => repository.getAppIcon(app.appKey)),
          ),
          title: app.displayName,
          subtitle: '${app.version} · ${app.httpPort}',
          trailing: ActionSheetStatusPill(
            label: appStatusLabel(app.status, l10n),
            color: colors.status(app.status),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActionSheetSection(
              title: l10n.containers_groupConfig,
              icon: TablerIcons.settings,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.info_circle,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.error_details,
                  onTap: () => showInstalledAppSheet(
                    sheetContext,
                    serverId: serverId,
                    installId: '${app.id}',
                    detailId: app.appDetailId,
                  ),
                ),
                if (hasContainer)
                  ActionSheetRow(
                    icon: TablerIcons.terminal_2,
                    iconColor: context.scheme.onSurfaceVariant,
                    title: l10n.containers_terminal,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      context.push(
                        '/s/$serverId/terminal?container='
                        '${Uri.encodeComponent(app.container)}',
                      );
                    },
                  ),
                if (hasContainer)
                  ActionSheetRow(
                    icon: TablerIcons.file_text,
                    iconColor: context.scheme.onSurfaceVariant,
                    title: l10n.containers_viewLogs,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      openContainerLogs(
                        context,
                        ref,
                        containerName: app.container,
                        subtitle: app.displayName,
                      );
                    },
                  ),
              ],
            ),
            ActionSheetSection(
              title: l10n.containers_groupLifecycle,
              icon: TablerIcons.refresh,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.player_play,
                  iconColor: colors.success,
                  title: l10n.containers_start,
                  enabled: !running,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    InstalledAppActions.operate(context, ref, app, 'start');
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.player_stop,
                  iconColor: colors.warning,
                  title: l10n.containers_stop,
                  enabled: running,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    InstalledAppActions.operate(context, ref, app, 'stop');
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.refresh,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.containers_restart,
                  enabled: running,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    InstalledAppActions.operate(context, ref, app, 'restart');
                  },
                ),
              ],
            ),
            FutureBuilder<bool>(
              future: ignoredFuture,
              builder: (context, ignoredSnapshot) => FutureBuilder<String?>(
                future: versionFuture,
                builder: (context, versionSnapshot) {
                  final ignored = ignoredSnapshot.data ?? false;
                  final newVersion = versionSnapshot.data;
                  return ActionSheetSection(
                    title: l10n.containers_groupMaintenance,
                    icon: TablerIcons.tool,
                    children: [
                      if (app.canUpdate)
                        ActionSheetRow(
                          icon: TablerIcons.arrow_up_circle,
                          iconColor: colors.success,
                          title: l10n.apps_upgrade,
                          subtitle: newVersion == null
                              ? app.version
                              : '${app.version} → $newVersion',
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            InstalledAppActions.upgrade(context, ref, app);
                          },
                        ),
                      ActionSheetRow(
                        icon: TablerIcons.adjustments,
                        iconColor: context.scheme.onSurfaceVariant,
                        title: l10n.apps_editParams,
                        subtitle: app.version,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          InstalledAppActions.editParams(context, ref, app);
                        },
                      ),
                      ActionSheetRow(
                        icon: TablerIcons.plug,
                        iconColor: context.scheme.onSurfaceVariant,
                        title: l10n.apps_changePort,
                        subtitle: '${app.httpPort}',
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          InstalledAppActions.changePort(context, ref, app);
                        },
                      ),
                      ActionSheetRow(
                        icon: TablerIcons.info_circle,
                        iconColor: context.scheme.onSurfaceVariant,
                        title: l10n.apps_connInfo,
                        subtitle: app.container,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          InstalledAppActions.showConnInfo(context, ref, app);
                        },
                      ),
                      ActionSheetRow(
                        icon: TablerIcons.file_settings,
                        iconColor: context.scheme.onSurfaceVariant,
                        title: l10n.apps_defaultConfig,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          InstalledAppActions.showDefaultConfig(
                            context,
                            ref,
                            app,
                          );
                        },
                      ),
                      ActionSheetRow(
                        icon: TablerIcons.bell_off,
                        iconColor: context.scheme.onSurfaceVariant,
                        title: ignored
                            ? l10n.apps_cancelIgnoreUpdate
                            : l10n.apps_ignoreUpdate,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          InstalledAppActions.toggleIgnore(context, ref, app);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            if (app.appDetailId > 0)
              ActionSheetSection(
                title: l10n.containers_groupDanger,
                icon: TablerIcons.alert_triangle,
                children: [
                  ActionSheetRow(
                    icon: TablerIcons.trash,
                    iconColor: colors.danger,
                    title: l10n.apps_uninstall,
                    danger: true,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await InstalledAppActions.uninstall(context, ref, app);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final installed = onlyUpgradable
        ? ref.watch(upgradableAppsProvider)
        : ref.watch(installedAppsProvider);
    return AsyncStateView(
      value: installed,
      onRetry: () => onlyUpgradable
          ? ref.read(upgradableAppsProvider.notifier).refresh()
          : _syncInstalledApps(ref),
      loading: const InstalledAppSkeletonList(),
      isEmpty: (data) => _visible(data.items).isEmpty,
      empty: RefreshableEmptyState(
        onRefresh: () => onlyUpgradable
            ? ref.read(upgradableAppsProvider.notifier).refresh()
            : _syncInstalledApps(ref),
        child: EmptyState(
          icon: TablerIcons.package,
          title: onlyUpgradable
              ? l10n.apps_upgradableEmptyTitle
              : l10n.apps_installedEmptyTitle,
          message: onlyUpgradable
              ? l10n.apps_upgradableEmptyMessage
              : l10n.apps_installedEmptyMessage,
        ),
      ),
      builder: (data) {
        final visible = _visible(data.items);
        return RefreshIndicator(
          onRefresh: () => onlyUpgradable
              ? ref.read(upgradableAppsProvider.notifier).refresh()
              : _syncInstalledApps(ref),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 400) {
                if (onlyUpgradable) {
                  ref.read(upgradableAppsProvider.notifier).loadMore();
                } else {
                  ref.read(installedAppsProvider.notifier).loadMore();
                }
              }
              return false;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(context.pagePadding),
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final app = visible[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.s12),
                  child: InstalledAppCard(
                    name: app.displayName,
                    icon: app.icon,
                    cacheKey: '$serverId:${app.appKey}',
                    iconLoader: () => ref
                        .read(appRepositoryProvider.future)
                        .then(
                          (repository) => repository.getAppIcon(app.appKey),
                        ),
                    status: app.status.toLowerCase(),
                    subtitle: '${app.version} · ${app.httpPort}',
                    canUpdate: app.canUpdate,
                    updateLabel: l10n.apps_update_available,
                    onTap: () => _showActions(context, ref, app),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _AppRow extends ConsumerWidget {
  const _AppRow({
    required this.app,
    required this.cacheKey,
    required this.onTap,
  });

  final AppCatalogDto app;
  final String cacheKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.scheme;
    return TonalCard(
      onTap: onTap,
      child: Row(
        children: [
          AppIcon(
            name: app.name,
            icon: app.icon,
            size: 44,
            cacheKey: cacheKey,
            iconLoader: () => ref
                .read(appRepositoryProvider.future)
                .then((repository) => repository.getAppIcon(app.key)),
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        app.name,
                        style: AppTextStyles.titleM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (app.installed) ...[
                      const SizedBox(width: AppTokens.s8),
                      Icon(
                        TablerIcons.circle_check,
                        size: AppTokens.iconSmall,
                        color: context.appColors.success,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  app.description,
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTokens.s8),
                Wrap(
                  spacing: AppTokens.s8,
                  runSpacing: AppTokens.s4,
                  children: [
                    if (app.versions.isNotEmpty)
                      _AppChip(label: app.versions.first),
                    for (final tag in app.tags.take(2)) _AppChip(label: tag),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.s8),
          Icon(
            TablerIcons.chevron_right,
            size: AppTokens.iconList,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _AppChip extends StatelessWidget {
  const _AppChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTokens.rXs),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
