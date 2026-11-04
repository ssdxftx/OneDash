import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../domain/entities/server.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/metric_card.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../providers/servers_provider.dart';
import '../../settings/providers/app_settings_provider.dart';

class ServersPage extends ConsumerWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final servers = ref.watch(serversProvider);
    final lastId = ref.watch(lastServerIdProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppBarLarge(
              title: l10n.servers_title,
              actions: [
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
                      SkeletonCard(height: 168),
                      SkeletonCard(height: 168),
                    ],
                  ),
                ),
                isEmpty: (items) => items.isEmpty,
                empty: _EmptyServers(onAdd: () => context.push('/servers/add')),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTokens.s16,
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
                                            .read(appSettingsControllerProvider)
                                            .valueOrNull
                                            ?.hapticsEnabled ??
                                        true;
                                    if (haptics) {
                                      await HapticFeedback.selectionClick();
                                    }
                                    await ref
                                        .read(serversProvider.notifier)
                                        .touch(server.id);
                                    if (!context.mounted) return;
                                    context.go('/s/${server.id}/overview');
                                  },
                                  onLongPress: () =>
                                      _showServerActions(context, ref, server),
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
    );
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
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/servers/${server.id}/edit');
                },
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

    return TonalCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusDot(
                status: online ? 'running' : 'offline',
                semanticLabel: online
                    ? l10n.servers_online
                    : l10n.servers_offline,
              ),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  server.displayName,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: l10n.action_edit,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  TablerIcons.edit,
                  size: AppTokens.iconList,
                  color: scheme.onSurfaceVariant,
                ),
                onPressed: onEdit,
              ),
              if (isCurrent)
                Container(
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
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s4),
          Text(
            '${server.host}:${server.port}',
            style: AppTextStyles.bodyS.copyWith(
              color: scheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          if (snapshot == null)
            const SkeletonBox(height: 48)
          else if (!snapshot.online)
            Row(
              children: [
                Icon(
                  TablerIcons.wifi_off,
                  size: AppTokens.iconList,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppTokens.s8),
                Text(
                  l10n.servers_offline,
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                _MiniMetric(
                  label: l10n.dashboard_cpu,
                  value: snapshot.cpuPercent ?? 0,
                ),
                const SizedBox(width: AppTokens.s16),
                _MiniMetric(
                  label: l10n.dashboard_memory,
                  value: snapshot.memoryPercent ?? 0,
                ),
                const SizedBox(width: AppTokens.s16),
                _MiniMetric(
                  label: l10n.dashboard_disk,
                  value: snapshot.diskPercent ?? 0,
                ),
              ],
            ),
          const SizedBox(height: AppTokens.s12),
          Row(
            children: [
              Expanded(
                child: Text(
                  server.lastUsedAt == null
                      ? l10n.servers_offline
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
              if (snapshot != null && snapshot.online)
                Text(
                  '${l10n.servers_online} · ${snapshot.latencyMs} ms',
                  style: AppTextStyles.caption.copyWith(
                    color: context.appColors.success,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MetricRing(
          value: value,
          label: label,
          size: 38,
          strokeWidth: 4,
          center: const SizedBox.shrink(),
        ),
        const SizedBox(width: AppTokens.s8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
