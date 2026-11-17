import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'server_edit_page.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../domain/entities/server.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/servers_provider.dart';
import '../../settings/providers/app_settings_provider.dart';

class ServersPage extends ConsumerStatefulWidget {
  const ServersPage({super.key});

  @override
  ConsumerState<ServersPage> createState() => _ServersPageState();
}

class _ServersPageState extends ConsumerState<ServersPage>
    with WidgetsBindingObserver {
  Timer? _healthTimer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _setVisible(bool visible) {
    if (_visible == visible) return;
    _visible = visible;
    _syncTimer();
  }

  void _syncTimer() {
    if (!_visible) {
      _healthTimer?.cancel();
      _healthTimer = null;
      return;
    }
    _healthTimer ??= Timer.periodic(
      AppTokens.serverHealthPoll,
      (_) => _refreshHealth(),
    );
  }

  void _refreshHealth() {
    if (!_visible || !mounted) return;
    final items = ref.read(serversProvider).valueOrNull;
    if (items == null || items.isEmpty) return;
    for (final server in items) {
      ref.invalidate(serverHealthProvider(server.id));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncTimer();
    } else {
      _healthTimer?.cancel();
      _healthTimer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _healthTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final servers = ref.watch(serversProvider);
    final lastId = ref.watch(lastServerIdProvider);

    return Scaffold(
      body: VisibilityDetector(
        key: const Key('servers-page'),
        onVisibilityChanged: (info) => _setVisible(info.visibleFraction > 0.5),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppBarLarge(
                title: l10n.servers_title,
                actions: [
                  AppIconButton(
                    icon: TablerIcons.arrows_sort,
                    tooltip: l10n.servers_reorder,
                    onPressed: () async {
                      final items = servers.valueOrNull;
                      if (items == null || items.length < 2) return;
                      await _reorder(context, ref, items);
                    },
                  ),
                  AppIconButton(
                    icon: TablerIcons.settings,
                    tooltip: l10n.settings_title,
                    onPressed: () => context.push('/settings'),
                  ),
                  AppIconButton(
                    icon: TablerIcons.plus,
                    tooltip: l10n.servers_add,
                    onPressed: () => context.push('/servers/add'),
                  ),
                ],
              ),
              Expanded(
                child: AsyncStateView<List<Server>>(
                  value: servers,
                  onRetry: () => ref.read(serversProvider.notifier).refresh(),
                  loading: const Padding(
                    padding: EdgeInsets.all(AppTokens.s16),
                    child: Column(
                      children: [
                        SkeletonCard(height: 224),
                        SkeletonCard(height: 224),
                      ],
                    ),
                  ),
                  isEmpty: (items) => items.isEmpty,
                  empty: _EmptyServers(
                    onAdd: () => context.push('/servers/add'),
                  ),
                  builder: (items) => RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(serversProvider.notifier).refresh();
                      for (final server in items) {
                        ref.invalidate(serverHealthProvider(server.id));
                      }
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        if (items.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppTokens.s20,
                                AppTokens.s8,
                                AppTokens.s20,
                                AppTokens.s8,
                              ),
                              child: SectionHeader(
                                title: l10n.servers_sectionConnected,
                                subtitle: l10n.servers_count(items.length),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.pagePadding,
                            ),
                            sliver: SliverList.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final server = items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppTokens.s12,
                                  ),
                                  child: _ServerCard(
                                    server: server,
                                    isCurrent: server.id == lastId,
                                    onEdit: () => context.push(
                                      '/servers/${server.id}/edit',
                                    ),
                                    onTap: () async {
                                      final haptics =
                                          ref
                                              .read(
                                                appSettingsControllerProvider,
                                              )
                                              .valueOrNull
                                              ?.hapticsEnabled ??
                                          true;
                                      if (haptics) {
                                        await HapticFeedback.selectionClick();
                                      }
                                      await ref
                                          .read(serversProvider.notifier)
                                          .touch(server.id);
                                      ref
                                              .read(
                                                activeServerIdStateProvider
                                                    .notifier,
                                              )
                                              .state =
                                          server.id;
                                      if (!context.mounted) return;
                                      unawaited(
                                        context.push(
                                          '/s/${server.id}/overview',
                                        ),
                                      );
                                    },
                                    onLongPress: () => _showServerActions(
                                      context,
                                      ref,
                                      server,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppTokens.s32),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reorder(
    BuildContext context,
    WidgetRef ref,
    List<Server> servers,
  ) async {
    final l10n = AppLocalizations.of(context);
    final order = List<Server>.of(servers);
    final applied = await showAppSheet<bool>(
      context: context,
      maxHeightFactor: 0.8,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.servers_reorder, style: AppTextStyles.titleM),
                        Text(
                          l10n.servers_reorderHint,
                          style: AppTextStyles.bodyS.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.action_close,
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(TablerIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.s8),
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: order.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() {
                      final item = order.removeAt(oldIndex);
                      order.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final server = order[index];
                    return ListTile(
                      key: ValueKey(server.id),
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(TablerIcons.grip_vertical),
                      ),
                      title: Text(server.displayName),
                      subtitle: Text('${server.host}:${server.port}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTokens.s12),
              PrimaryButton(
                label: l10n.action_save,
                expanded: true,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
    if (applied != true || !context.mounted) return;
    await ref
        .read(serversProvider.notifier)
        .reorder(order.map((server) => server.id).toList(growable: false));
  }

  Future<void> _showServerActions(
    BuildContext context,
    WidgetRef ref,
    Server server,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(server.displayName, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            '${server.host}:${server.port}',
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.edit),
                title: l10n.action_edit,
                onTap: () =>
                    showServerEditSheet(sheetContext, serverId: server.id),
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.copy),
                title: l10n.action_copy,
                subtitle: '${server.host}:${server.port}',
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: '${server.host}:${server.port}'),
                  );
                  Navigator.of(sheetContext).pop();
                  AppToast.success(context, l10n.action_copy);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.servers_delete,
                danger: true,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await showConfirmSheet(
                    context,
                    title: l10n.servers_delete,
                    message: l10n.servers_delete_message,
                    confirmLabel: l10n.action_delete,
                  );
                  if (!confirmed) return;
                  await ref.read(serversProvider.notifier).delete(server.id);
                  ref.invalidate(dioClientProvider(server.id));
                  if (context.mounted) {
                    AppToast.success(context, l10n.action_done);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }
}

class _EmptyServers extends StatelessWidget {
  const _EmptyServers({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: TablerIcons.server,
      title: l10n.servers_empty_title,
      message: l10n.servers_empty_message,
      actionLabel: l10n.servers_add,
      onAction: onAdd,
    );
  }
}

class _ServerCard extends ConsumerWidget {
  const _ServerCard({
    required this.server,
    required this.isCurrent,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
  });

  final Server server;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final health = ref.watch(serverHealthProvider(server.id));
    final snapshot = health.valueOrNull;
    final online = snapshot?.online ?? false;
    final subtitle = _subtitle(server, snapshot);

    return TonalCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServerAvatar(online: online),
              const SizedBox(width: AppTokens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            server.displayName,
                            style: AppTextStyles.titleM,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: AppTokens.s8),
                          const _CurrentPill(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.s4),
              if (snapshot == null)
                const Padding(
                  padding: EdgeInsets.only(top: AppTokens.s8),
                  child: SkeletonBox(width: 62, height: 24),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: AppTokens.s8),
                  child: _ServerStatusPill(
                    online: snapshot.online,
                    latencyMs: snapshot.latencyMs,
                  ),
                ),
              IconButton(
                tooltip: l10n.action_edit,
                icon: Icon(
                  TablerIcons.edit,
                  size: AppTokens.iconList,
                  color: scheme.onSurfaceVariant,
                ),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s16),
          if (snapshot == null)
            const SkeletonBox(height: 52)
          else if (!online)
            const _ServerOfflineRow()
          else
            Row(
              children: [
                Expanded(
                  child: _ServerMetric(
                    label: l10n.dashboard_cpu,
                    value: snapshot.cpuPercent,
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: _ServerMetric(
                    label: l10n.dashboard_memory,
                    value: snapshot.memoryPercent,
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: _ServerMetric(
                    label: l10n.dashboard_disk,
                    value: snapshot.diskPercent,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppTokens.s16),
          Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppTokens.s12),
          Row(
            children: [
              Expanded(
                child: _ServerCount(
                  icon: TablerIcons.world,
                  label: l10n.servers_websites,
                  value: snapshot?.websiteCount,
                  color: context.appColors.chart2,
                ),
              ),
              Expanded(
                child: _ServerCount(
                  icon: TablerIcons.database,
                  label: l10n.servers_databases,
                  value: snapshot?.databaseCount,
                  color: context.appColors.chart3,
                ),
              ),
              Expanded(
                child: _ServerCount(
                  icon: TablerIcons.apps,
                  label: l10n.servers_apps,
                  value: snapshot?.appCount,
                  color: context.appColors.chart4,
                ),
              ),
              Expanded(
                child: _ServerCount(
                  icon: TablerIcons.calendar_time,
                  label: l10n.servers_tasks,
                  value: snapshot?.cronjobCount,
                  color: context.appColors.chart5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s12),
          Row(
            children: [
              Icon(
                TablerIcons.history,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppTokens.s4),
              Expanded(
                child: Text(
                  server.lastUsedAt == null
                      ? (snapshot?.online == true
                            ? l10n.servers_sessionActive
                            : l10n.servers_neverConnected)
                      : l10n.servers_last_seen(
                          formatListTime(server.lastUsedAt, l10n),
                        ),
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
      ),
    );
  }

  String _subtitle(Server server, ServerHealth? snapshot) {
    final distro = snapshot?.distro.trim() ?? '';
    final ip = snapshot?.ipAddress.trim() ?? '';
    final parts = [if (distro.isNotEmpty) distro, if (ip.isNotEmpty) ip];
    if (parts.isEmpty) return '${server.host}:${server.port}';
    return parts.join(' · ');
  }
}

class _ServerAvatar extends StatelessWidget {
  const _ServerAvatar({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final color = online
        ? context.appColors.success
        : context.appColors.neutral;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.16),
            scheme.primary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.rMd),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Icon(TablerIcons.server_2, size: 22, color: color),
    );
  }
}

class _CurrentPill extends StatelessWidget {
  const _CurrentPill();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTokens.rFull),
      ),
      child: Text(
        l10n.servers_current,
        style: AppTextStyles.caption.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ServerStatusPill extends StatelessWidget {
  const _ServerStatusPill({required this.online, required this.latencyMs});

  final bool online;
  final int latencyMs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = online
        ? (latencyMs > 500
              ? context.appColors.warning
              : context.appColors.success)
        : context.appColors.neutral;
    final label = online
        ? (latencyMs > 0 ? '$latencyMs ms' : l10n.servers_online)
        : l10n.servers_offline;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            online ? TablerIcons.activity_heartbeat : TablerIcons.wifi_off,
            size: 12,
            color: color,
          ),
          const SizedBox(width: AppTokens.s4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerOfflineRow extends StatelessWidget {
  const _ServerOfflineRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTokens.rMd),
      ),
      child: Row(
        children: [
          Icon(
            TablerIcons.cloud_off,
            size: AppTokens.iconList,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppTokens.s8),
          Expanded(
            child: Text(
              l10n.servers_offline,
              style: AppTextStyles.bodyS.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerMetric extends StatelessWidget {
  const _ServerMetric({required this.label, required this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final clamped = value?.clamp(0, 100).toDouble();
    final color = clamped == null
        ? context.appColors.neutral
        : usageColor(context, clamped);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppTokens.s4),
            Text(
              clamped == null ? '--' : '${clamped.toStringAsFixed(0)}%',
              style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              Container(height: 5, color: color.withValues(alpha: 0.12)),
              FractionallySizedBox(
                widthFactor: (clamped ?? 0) / 100,
                child: Container(height: 5, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServerCount extends StatelessWidget {
  const _ServerCount({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppTokens.s4),
          Text(
            '$label ${value ?? '--'}',
            style: AppTextStyles.caption.copyWith(
              color: context.scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

Color usageColor(BuildContext context, double percent) {
  final colors = context.appColors;
  if (percent >= 85) return colors.danger;
  if (percent >= 60) return colors.warning;
  return colors.success;
}
