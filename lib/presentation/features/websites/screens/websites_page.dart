import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/dto/website/website_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/action_sheet.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/removable_list_item.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/formatters/enum_labels.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/refreshable_empty_state.dart';
import '../../../common/states/error_toast.dart';
import '../../servers/providers/servers_provider.dart';
import '../providers/websites_provider.dart';

class WebsitesPage extends ConsumerStatefulWidget {
  const WebsitesPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<WebsitesPage> createState() => _WebsitesPageState();
}

class _WebsitesPageState extends ConsumerState<WebsitesPage> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();
  bool _searching = false;
  String _selectedFilter = '';
  bool _selecting = false;
  final Set<int> _selected = {};
  final Set<int> _removing = {};

  bool get _selectionMode => _selecting;

  void _toggle(WebsiteDto site) {
    setState(() {
      _selecting = true;
      if (!_selected.remove(site.id)) _selected.add(site.id);
    });
  }

  void _clearSelection() => setState(() {
    _selecting = false;
    _selected.clear();
  });

  Future<void> _batchDelete() async {
    final l10n = AppLocalizations.of(context);
    final ids = _selected.toList(growable: false);
    if (ids.isEmpty) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_delete,
      message: l10n.files_selectCount(ids.length),
      confirmLabel: l10n.action_delete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      for (final id in ids) {
        await repository.deleteWebsite(id);
      }
      if (!mounted) return;
      setState(() => _removing.addAll(ids));
      await Future<void>.delayed(context.motion(AppTokens.dBase));
      if (!mounted) return;
      _clearSelection();
      AppToast.success(context, l10n.websites_deleted);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      await ref.read(websitesProvider.notifier).refresh();
      if (mounted) setState(() => _removing.removeAll(ids));
    }
  }

  static const _filters = ['', 'running', 'stopped', 'static', 'proxy', 'php'];

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _filterLabel(String value, AppLocalizations l10n) {
    return switch (value) {
      'running' => l10n.websites_running,
      'stopped' => l10n.websites_stopped,
      'static' => l10n.websites_static,
      'proxy' => l10n.websites_proxy,
      'php' => l10n.websites_php,
      _ => l10n.websites_all,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final server = ref.watch(serverByIdProvider(widget.serverId)).valueOrNull;
    final websites = ref.watch(websitesProvider);
    final total = websites.valueOrNull?.total;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppBarLarge(
              title: l10n.websites_title,
              subtitle: [
                if (server != null) server.displayName,
                if (total != null) l10n.websites_count(total),
              ].join(' · '),
              onTitleTap: () => showServerSwitcher(
                context,
                ref,
                currentServerId: widget.serverId,
              ),
              actions: [
                AppIconButton(
                  icon: TablerIcons.refresh,
                  tooltip: l10n.action_refresh,
                  onPressed: () =>
                      ref.read(websitesProvider.notifier).refresh(),
                ),
                AppIconButton(
                  icon: _searching ? TablerIcons.x : TablerIcons.search,
                  tooltip: l10n.action_search,
                  onPressed: () {
                    setState(() {
                      _searching = !_searching;
                      if (!_searching) {
                        _clearSelection();
                        _searchController.clear();
                        ref.read(websitesProvider.notifier).search('');
                      }
                    });
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
                          label: _selectionMode
                              ? l10n.files_cancelSelection
                              : l10n.files_selectAll,
                          value: 'select',
                          icon: _selectionMode
                              ? TablerIcons.square_x
                              : TablerIcons.checkbox,
                        ),
                        SelectionOption(
                          label: l10n.websites_templates,
                          value: 'templates',
                          icon: TablerIcons.layout,
                        ),
                      ],
                    );
                    if (!mounted || value == null) return;
                    if (value == 'select') {
                      setState(() {
                        if (_selectionMode) {
                          _clearSelection();
                        } else {
                          _selecting = true;
                          final items = ref
                              .read(websitesProvider)
                              .valueOrNull
                              ?.items;
                          _selected.addAll(
                            (items ?? const []).map((site) => site.id),
                          );
                        }
                      });
                    } else if (value == 'templates') {
                      if (!context.mounted) return;
                      await context.push(
                        '/s/${widget.serverId}/websites/templates',
                      );
                    }
                  },
                ),
                AppIconButton(
                  icon: TablerIcons.plus,
                  tooltip: l10n.websites_create,
                  onPressed: () =>
                      context.push('/s/${widget.serverId}/websites/create'),
                ),
              ],
            ),
            AnimatedSize(
              duration: context.motion(AppTokens.dBase),
              curve: AppTokens.curveBase,
              alignment: Alignment.topCenter,
              child: _searching
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.pagePadding,
                        vertical: AppTokens.s8,
                      ),
                      child: SearchField(
                        controller: _searchController,
                        hint: l10n.action_search,
                        autofocus: true,
                        onChanged: (value) {
                          _clearSelection();
                          _debouncer(() {
                            ref.read(websitesProvider.notifier).search(value);
                          }, delay: const Duration(milliseconds: 300));
                        },
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            AppFilterChips<String>(
              options: _filters,
              labelOf: (value) => _filterLabel(value, l10n),
              selected: {_selectedFilter},
              onChanged: (selection) {
                if (selection.isEmpty) return;
                setState(() {
                  _selectedFilter = selection.first;
                  _clearSelection();
                });
                ref.read(websitesProvider.notifier).setType(selection.first);
              },
            ),
            Expanded(
              child: AsyncStateView(
                value: websites,
                contentKey: (_selectedFilter, _searchController.text),
                onRetry: () => ref.read(websitesProvider.notifier).refresh(),
                loading: const SkeletonList(itemCount: 8),
                isEmpty: (result) => result.items.isEmpty,
                empty: RefreshableEmptyState(
                  onRefresh: () =>
                      ref.read(websitesProvider.notifier).refresh(),
                  child: EmptyState(
                    icon: TablerIcons.world,
                    title: l10n.websites_empty_title,
                    message: l10n.websites_empty_message,
                    actionLabel: l10n.websites_create,
                    onAction: () =>
                        context.push('/s/${widget.serverId}/websites/create'),
                  ),
                ),
                builder: (result) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(websitesProvider.notifier).refresh(),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.extentAfter < 400) {
                        ref.read(websitesProvider.notifier).loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        context.pagePadding,
                        AppTokens.s8,
                        context.pagePadding,
                        AppTokens.s32,
                      ),
                      itemCount: result.items.length,
                      itemBuilder: (context, index) {
                        final site = result.items[index];
                        return RemovableListItem(
                          key: ValueKey('website-${site.id}'),
                          removing: _removing.contains(site.id),
                          animateIn: true,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppTokens.s12,
                            ),
                            child: _WebsiteCard(
                              site: site,
                              selected: _selected.contains(site.id),
                              selectionMode: _selectionMode,
                              onTap: _selectionMode
                                  ? () => _toggle(site)
                                  : () => _showSiteActions(site),
                              onLongPress: () => _toggle(site),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedSize(
        duration: context.motion(AppTokens.dBase),
        curve: AppTokens.curveBase,
        alignment: Alignment.bottomCenter,
        child: _selectionMode
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.s16),
                  child: Row(
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
                        onPressed: _batchDelete,
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    return switch (status.toLowerCase()) {
      'running' => l10n.websites_running,
      'stopped' => l10n.websites_stopped,
      _ => status,
    };
  }

  Future<void> _showSiteActions(WebsiteDto site) async {
    final l10n = AppLocalizations.of(context);
    final running = site.status.toLowerCase() == 'running';
    final colors = context.appColors;
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.9,
      builder: (sheetContext) => ActionSheetScaffold(
        infoCard: ActionSheetInfoCard(
          leading: Container(
            decoration: BoxDecoration(
              color: colors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.rMd),
            ),
            child: Icon(
              TablerIcons.world,
              color: colors.info,
              size: AppTokens.iconNav,
            ),
          ),
          title: site.primaryDomain,
          subtitle: site.type,
          trailing: ActionSheetStatusPill(
            label: _statusLabel(site.status, l10n),
            color: running ? colors.success : colors.info,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActionSheetSection(
              title: l10n.containers_groupLifecycle,
              icon: TablerIcons.refresh,
              children: [
                ActionSheetRow(
                  icon: running
                      ? TablerIcons.player_pause
                      : TablerIcons.player_play,
                  iconColor: running ? colors.warning : colors.success,
                  title: running ? l10n.websites_stop : l10n.websites_start,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _operateSite(site, running ? 'stop' : 'start');
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.eye,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_open,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openSite(site);
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.copy,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_copyDomain,
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: site.primaryDomain),
                    );
                    if (!sheetContext.mounted) return;
                    Navigator.of(sheetContext).pop();
                    if (!mounted) return;
                    AppToast.success(
                      context,
                      l10n.common_copiedLabel(site.primaryDomain),
                    );
                  },
                ),
              ],
            ),
            ActionSheetSection(
              title: l10n.containers_groupConfig,
              icon: TablerIcons.settings,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.info_circle,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.error_details,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      '/s/${widget.serverId}/websites/${site.id}/config',
                    );
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.world_www,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_domains,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      '/s/${widget.serverId}/websites/${site.id}/domains',
                    );
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.lock,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_sslCertificate,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      '/s/${widget.serverId}/websites/${site.id}/ssl'
                      '?domain=${Uri.encodeComponent(site.primaryDomain)}',
                    );
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.arrows_exchange,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_proxySettings,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      '/s/${widget.serverId}/websites/${site.id}/proxy',
                    );
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.sitemap,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_loadBalance,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      '/s/${widget.serverId}/websites/${site.id}/load-balance',
                    );
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.adjustments,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_advanced,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      '/s/${widget.serverId}/websites/${site.id}/advanced',
                    );
                  },
                ),
                ActionSheetRow(
                  icon: TablerIcons.certificate,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_certificateAccounts,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/s/${widget.serverId}/websites/accounts');
                  },
                ),
              ],
            ),
            ActionSheetSection(
              title: l10n.websites_logs,
              icon: TablerIcons.file_text,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.file_text,
                  iconColor: context.scheme.onSurfaceVariant,
                  title: l10n.websites_logs,
                  subtitle: l10n.websites_liveLogHint,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      '/s/${widget.serverId}/websites/${site.id}/logs',
                    );
                  },
                ),
              ],
            ),
            ActionSheetSection(
              title: l10n.containers_groupDanger,
              icon: TablerIcons.alert_triangle,
              children: [
                ActionSheetRow(
                  icon: TablerIcons.trash,
                  iconColor: colors.danger,
                  title: l10n.websites_delete,
                  danger: true,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _deleteSite(site);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _operateSite(WebsiteDto site, String operate) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.operateWebsite(site.id, operate);
      if (!mounted) return;
      AppToast.success(
        context,
        operate == 'start' ? l10n.websites_started : l10n.websites_stopped,
      );
      await ref.read(websitesProvider.notifier).refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _openSite(WebsiteDto site) async {
    final l10n = AppLocalizations.of(context);
    final protocol = site.protocol.toLowerCase() == 'https' ? 'https' : 'http';
    final uri = Uri.tryParse('$protocol://${site.primaryDomain}');
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      showErrorToast(
        context,
        ApiBusinessException(400, l10n.websites_openFailed),
      );
    }
  }

  Future<void> _deleteSite(WebsiteDto site) async {
    final l10n = AppLocalizations.of(context);
    final options = await showAppSheet<WebsiteDeleteOptions>(
      context: context,
      builder: (sheetContext) => WebsiteDeleteSheet(site: site),
    );
    if (options == null || !mounted) return;
    final confirmed = await showConfirmSheet(
      context,
      title: l10n.websites_deleteTitle(site.primaryDomain),
      message: l10n.websites_deleteMessage,
      confirmLabel: l10n.action_delete,
      requireText: site.primaryDomain,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteWebsite(
        site.id,
        deleteBackup: options.deleteBackup,
        forceDelete: options.forceDelete,
        deleteDB: options.deleteDB,
      );
      if (!mounted) return;
      setState(() => _removing.add(site.id));
      await Future<void>.delayed(context.motion(AppTokens.dBase));
      if (!mounted) return;
      AppToast.success(context, l10n.websites_deleted);
      await ref.read(websitesProvider.notifier).refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _removing.remove(site.id));
    }
  }
}

class WebsiteDeleteOptions {
  const WebsiteDeleteOptions({
    required this.deleteDB,
    required this.deleteBackup,
    required this.forceDelete,
  });

  final bool deleteDB;
  final bool deleteBackup;
  final bool forceDelete;
}

class WebsiteDeleteSheet extends StatefulWidget {
  const WebsiteDeleteSheet({super.key, required this.site});

  final WebsiteDto site;

  @override
  State<WebsiteDeleteSheet> createState() => WebsiteDeleteSheetState();
}

class WebsiteDeleteSheetState extends State<WebsiteDeleteSheet> {
  bool _deleteDB = false;
  bool _deleteBackup = false;
  bool _forceDelete = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasDatabase = widget.site.dbID > 0;
    final scheme = context.scheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.websites_deleteTitle(widget.site.primaryDomain),
          style: AppTextStyles.titleL,
        ),
        const SizedBox(height: AppTokens.s8),
        Text(
          l10n.websites_deleteMessage,
          style: AppTextStyles.bodyM.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppTokens.s16),
        TonalCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              CheckboxListTile(
                value: _deleteDB,
                onChanged: hasDatabase
                    ? (value) => setState(() => _deleteDB = value ?? false)
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  hasDatabase
                      ? l10n.websites_deleteDatabaseCount(1)
                      : l10n.websites_deleteDatabaseCount(0),
                ),
                subtitle: hasDatabase
                    ? Text('${widget.site.dbType} · ${widget.site.dbID}')
                    : null,
              ),
              CheckboxListTile(
                value: _deleteBackup,
                onChanged: (value) =>
                    setState(() => _deleteBackup = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l10n.websites_deleteBackup),
              ),
              CheckboxListTile(
                value: _forceDelete,
                onChanged: (value) =>
                    setState(() => _forceDelete = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l10n.websites_forceDelete),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s24),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: l10n.action_cancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: DangerButton(
                label: l10n.action_delete,
                onPressed: () => Navigator.of(context).pop(
                  WebsiteDeleteOptions(
                    deleteDB: _deleteDB,
                    deleteBackup: _deleteBackup,
                    forceDelete: _forceDelete,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WebsiteCard extends StatelessWidget {
  const _WebsiteCard({
    required this.site,
    required this.onTap,
    required this.onLongPress,
    required this.selected,
    required this.selectionMode,
  });

  final WebsiteDto site;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool selected;
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final typeLabel = websiteTypeLabel(site.type, l10n);
    final expiry = _parseDate(site.sslExpireDate).isAfter(DateTime(2000))
        ? _parseDate(site.sslExpireDate)
        : _parseDate(site.expireDate);
    final daysLeft = expiry.difference(DateTime.now()).inDays;
    final expiryColor = daysLeft < 0
        ? context.appColors.danger
        : daysLeft < 7
        ? context.appColors.danger
        : daysLeft < 30
        ? context.appColors.warning
        : scheme.onSurfaceVariant;

    return TonalCard(
      onTap: onTap,
      onLongPress: onLongPress,
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (selectionMode)
                Checkbox(value: selected, onChanged: (_) => onTap()),
              StatusDot(status: site.status.toLowerCase()),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  site.primaryDomain,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              Text(
                _statusLabel(site.status, l10n),
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (site.sslExpireDate.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.s8,
                    vertical: AppTokens.chipPaddingY,
                  ),
                  decoration: BoxDecoration(
                    color: expiryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppTokens.rXs),
                  ),
                  child: Text(
                    l10n.websites_ssl,
                    style: AppTextStyles.caption.copyWith(
                      color: expiryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!selectionMode) ...[
                const SizedBox(width: AppTokens.s4),
                Icon(
                  TablerIcons.chevron_right,
                  size: AppTokens.iconList,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.s8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppTokens.rXs),
                ),
                child: Text(
                  typeLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  site.siteDir.isEmpty ? site.sitePath : site.siteDir,
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (expiry.isAfter(DateTime(2000))) ...[
            const SizedBox(height: AppTokens.s8),
            Row(
              children: [
                Icon(TablerIcons.calendar_event, size: 14, color: expiryColor),
                const SizedBox(width: 4),
                Text(
                  l10n.websites_expire_days(daysLeft),
                  style: AppTextStyles.caption.copyWith(
                    color: expiryColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    return switch (status.toLowerCase()) {
      'running' => l10n.websites_running,
      'stopped' => l10n.websites_stopped,
      _ => status,
    };
  }

  DateTime _parseDate(String raw) {
    return DateTime.tryParse(raw) ?? DateTime(1970);
  }
}
