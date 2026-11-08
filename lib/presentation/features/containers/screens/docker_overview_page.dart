import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/container_item_stats_dto.dart';
import '../../../../data/dto/container/container_status_dto.dart';
import '../../../../data/dto/container/docker_status_dto.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_toast.dart';
import '../../servers/providers/servers_provider.dart';
import '../providers/container_resources_provider.dart';
import '../providers/containers_provider.dart';

class DockerOverviewPage extends ConsumerWidget {
  const DockerOverviewPage({super.key, required this.serverId});

  final int serverId;

  void _refresh(WidgetRef ref) {
    ref.invalidate(dockerStatusProvider);
    ref.invalidate(containerStatusProvider);
    ref.invalidate(containerItemStatsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final server = ref.watch(serverByIdProvider(serverId)).valueOrNull;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppBarLarge(
              title: l10n.nav_containers,
              subtitle: server?.displayName,
              onTitleTap: () =>
                  showServerSwitcher(context, ref, currentServerId: serverId),
              actions: [
                AppIconButton(
                  icon: TablerIcons.refresh,
                  tooltip: l10n.action_refresh,
                  onPressed: () => _refresh(ref),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refresh(ref),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    context.pagePadding,
                    AppTokens.s8,
                    context.pagePadding,
                    AppTokens.bottomNavClearance +
                        MediaQuery.paddingOf(context).bottom,
                  ),
                  children: [
                    _DockerCard(
                      serverId: serverId,
                      onRetry: () => _refresh(ref),
                    ),
                    const SizedBox(height: AppTokens.s16),
                    _ResourcesCard(
                      serverId: serverId,
                      onRetry: () => _refresh(ref),
                    ),
                    const SizedBox(height: AppTokens.s16),
                    _DiskCard(onRetry: () => _refresh(ref)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockerCard extends ConsumerWidget {
  const _DockerCard({required this.serverId, required this.onRetry});

  final int serverId;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final docker = ref.watch(dockerStatusProvider);
    final daemon = ref.watch(dockerDaemonConfigProvider);
    return _asyncBody(
      docker,
      (status) => _asyncBody(
        daemon,
        (config) => _DockerBody(
          serverId: serverId,
          status: status,
          version: config.version,
          onRefresh: onRetry,
        ),
        skeleton: const _DockerSkeleton(),
        onError: (_) => _DockerBody(
          serverId: serverId,
          status: status,
          version: '',
          onRefresh: onRetry,
        ),
      ),
      skeleton: const _DockerSkeleton(),
      onError: (error) =>
          _ErrorCard(message: describeError(error, l10n), onRetry: onRetry),
    );
  }
}

class _DockerBody extends StatelessWidget {
  const _DockerBody({
    required this.serverId,
    required this.status,
    required this.version,
    required this.onRefresh,
  });

  final int serverId;
  final DockerStatusDto status;
  final String version;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final running = status.isAvailable;
    final dockerVersion = version.trim();
    return TonalCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTokens.rMd),
            ),
            child: Icon(
              TablerIcons.brand_docker,
              color: colors.info,
              size: AppTokens.iconNav,
            ),
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Docker', style: AppTextStyles.titleM),
                const SizedBox(height: AppTokens.s4),
                Text(
                  dockerVersion.isEmpty
                      ? l10n.containers_dockerService
                      : 'v$dockerVersion',
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.s8),
          _StatusPill(
            label: running ? l10n.containers_running : l10n.containers_stopped,
            color: running ? colors.success : colors.warning,
          ),
          IconButton(
            tooltip: l10n.containers_dockerSettings,
            onPressed: () => context.push('/s/$serverId/containers/docker'),
            icon: const Icon(TablerIcons.settings),
          ),
        ],
      ),
    );
  }
}

class _ResourcesCard extends ConsumerWidget {
  const _ResourcesCard({required this.serverId, required this.onRetry});

  final int serverId;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(containerStatusProvider);
    return _asyncBody(
      status,
      (data) => _ResourcesBody(serverId: serverId, status: data),
      skeleton: const _ResourcesSkeleton(),
      onError: (error) =>
          _ErrorCard(message: describeError(error, l10n), onRetry: onRetry),
    );
  }
}

class _ResourcesBody extends StatelessWidget {
  const _ResourcesBody({required this.serverId, required this.status});

  final int serverId;
  final ContainerStatusDto status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = <_OverviewRowData>[
      _OverviewRowData(
        icon: TablerIcons.box,
        title: l10n.containers_usageContainers,
        value: '${status.containerCount}',
        note: l10n.containers_overview_runningCount(status.running),
        onTap: () => context.push('/s/$serverId/containers/list'),
      ),
      _OverviewRowData(
        icon: TablerIcons.stack_2,
        title: l10n.containers_compose,
        value: '${status.composeCount}',
        onTap: () => context.push('/s/$serverId/more/compose'),
      ),
      _OverviewRowData(
        icon: TablerIcons.template,
        title: l10n.containers_composeTemplates,
        value: '${status.composeTemplateCount}',
        onTap: () => context.push('/s/$serverId/more/compose?templates=1'),
      ),
      _OverviewRowData(
        icon: TablerIcons.photo,
        title: l10n.containers_images,
        value: '${status.imageCount}',
        onTap: () => context.push('/s/$serverId/containers/images'),
      ),
      _OverviewRowData(
        icon: TablerIcons.database,
        title: l10n.containers_imageRepos,
        value: '${status.repoCount}',
        onTap: () => context.push('/s/$serverId/containers/repos'),
      ),
      _OverviewRowData(
        icon: TablerIcons.network,
        title: l10n.nav_network,
        value: '${status.networkCount}',
        onTap: () => context.push('/s/$serverId/containers/networks'),
      ),
      _OverviewRowData(
        icon: TablerIcons.database,
        title: l10n.containers_storageVolumes,
        value: '${status.volumeCount}',
        onTap: () => context.push('/s/$serverId/containers/volumes'),
      ),
    ];
    return TonalCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s12,
              AppTokens.s16,
              AppTokens.s4,
            ),
            child: Text(
              l10n.containers_overview_resources,
              style: AppTextStyles.caption.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
          for (var index = 0; index < rows.length; index++) ...[
            _OverviewRow(data: rows[index]),
            if (index < rows.length - 1)
              Divider(
                height: 1,
                indent: AppTokens.s48,
                color: context.scheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _OverviewRowData {
  const _OverviewRowData({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.note,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? note;
  final VoidCallback onTap;
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.data});

  final _OverviewRowData data;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s12,
          AppTokens.s12,
          AppTokens.s12,
        ),
        child: Row(
          children: [
            Icon(
              data.icon,
              size: AppTokens.iconList,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppTokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: AppTextStyles.bodyM),
                  if (data.note != null)
                    Text(
                      data.note!,
                      style: AppTextStyles.caption.copyWith(
                        color: context.appColors.success,
                      ),
                    ),
                ],
              ),
            ),
            Text(data.value, style: AppTextStyles.bodyM),
            const SizedBox(width: AppTokens.s4),
            Icon(
              TablerIcons.chevron_right,
              size: AppTokens.iconList,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiskCard extends ConsumerWidget {
  const _DiskCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(containerItemStatsProvider);
    return _asyncBody(
      stats,
      (data) =>
          data == null ? const _DiskUnavailable() : _DiskBody(stats: data),
      skeleton: const _DiskSkeleton(),
      onError: (_) => const _DiskUnavailable(),
    );
  }
}

class _DiskBody extends StatelessWidget {
  const _DiskBody({required this.stats});

  final ContainerItemStatsDto stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = <(String, int, int)>[
      (l10n.containers_usageImages, stats.imageUsage, stats.imageReclaimable),
      (
        l10n.containers_usageContainers,
        stats.containerUsage,
        stats.containerReclaimable,
      ),
      (
        l10n.containers_usageVolumes,
        stats.volumeUsage,
        stats.volumeReclaimable,
      ),
      (
        l10n.containers_usageBuildCache,
        stats.buildCacheUsage,
        stats.buildCacheReclaimable,
      ),
    ];
    return TonalCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s12,
              AppTokens.s16,
              AppTokens.s4,
            ),
            child: Text(
              l10n.containers_diskUsage,
              style: AppTextStyles.caption.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
          for (var index = 0; index < rows.length; index++) ...[
            _DiskRow(
              title: rows[index].$1,
              usage: rows[index].$2,
              reclaimable: rows[index].$3,
            ),
            if (index < rows.length - 1)
              Divider(
                height: 1,
                indent: AppTokens.s16,
                color: context.scheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _DiskRow extends StatelessWidget {
  const _DiskRow({
    required this.title,
    required this.usage,
    required this.reclaimable,
  });

  final String title;
  final int usage;
  final int reclaimable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: AppTokens.s12,
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.bodyM)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatBytes(usage), style: AppTextStyles.bodyM),
              if (reclaimable > 0)
                Text(
                  l10n.containers_overview_reclaimable(
                    formatBytes(reclaimable),
                  ),
                  style: AppTextStyles.caption.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: AppTokens.s4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppTokens.s4),
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TonalCard(
      child: Row(
        children: [
          Icon(
            TablerIcons.alert_triangle,
            color: context.appColors.warning,
            size: AppTokens.iconList,
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(child: Text(message, style: AppTextStyles.bodyS)),
          TextButton(onPressed: onRetry, child: Text(l10n.action_retry)),
        ],
      ),
    );
  }
}

Widget _asyncBody<T>(
  AsyncValue<T> value,
  Widget Function(T data) build, {
  required Widget skeleton,
  required Widget Function(Object error) onError,
}) {
  if (value.hasValue) return build(value.value as T);
  if (value.hasError) return onError(value.error!);
  return skeleton;
}

Widget _bar(
  BuildContext context, {
  required double width,
  required double height,
  double radius = 3,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: context.scheme.onSurfaceVariant.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class _DockerSkeleton extends StatelessWidget {
  const _DockerSkeleton();

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      child: Row(
        children: [
          _bar(context, width: 44, height: 44, radius: AppTokens.rMd),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(context, width: 64, height: 18),
                const SizedBox(height: AppTokens.s4),
                _bar(context, width: 44, height: 14),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.s8),
          _bar(context, width: 56, height: 24, radius: AppTokens.rFull),
          const SizedBox(width: AppTokens.s8),
          _bar(context, width: 48, height: 48, radius: AppTokens.rFull),
        ],
      ),
    );
  }
}

class _ResourcesSkeleton extends StatelessWidget {
  const _ResourcesSkeleton();

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s12,
              AppTokens.s16,
              AppTokens.s4,
            ),
            child: _bar(context, width: 48, height: 16),
          ),
          for (var index = 0; index < 7; index++) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s16,
                AppTokens.s12,
                AppTokens.s12,
                AppTokens.s12,
              ),
              child: Row(
                children: [
                  _bar(
                    context,
                    width: AppTokens.iconList,
                    height: AppTokens.iconList,
                    radius: 4,
                  ),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bar(context, width: double.infinity, height: 21),
                        if (index == 0) ...[
                          const SizedBox(height: 2),
                          _bar(context, width: 64, height: 16),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  _bar(context, width: 28, height: 21),
                  const SizedBox(width: AppTokens.s4),
                  _bar(
                    context,
                    width: AppTokens.iconList,
                    height: AppTokens.iconList,
                    radius: 4,
                  ),
                ],
              ),
            ),
            if (index < 6)
              Divider(
                height: 1,
                indent: AppTokens.s48,
                color: context.scheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _DiskSkeleton extends StatelessWidget {
  const _DiskSkeleton();

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s12,
              AppTokens.s16,
              AppTokens.s4,
            ),
            child: _bar(context, width: 72, height: 16),
          ),
          for (var index = 0; index < 4; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.s16,
                vertical: AppTokens.s12,
              ),
              child: Row(
                children: [
                  Expanded(child: _bar(context, width: 72, height: 21)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar(context, width: 56, height: 21),
                      _bar(context, width: 72, height: 16),
                    ],
                  ),
                ],
              ),
            ),
            if (index < 3)
              Divider(
                height: 1,
                indent: AppTokens.s16,
                color: context.scheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _DiskUnavailable extends StatelessWidget {
  const _DiskUnavailable();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TonalCard(
      child: Row(
        children: [
          Icon(
            TablerIcons.database_off,
            color: context.scheme.onSurfaceVariant,
            size: AppTokens.iconList,
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Text(
              l10n.containers_diskStatsUnsupported,
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
