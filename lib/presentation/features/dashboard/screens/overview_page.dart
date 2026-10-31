import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../common/charts/area_chart.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/metric_card.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/server_switcher_sheet.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/error_mapper.dart';
import '../../../common/states/error_state.dart';
import '../../servers/providers/servers_provider.dart';
import '../providers/overview_provider.dart';
import '../utils/dashboard_health.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage>
    with WidgetsBindingObserver {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setVisible(true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setVisible(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _setVisible(false);
    }
  }

  void _setVisible(bool visible) {
    if (!mounted || _visible == visible) return;
    _visible = visible;
    ref.read(overviewProvider(widget.serverId).notifier).setVisible(visible);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final server = ref.watch(serverByIdProvider(widget.serverId)).valueOrNull;
    final overview = ref.watch(overviewProvider(widget.serverId));

    return Scaffold(
      body: VisibilityDetector(
        key: Key('overview-${widget.serverId}'),
        onVisibilityChanged: (info) => _setVisible(info.visibleFraction > 0.5),
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(overviewProvider(widget.serverId).notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBarLarge(
                title: server?.displayName ?? l10n.nav_overview,
                subtitle: server == null
                    ? null
                    : '${server.host}:${server.port}',
                onTitleLongPress: () => showServerSwitcher(
                  context,
                  ref,
                  currentServerId: widget.serverId,
                ),
                actions: [
                  AppIconButton(
                    icon: TablerIcons.terminal_2,
                    tooltip: l10n.dashboard_terminal,
                    onPressed: () =>
                        context.push('/s/${widget.serverId}/terminal'),
                  ),
                  AppIconButton(
                    icon: TablerIcons.refresh,
                    tooltip: l10n.action_refresh,
                    onPressed: () => ref
                        .read(overviewProvider(widget.serverId).notifier)
                        .refresh(),
                  ),
                ],
              ),
              ...overview.when(
                skipLoadingOnRefresh: true,
                loading: () => [
                  const SliverToBoxAdapter(
                    child: SkeletonShimmer(
                      child: Padding(
                        padding: EdgeInsets.all(AppTokens.s16),
                        child: Column(
                          children: [
                            SkeletonCard(height: 148),
                            SizedBox(height: AppTokens.s12),
                            Row(
                              children: [
                                Expanded(child: SkeletonCard(height: 124)),
                                SizedBox(width: AppTokens.s12),
                                Expanded(child: SkeletonCard(height: 124)),
                              ],
                            ),
                            SizedBox(height: AppTokens.s12),
                            SkeletonCard(height: 180),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                error: (error, stack) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorState(
                      data: mapError(error, l10n),
                      onRetry: () => ref
                          .read(overviewProvider(widget.serverId).notifier)
                          .refresh(),
                    ),
                  ),
                ],
                data: (state) => _content(context, l10n, state),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppTokens.s40)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    AppLocalizations l10n,
    OverviewState state,
  ) {
    final scheme = context.scheme;
    final dashboard = state.dashboard;
    final current = dashboard.current;
    final base = dashboard.base;
    final diskPercent = current.disks.isEmpty
        ? 0.0
        : current.disks
              .map((d) => d.usedPercent)
              .reduce((a, b) => a > b ? a : b);
    final cores = base.cpuLogicalCores > 0
        ? base.cpuLogicalCores
        : base.cpuCores;
    final score = healthScore(
      cpuPercent: current.cpuUsedPercent,
      memoryPercent: current.memoryUsedPercent,
      diskPercent: diskPercent,
      load1: current.load1,
      cores: cores,
    );
    final netDown = state.netDownHistory.isEmpty
        ? 0.0
        : state.netDownHistory.last;
    final busiestDisk = current.disks.isEmpty
        ? null
        : current.disks.reduce(
            (a, b) => a.usedPercent >= b.usedPercent ? a : b,
          );
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s8,
          AppTokens.s16,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              if (state.stale)
                _OfflineBanner(
                  message: l10n.dashboard_offline_banner,
                  lastUpdated: state.lastUpdated,
                ),
              TonalCard(
                padding: const EdgeInsets.all(AppTokens.s20),
                child: Row(
                  children: [
                    MetricRing(
                      value: score,
                      label: l10n.dashboard_health,
                      size: 96,
                      strokeWidth: 10,
                      color: score >= 70
                          ? context.appColors.success
                          : score >= 50
                          ? context.appColors.warning
                          : context.appColors.danger,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            score.toStringAsFixed(0),
                            style: AppTextStyles.numericLarge.copyWith(
                              fontSize: 26,
                            ),
                          ),
                          Text(
                            healthLabel(score, l10n),
                            style: AppTextStyles.caption.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTokens.s20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            base.hostname.isEmpty
                                ? l10n.dashboard_health
                                : base.hostname,
                            style: AppTextStyles.titleM,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTokens.s4),
                          Text(
                            [
                              base.prettyDistro,
                              base.kernelVersion,
                            ].where((e) => e.isNotEmpty).join(' · '),
                            style: AppTextStyles.bodyS.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTokens.s12),
                          Wrap(
                            spacing: AppTokens.s8,
                            runSpacing: AppTokens.s8,
                            children: [
                              _Pill(
                                label:
                                    '${l10n.dashboard_load} ${current.load1.toStringAsFixed(2)}',
                              ),
                              _Pill(
                                label:
                                    '${l10n.dashboard_processes} ${current.procs}',
                              ),
                              _Pill(
                                label:
                                    '${l10n.dashboard_uptime} ${formatUptime(current.uptimeSeconds, l10n)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(AppTokens.s16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppTokens.s12,
            crossAxisSpacing: AppTokens.s12,
            mainAxisExtent: 136 + (textScale - 1) * 80,
          ),
          delegate: SliverChildListDelegate.fixed([
            MetricCard(
              title: l10n.dashboard_cpu,
              value: current.cpuUsedPercent.toStringAsFixed(1),
              unit: '%',
              caption: l10n.dashboard_cores(cores),
              status: current.cpuUsedPercent > 90 ? 'error' : 'running',
              sparkline: Sparkline(values: state.cpuHistory, maxValue: 100),
              onTap: () => _showCoreUsage(context, current.cpuDetailedPercent),
              onLongPress: () => _copy(context, current.cpuUsedPercent),
            ),
            MetricCard(
              title: l10n.dashboard_memory,
              value: current.memoryUsedPercent.toStringAsFixed(1),
              unit: '%',
              caption: l10n.dashboard_used_of(
                formatBytes(current.memoryUsed),
                formatBytes(current.memoryTotal),
              ),
              status: current.memoryUsedPercent > 90 ? 'error' : 'running',
              sparkline: Sparkline(values: state.memoryHistory, maxValue: 100),
              onLongPress: () => _copy(context, current.memoryUsedPercent),
            ),
            MetricCard(
              title: l10n.dashboard_disk,
              value: diskPercent.toStringAsFixed(1),
              unit: '%',
              caption: busiestDisk == null
                  ? '${current.disks.length}'
                  : l10n.dashboard_used_of(
                      formatBytes(busiestDisk.used),
                      formatBytes(busiestDisk.total),
                    ),
              status: diskPercent > 90 ? 'error' : 'running',
              onLongPress: () => _copy(context, diskPercent),
            ),
            MetricCard(
              title: l10n.dashboard_network,
              value: formatByteRate(netDown),
              caption: l10n.dashboard_trafficTotal(
                formatBytes(current.netBytesRecv + current.netBytesSent),
              ),
              status: 'running',
              sparkline: Sparkline(values: state.netDownHistory),
              onLongPress: () => _copy(context, formatByteRate(netDown)),
            ),
          ]),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
        sliver: SliverToBoxAdapter(
          child: TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.dashboard_network,
                        style: AppTextStyles.titleM,
                      ),
                    ),
                    _Legend(
                      color: context.appColors.chart1,
                      label: l10n.dashboard_download,
                    ),
                    const SizedBox(width: AppTokens.s12),
                    _Legend(
                      color: context.appColors.chart2,
                      label: l10n.dashboard_upload,
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s16),
                SizedBox(
                  height: 160,
                  child: AreaChart(
                    seriesA: state.netDownHistory,
                    seriesB: state.netUpHistory,
                    colorA: context.appColors.chart1,
                    colorB: context.appColors.chart2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s24,
          AppTokens.s16,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: l10n.dashboard_system_info),
              SplitListGroup(
                children: [
                  _InfoRow(label: l10n.servers_host, value: base.hostname),
                  _InfoRow(
                    label: l10n.dashboard_system,
                    value: base.prettyDistro,
                  ),
                  _InfoRow(
                    label: l10n.dashboard_kernel,
                    value: base.kernelVersion,
                  ),
                  _InfoRow(label: l10n.dashboard_arch, value: base.kernelArch),
                  _InfoRow(label: l10n.dashboard_cpu, value: base.cpuModelName),
                  _InfoRow(label: l10n.dashboard_cpuCores, value: '$cores'),
                  _InfoRow(
                    label: l10n.dashboard_load,
                    value:
                        '${current.load1.toStringAsFixed(2)} / ${current.load5.toStringAsFixed(2)} / ${current.load15.toStringAsFixed(2)}',
                  ),
                  _InfoRow(
                    label: l10n.dashboard_uptime,
                    value: formatUptime(current.uptimeSeconds, l10n),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s24,
          AppTokens.s16,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: l10n.dashboard_sites_containers),
              SplitListGroup(
                children: [
                  SplitListTile(
                    leading: const Icon(TablerIcons.world),
                    title: l10n.nav_websites,
                    subtitle: '${base.websiteNumber}',
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => context.go('/s/${widget.serverId}/websites'),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.database),
                    title: l10n.more_databases,
                    subtitle: '${base.databaseNumber}',
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () =>
                        context.go('/s/${widget.serverId}/more/databases'),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.clock),
                    title: l10n.more_cronjobs,
                    subtitle: '${base.cronjobNumber}',
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () =>
                        context.go('/s/${widget.serverId}/more/cronjobs'),
                  ),
                  SplitListTile(
                    leading: const Icon(TablerIcons.apps),
                    title: l10n.more_installed_apps,
                    subtitle: '${base.appInstalledNumber}',
                    trailing: const Icon(TablerIcons.chevron_right),
                    onTap: () => context.go('/s/${widget.serverId}/more/apps'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s16,
          AppTokens.s24,
          AppTokens.s16,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: l10n.dashboard_quick_actions),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppTokens.s12,
                  crossAxisSpacing: AppTokens.s12,
                  mainAxisExtent: 88 + (textScale - 1) * 40,
                ),
                children: [
                  _QuickAction(
                    icon: TablerIcons.database,
                    label: l10n.more_databases,
                    onTap: () =>
                        context.push('/s/${widget.serverId}/more/databases'),
                  ),
                  _QuickAction(
                    icon: TablerIcons.eraser,
                    label: l10n.dashboard_clear_cache,
                    onTap: () {
                      PaintingBinding.instance.imageCache.clear();
                      PaintingBinding.instance.imageCache.clearLiveImages();
                      AppToast.success(context, l10n.dashboard_clear_cache);
                    },
                  ),
                  _QuickAction(
                    icon: TablerIcons.file_text,
                    label: l10n.dashboard_view_logs,
                    onTap: () =>
                        context.push('/s/${widget.serverId}/more/logs'),
                  ),
                  _QuickAction(
                    icon: TablerIcons.terminal_2,
                    label: l10n.dashboard_terminal,
                    onTap: () => context.push('/s/${widget.serverId}/terminal'),
                  ),
                  _QuickAction(
                    icon: TablerIcons.cloud_upload,
                    label: l10n.more_backups,
                    onTap: () =>
                        context.push('/s/${widget.serverId}/more/backups'),
                  ),
                  _QuickAction(
                    icon: TablerIcons.shield,
                    label: l10n.dashboard_firewall,
                    onTap: () =>
                        context.push('/s/${widget.serverId}/more/firewall'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Future<void> _showCoreUsage(BuildContext context, List<double> cores) {
    final l10n = AppLocalizations.of(context);
    return showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dashboard_coreUsage, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s16),
          if (cores.isEmpty)
            Text(l10n.dashboard_noCoreData)
          else
            for (var i = 0; i < cores.length; i++) ...[
              Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text('CPU $i', style: AppTextStyles.caption),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTokens.rFull),
                      child: LinearProgressIndicator(
                        value: (cores[i] / 100).clamp(0, 1).toDouble(),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.s8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${cores[i].toStringAsFixed(0)}%',
                      textAlign: TextAlign.end,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.s8),
            ],
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }

  void _copy(BuildContext context, Object value) {
    Clipboard.setData(ClipboardData(text: '$value'));
    AppToast.show(context, '$value');
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.message, required this.lastUpdated});

  final String message;
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppTokens.s12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s12,
        vertical: AppTokens.s8,
      ),
      decoration: BoxDecoration(
        color: context.appColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.rMd),
      ),
      child: Row(
        children: [
          Icon(
            TablerIcons.wifi_off,
            size: AppTokens.iconList,
            color: context.appColors.warning,
          ),
          const SizedBox(width: AppTokens.s8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyS.copyWith(
                color: context.appColors.warning,
              ),
            ),
          ),
          Text(
            '${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}',
            style: AppTextStyles.caption.copyWith(
              color: context.appColors.warning,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: AppTokens.s4,
      ),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTokens.rFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: context.scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: AppTokens.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: AppTextStyles.bodyS.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: AppTextStyles.bodyM.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return TonalCard(
      padding: const EdgeInsets.all(AppTokens.s8),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppTokens.iconNav, color: scheme.primary),
          const SizedBox(height: AppTokens.s8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
