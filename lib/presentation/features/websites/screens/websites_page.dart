import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/dto/website/website_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
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
              onTitleLongPress: () => showServerSwitcher(
                context,
                ref,
                currentServerId: widget.serverId,
              ),
              actions: [
                AppIconButton(
                  icon: _searching ? TablerIcons.x : TablerIcons.search,
                  tooltip: l10n.action_search,
                  onPressed: () {
                    setState(() => _searching = !_searching);
                    if (!_searching) {
                      _searchController.clear();
                      ref.read(websitesProvider.notifier).search('');
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
            if (_searching)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.s16,
                  vertical: AppTokens.s8,
                ),
                child: SearchField(
                  controller: _searchController,
                  hint: l10n.action_search,
                  autofocus: true,
                  onChanged: (value) {
                    _debouncer(() {
                      ref.read(websitesProvider.notifier).search(value);
                    }, delay: const Duration(milliseconds: 300));
                  },
                ),
              ),
            AppFilterChips<String>(
              options: _filters,
              labelOf: (value) => _filterLabel(value, l10n),
              selected: {_selectedFilter},
              onChanged: (selection) {
                if (selection.isEmpty) return;
                setState(() => _selectedFilter = selection.first);
                ref.read(websitesProvider.notifier).setType(selection.first);
              },
            ),
            Expanded(
              child: AsyncStateView(
                value: websites,
                onRetry: () => ref.read(websitesProvider.notifier).refresh(),
                loading: const SkeletonList(itemCount: 8),
                isEmpty: (result) => result.items.isEmpty,
                empty: EmptyState(
                  icon: TablerIcons.world,
                  title: l10n.websites_empty_title,
                  message: l10n.websites_empty_message,
                  actionLabel: l10n.websites_create,
                  onAction: () =>
                      context.push('/s/${widget.serverId}/websites/create'),
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
                      padding: const EdgeInsets.fromLTRB(
                        AppTokens.s16,
                        AppTokens.s8,
                        AppTokens.s16,
                        AppTokens.s32,
                      ),
                      itemCount: result.items.length,
                      itemBuilder: (context, index) {
                        final site = result.items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTokens.s12),
                          child: _WebsiteCard(
                            site: site,
                            onTap: () => context.push(
                              '/s/${widget.serverId}/websites/${site.id}',
                            ),
                            onLongPress: () => _showSiteActions(site),
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
    );
  }

  Future<void> _showSiteActions(WebsiteDto site) async {
    final l10n = AppLocalizations.of(context);
    final running = site.status.toLowerCase() == 'running';
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(site.primaryDomain, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            site.type,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: Icon(
                  running ? TablerIcons.player_pause : TablerIcons.player_play,
                ),
                title: running ? l10n.websites_stop : l10n.websites_start,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _operateSite(site, running ? 'stop' : 'start');
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.copy),
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
              SplitListTile(
                leading: const Icon(TablerIcons.world),
                title: l10n.websites_open,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openSite(site);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
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
    final protocol = site.protocol.toLowerCase() == 'https' ? 'https' : 'http';
    final uri = Uri.tryParse('$protocol://${site.primaryDomain}');
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      showErrorToast(context, StateError('open website failed'));
    }
  }

  Future<void> _deleteSite(WebsiteDto site) async {
    final l10n = AppLocalizations.of(context);
    final options = await showAppSheet<WebsiteDeleteOptions>(
      context: context,
      builder: (sheetContext) => WebsiteDeleteSheet(site: site),
    );
    if (options == null || !mounted) return;
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.deleteWebsite(
        site.id,
        deleteBackup: options.deleteBackup,
        forceDelete: options.forceDelete,
        deleteDB: options.deleteDB,
      );
      if (!mounted) return;
      AppToast.success(context, l10n.websites_deleted);
      await ref.read(websitesProvider.notifier).refresh();
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
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
  });

  final WebsiteDto site;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final typeLabel = switch (site.type.toLowerCase()) {
      'static' => l10n.websites_static,
      'proxy' || 'reverse_proxy' => l10n.websites_proxy,
      'php' => l10n.websites_php,
      _ => site.type,
    };
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppTokens.rXs),
                  ),
                  child: Text(
                    'SSL',
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: AppTokens.s4),
              Icon(
                TablerIcons.chevron_right,
                size: AppTokens.iconList,
                color: scheme.onSurfaceVariant,
              ),
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
