import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/dto/website/website_dto.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/search_field.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
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

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppBarLarge(
              title: l10n.websites_title,
              subtitle: server?.displayName,
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
}

class _WebsiteCard extends StatelessWidget {
  const _WebsiteCard({required this.site, required this.onTap});

  final WebsiteDto site;
  final VoidCallback onTap;

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

  DateTime _parseDate(String raw) {
    return DateTime.tryParse(raw) ?? DateTime(1970);
  }
}
