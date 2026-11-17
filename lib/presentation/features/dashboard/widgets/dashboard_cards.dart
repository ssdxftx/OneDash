import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../domain/entities/dashboard.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/tonal_card.dart';
import '../providers/overview_provider.dart';
import '../utils/dashboard_health.dart';

List<Widget> buildDashboardCards({
  required BuildContext context,
  required AppLocalizations l10n,
  required Dashboard dashboard,
  required OverviewState state,
}) {
  final current = dashboard.current;
  final disk = _primaryDisk(current.disks);
  return [
    RepaintBoundary(
      child: _ServerHeaderCard(dashboard: dashboard, state: state),
    ),
    const SizedBox(height: AppTokens.s12),
    RepaintBoundary(
      child: _ResourceCard(current: current, disk: disk),
    ),
    const SizedBox(height: AppTokens.s12),
    RepaintBoundary(child: _NetworkTrafficCard(current: current)),
    const SizedBox(height: AppTokens.s12),
    RepaintBoundary(child: _SpeedChartCard(state: state)),
    const SizedBox(height: AppTokens.s12),
    RepaintBoundary(child: _DiskIoCard(state: state)),
    if (current.disks.isNotEmpty) ...[
      const SizedBox(height: AppTokens.s12),
      RepaintBoundary(child: _DiskUsageCard(disks: current.disks)),
    ],
    const SizedBox(height: AppTokens.s12),
    RepaintBoundary(child: _HostDetailsCard(base: dashboard.base)),
    if (current.topCpuItems.isNotEmpty || current.topMemItems.isNotEmpty) ...[
      const SizedBox(height: AppTokens.s12),
      RepaintBoundary(child: _ProcessCard(current: current)),
    ],
  ];
}

DiskUsage? _primaryDisk(List<DiskUsage> disks) {
  if (disks.isEmpty) return null;
  for (final disk in disks) {
    if (disk.path == '/') return disk;
  }
  return disks.reduce((a, b) => a.usedPercent >= b.usedPercent ? a : b);
}

String _systemSummary(DashboardBase base) {
  final distro = base.prettyDistro.trim();
  final version = base.platformVersion.trim();
  if (distro.isEmpty) return version;
  if (version.isEmpty || distro.contains(version)) return distro;
  if (version.contains(distro)) return version;
  return '$distro · $version';
}

Color _usageColor(BuildContext context, double percent) {
  final colors = context.appColors;
  if (percent >= 85) return colors.danger;
  if (percent >= 60) return colors.warning;
  return colors.success;
}

Widget _panelTitle(
  BuildContext context,
  String title,
  IconData icon,
  Color color, {
  Widget? trailing,
}) {
  return Row(
    children: [
      Icon(icon, size: AppTokens.iconSmall, color: color),
      const SizedBox(width: AppTokens.s8),
      Expanded(
        child: Text(
          title,
          style: AppTextStyles.titleS.copyWith(color: context.scheme.onSurface),
        ),
      ),
      if (trailing != null) trailing,
    ],
  );
}

class _ServerHeaderCard extends StatelessWidget {
  const _ServerHeaderCard({required this.dashboard, required this.state});

  final Dashboard dashboard;
  final OverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final base = dashboard.base;
    final current = dashboard.current;
    final online = !state.stale;
    return TonalCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.appColors.info.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  TablerIcons.server_2,
                  size: 22,
                  color: context.appColors.info,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      base.hostname.isEmpty
                          ? l10n.dashboard_hostDetails
                          : base.hostname,
                      style: AppTextStyles.titleM.copyWith(letterSpacing: -0.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTokens.s4),
                    Text(
                      _systemSummary(base),
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              StatusPill(
                label: online ? l10n.servers_online : l10n.servers_offline,
                tone: online
                    ? context.appColors.success
                    : context.appColors.danger,
                showDot: true,
                minWidth: 76,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s16),
          Divider(height: 1, color: scheme.outlineVariant),
          const SizedBox(height: AppTokens.s16),
          _HeaderMetrics(
            metrics: [
              (
                icon: TablerIcons.clock,
                label: l10n.dashboard_uptime,
                value: formatUptime(current.uptimeSeconds, l10n),
              ),
              (
                icon: TablerIcons.activity,
                label: l10n.dashboard_load,
                value:
                    '${current.load1.toStringAsFixed(2)}/${current.load5.toStringAsFixed(2)}/${current.load15.toStringAsFixed(2)}',
              ),
              (
                icon: TablerIcons.cpu,
                label: l10n.dashboard_processes,
                value: '${current.procs}',
              ),
              (
                icon: TablerIcons.topology_star,
                label: l10n.dashboard_arch,
                value: base.kernelArch.isEmpty ? '-' : base.kernelArch,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.alignment,
  });

  final IconData icon;
  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppTokens.iconMicro,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: switch (alignment) {
            CrossAxisAlignment.end => Alignment.centerRight,
            CrossAxisAlignment.center => Alignment.center,
            _ => Alignment.centerLeft,
          },
          child: Text(
            value,
            maxLines: 1,
            style: AppTextStyles.bodyM.copyWith(
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
            textAlign: switch (alignment) {
              CrossAxisAlignment.end => TextAlign.end,
              CrossAxisAlignment.center => TextAlign.center,
              _ => TextAlign.start,
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderMetrics extends StatelessWidget {
  const _HeaderMetrics({required this.metrics});

  final List<({IconData icon, String label, String value})> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 480 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.15;
        if (!stacked) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < metrics.length; index++)
                Expanded(
                  child: _HeaderMetric(
                    icon: metrics[index].icon,
                    label: metrics[index].label,
                    value: metrics[index].value,
                    alignment: switch (index) {
                      0 => CrossAxisAlignment.start,
                      _ when index == metrics.length - 1 =>
                        CrossAxisAlignment.end,
                      _ => CrossAxisAlignment.center,
                    },
                  ),
                ),
            ],
          );
        }
        return Column(
          children: [
            _HeaderMetricRow(left: metrics[0], right: metrics[1]),
            const SizedBox(height: AppTokens.s16),
            _HeaderMetricRow(left: metrics[2], right: metrics[3]),
          ],
        );
      },
    );
  }
}

class _HeaderMetricRow extends StatelessWidget {
  const _HeaderMetricRow({required this.left, required this.right});

  final ({IconData icon, String label, String value}) left;
  final ({IconData icon, String label, String value}) right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _HeaderMetric(
            icon: left.icon,
            label: left.label,
            value: left.value,
            alignment: CrossAxisAlignment.start,
          ),
        ),
        const SizedBox(width: AppTokens.s16),
        Expanded(
          child: _HeaderMetric(
            icon: right.icon,
            label: right.label,
            value: right.value,
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.current, required this.disk});

  final DashboardCurrent current;
  final DiskUsage? disk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cores = current.cpuTotal > 0
        ? current.cpuTotal
        : current.cpuDetailedPercent.length;
    final rows = <Widget>[
      _ResourceRow(
        icon: TablerIcons.cpu,
        label: l10n.dashboard_cpu,
        color: _usageColor(context, current.cpuUsedPercent),
        value:
            '${current.cpuUsed.toStringAsFixed(2)} / ${l10n.dashboard_cores(cores)}',
        percent: current.cpuUsedPercent,
      ),
      _ResourceRow(
        icon: TablerIcons.device_sd_card,
        label: l10n.dashboard_memory,
        color: _usageColor(context, current.memoryUsedPercent),
        value:
            '${formatBytes(current.memoryUsed)} / ${formatBytes(current.memoryTotal)}',
        percent: current.memoryUsedPercent,
      ),
      if (current.swapMemoryTotal > 0)
        _ResourceRow(
          icon: TablerIcons.arrows_diagonal,
          label: l10n.dashboard_swap,
          color: _usageColor(context, current.swapMemoryUsedPercent),
          value:
              '${formatBytes(current.swapMemoryUsed)} / ${formatBytes(current.swapMemoryTotal)}',
          percent: current.swapMemoryUsedPercent,
        ),
      _ResourceRow(
        icon: TablerIcons.database,
        label: l10n.dashboard_disk,
        color: _usageColor(context, disk?.usedPercent ?? 0),
        value: disk == null
            ? ''
            : '${formatBytes(disk!.used)} / ${formatBytes(disk!.total)}',
        percent: disk?.usedPercent ?? 0,
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
            child: _panelTitle(
              context,
              l10n.dashboard_resourceUsage,
              TablerIcons.cpu,
              context.appColors.success,
            ),
          ),
          for (var index = 0; index < rows.length; index++) ...[
            rows[index],
            if (index < rows.length - 1)
              Divider(
                height: 1,
                indent: 44,
                color: context.scheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({
    required this.icon,
    required this.label,
    required this.color,
    this.value,
    required this.percent,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String? value;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final clamped = percent.clamp(0, 100).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: AppTokens.s8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: AppTokens.iconInline, color: color),
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
                        label,
                        style: AppTextStyles.label.copyWith(height: 1.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTokens.s8),
                    Text(
                      '${clamped.toStringAsFixed(0)}%',
                      style: AppTextStyles.label.copyWith(
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                if (value != null && value!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    value!,
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        color: color.withValues(alpha: 0.12),
                      ),
                      FractionallySizedBox(
                        widthFactor: clamped / 100,
                        child: Container(height: 6, color: color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NodeInfoCard extends StatelessWidget {
  const NodeInfoCard({super.key, required this.node});

  final Map<String, dynamic> node;

  double _num(String key) {
    final value = node[key];
    return value is num ? value.toDouble() : 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cpu = _num('cpuUsedPercent').clamp(0, 100).toDouble();
    final memory = _num('memoryUsedPercent').clamp(0, 100).toDouble();
    return SizedBox(
      width: double.infinity,
      child: TonalCard(
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
              child: _panelTitle(
                context,
                l10n.dashboard_nodeInfo,
                TablerIcons.topology_star,
                context.appColors.chart4,
              ),
            ),
            _ResourceRow(
              icon: TablerIcons.cpu,
              label: l10n.dashboard_cpu,
              color: _usageColor(context, cpu),
              percent: cpu,
            ),
            Divider(
              height: 1,
              indent: 44,
              color: context.scheme.outlineVariant,
            ),
            _ResourceRow(
              icon: TablerIcons.device_sd_card,
              label: l10n.dashboard_memory,
              color: _usageColor(context, memory),
              percent: memory,
            ),
            Divider(
              height: 1,
              indent: 44,
              color: context.scheme.outlineVariant,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s16,
                AppTokens.s12,
                AppTokens.s16,
                AppTokens.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dashboard_load,
                    style: AppTextStyles.caption.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTokens.s8),
                  Row(
                    children: [
                      Expanded(
                        child: _LoadTile(
                          label: '1m',
                          value: _num('load1').toStringAsFixed(2),
                        ),
                      ),
                      const SizedBox(width: AppTokens.s8),
                      Expanded(
                        child: _LoadTile(
                          label: '5m',
                          value: _num('load5').toStringAsFixed(2),
                        ),
                      ),
                      const SizedBox(width: AppTokens.s8),
                      Expanded(
                        child: _LoadTile(
                          label: '15m',
                          value: _num('load15').toStringAsFixed(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadTile extends StatelessWidget {
  const _LoadTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.s8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTokens.rSm),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.titleS.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkTrafficCard extends StatelessWidget {
  const _NetworkTrafficCard({required this.current});

  final DashboardCurrent current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TonalCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s12,
              AppTokens.s16,
              AppTokens.s4,
            ),
            child: _panelTitle(
              context,
              l10n.dashboard_network,
              TablerIcons.activity,
              context.appColors.chart2,
            ),
          ),
          _TrafficRow(
            icon: TablerIcons.arrow_up_right,
            label: l10n.dashboard_upload,
            value: l10n.dashboard_trafficTotal(
              formatBytes(current.netBytesSent),
            ),
            color: context.appColors.success,
          ),
          Divider(height: 1, indent: 44, color: context.scheme.outlineVariant),
          _TrafficRow(
            icon: TablerIcons.arrow_down_left,
            label: l10n.dashboard_download,
            value: l10n.dashboard_trafficTotal(
              formatBytes(current.netBytesRecv),
            ),
            color: context.appColors.chart2,
          ),
        ],
      ),
    );
  }
}

class _TrafficRow extends StatelessWidget {
  const _TrafficRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: AppTokens.iconInline, color: color),
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(height: 1.1),
            ),
          ),
          const SizedBox(width: AppTokens.s8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyM.copyWith(
                height: 1.1,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedChartCard extends StatefulWidget {
  const _SpeedChartCard({required this.state});

  final OverviewState state;

  @override
  State<_SpeedChartCard> createState() => _SpeedChartCardState();
}

class _SpeedChartCardState extends State<_SpeedChartCard>
    with SingleTickerProviderStateMixin {
  final _now = ValueNotifier<DateTime>(DateTime.now());
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => _now.value = DateTime.now())..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _now.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.state;
    final latest = state.speedHistory.isEmpty
        ? SpeedSample(time: _epoch, up: 0, down: 0)
        : state.speedHistory.last;
    final chartScale = _speedScale(state.speedHistory);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _panelTitle(
                  context,
                  l10n.dashboard_realtimeSpeed,
                  TablerIcons.chart_area_line,
                  context.appColors.chart1,
                ),
                const SizedBox(height: AppTokens.s8),
                Wrap(
                  spacing: AppTokens.s16,
                  runSpacing: 6,
                  children: [
                    _LegendItem(
                      icon: TablerIcons.arrow_up_right,
                      label: formatByteRate(latest.up),
                      color: context.appColors.success,
                    ),
                    _LegendItem(
                      icon: TablerIcons.arrow_down_left,
                      label: formatByteRate(latest.down),
                      color: context.appColors.chart2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: Padding(
              padding: const EdgeInsets.only(left: AppTokens.s16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SpeedChartYAxis(
                    scale: chartScale,
                    color: context.scheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  const SizedBox(width: AppTokens.s8),
                  Expanded(
                    child: ValueListenableBuilder<DateTime>(
                      valueListenable: _now,
                      builder: (context, now, _) => CustomPaint(
                        painter: _SpeedChartPainter(
                          samples: state.speedHistory,
                          now: now,
                          upColor: context.appColors.success,
                          downColor: context.appColors.chart2,
                          gridColor: context.scheme.outlineVariant,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s4,
              AppTokens.s16,
              AppTokens.s12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dashboard_chartSecondsAgo(60),
                  style: AppTextStyles.caption.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  l10n.dashboard_chartSecondsAgo(30),
                  style: AppTextStyles.caption.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  l10n.dashboard_chartNow,
                  style: AppTextStyles.caption.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _epoch = DateTime.utc(1970);

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppTokens.iconMicro, color: color),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 132),
          child: Transform.translate(
            offset: const Offset(0, -1),
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: AppTextStyles.caption.copyWith(
                height: 1.1,
                fontWeight: FontWeight.w600,
                color: context.scheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

double _speedScale(List<SpeedSample> samples) {
  var currentMax = 0.0;
  for (final sample in samples) {
    currentMax = math.max(currentMax, math.max(sample.up, sample.down));
  }
  if (currentMax < 2048) return 2048;
  final magnitude = math
      .pow(10, (math.log(currentMax) / math.ln10).floor())
      .toDouble();
  final scale = switch (currentMax / magnitude) {
    <= 1 => 1,
    <= 2 => 2,
    <= 5 => 5,
    _ => 10,
  };
  return magnitude * scale * 1.2;
}

class _SpeedChartYAxis extends StatelessWidget {
  const _SpeedChartYAxis({required this.scale, required this.color});

  final double scale;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const height = 160.0;
    const steps = 4;
    return SizedBox(
      width: 52,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < steps; index++)
            Positioned(
              top: height * index / steps - 6,
              right: 0,
              child: Text(
                formatByteRate(scale * (1 - index / steps)),
                textAlign: TextAlign.end,
                style: AppTextStyles.caption.copyWith(height: 1, color: color),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpeedChartPainter extends CustomPainter {
  _SpeedChartPainter({
    required this.samples,
    required this.now,
    required this.upColor,
    required this.downColor,
    required this.gridColor,
  });

  final List<SpeedSample> samples;
  final DateTime now;
  final Color upColor;
  final Color downColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty || size.width <= 0 || size.height <= 0) return;
    final scale = _speedScale(samples);
    const stepCount = 4;
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var index = 0; index <= stepCount; index++) {
      final y = size.height * index / stepCount;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    _drawSeries(canvas, size, scale, (sample) => sample.up, upColor);
    _drawSeries(canvas, size, scale, (sample) => sample.down, downColor);
  }

  void _drawSeries(
    Canvas canvas,
    Size size,
    double scale,
    double Function(SpeedSample sample) value,
    Color color,
  ) {
    final points = <Offset>[];
    for (final sample in samples) {
      final diff = now.difference(sample.time).inMilliseconds / 1000.0;
      if (diff > 62 || diff < -2) continue;
      final x = (1 - diff / 60) * size.width;
      final y = size.height * (1 - (value(sample) / scale).clamp(0, 1));
      points.add(Offset(x, y));
    }
    if (points.isEmpty) return;

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final last = points[index - 1];
      final point = points[index];
      final controlX = last.dx + (point.dx - last.dx) / 2;
      line.cubicTo(controlX, last.dy, controlX, point.dy, point.dx, point.dy);
    }
    final fill = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SpeedChartPainter oldDelegate) =>
      oldDelegate.samples != samples || oldDelegate.now != now;
}

class _DiskIoCard extends StatelessWidget {
  const _DiskIoCard({required this.state});

  final OverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = <(String, String)>[
      (l10n.dashboard_read, formatByteRate(state.readBytesPerSecond)),
      (l10n.dashboard_write, formatByteRate(state.writeBytesPerSecond)),
      (
        l10n.dashboard_latency,
        l10n.dashboard_latencyValue(state.latencyMs.toStringAsFixed(2)),
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
            child: _panelTitle(
              context,
              l10n.dashboard_diskIo,
              TablerIcons.arrows_down_up,
              context.appColors.warning,
            ),
          ),
          for (var index = 0; index < rows.length; index++) ...[
            _SimpleRow(label: rows[index].$1, value: rows[index].$2),
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

class _DiskUsageCard extends StatelessWidget {
  const _DiskUsageCard({required this.disks});

  final List<DiskUsage> disks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selectDisks(disks);
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
            child: _panelTitle(
              context,
              l10n.dashboard_partitions,
              TablerIcons.database,
              context.appColors.chart5,
            ),
          ),
          for (var index = 0; index < selected.length; index++) ...[
            _DiskUsageRow(disk: selected[index]),
            if (index < selected.length - 1)
              Divider(
                height: 1,
                indent: 44,
                color: context.scheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }

  List<DiskUsage> _selectDisks(List<DiskUsage> source) {
    if (source.length <= 3) return source;
    final result = <DiskUsage>[];
    for (final disk in source) {
      if (disk.path == '/') {
        result.add(disk);
        break;
      }
    }
    for (final disk in source) {
      if (result.length >= 3) break;
      if (result.contains(disk)) continue;
      result.add(disk);
    }
    return result;
  }
}

class _DiskUsageRow extends StatelessWidget {
  const _DiskUsageRow({required this.disk});

  final DiskUsage disk;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final percent = disk.usedPercent.clamp(0, 100).toDouble();
    final color = _usageColor(context, percent);
    final path = disk.path.isEmpty ? disk.device : disk.path;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: AppTokens.s12,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              TablerIcons.database,
              size: AppTokens.iconInline,
              color: color,
            ),
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
                        path,
                        style: AppTextStyles.bodyM.copyWith(
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTokens.s12),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: AppTextStyles.label.copyWith(
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        color: color.withValues(alpha: 0.12),
                      ),
                      FractionallySizedBox(
                        widthFactor: percent / 100,
                        child: Container(height: 6, color: color),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.s8),
                Text(
                  '${formatBytes(disk.used)} / ${formatBytes(disk.total)}',
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HostDetailsCard extends StatelessWidget {
  const _HostDetailsCard({required this.base});

  final DashboardBase base;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final physical = base.cpuCores;
    final logical = base.cpuLogicalCores > 0
        ? base.cpuLogicalCores
        : base.cpuCores;
    final rows = <(String, String)>[
      (
        l10n.dashboard_system,
        base.prettyDistro.isNotEmpty ? base.prettyDistro : base.os,
      ),
      ('IPv4', base.ipV4Addr),
      (
        l10n.dashboard_kernel,
        '${base.kernelVersion} (${base.kernelArch})'.trim(),
      ),
      (l10n.dashboard_cpu, base.cpuModelName),
      (l10n.dashboard_cpuCores, l10n.dashboard_coreThreads(physical, logical)),
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
            child: _panelTitle(
              context,
              l10n.dashboard_hostDetails,
              TablerIcons.server,
              context.scheme.onSurfaceVariant,
            ),
          ),
          for (var index = 0; index < rows.length; index++) ...[
            _ConfigRow(label: rows[index].$1, value: rows[index].$2),
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

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: AppTokens.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyS.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value.trim().isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyM,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessCard extends StatelessWidget {
  const _ProcessCard({required this.current});

  final DashboardCurrent current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cpuItems = current.topCpuItems.take(3).toList();
    final memItems = current.topMemItems.take(3).toList();
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
            child: _panelTitle(
              context,
              l10n.dashboard_processes,
              TablerIcons.list_details,
              context.appColors.chart6,
            ),
          ),
          for (final item in cpuItems)
            _ProcessRow(
              label: item.name.isEmpty ? 'PID ${item.pid}' : item.name,
              value:
                  'CPU ${item.percent.toStringAsFixed(1)} · ${formatBytes(item.memory)}',
            ),
          for (final item in memItems)
            _ProcessRow(
              label: item.name.isEmpty ? 'PID ${item.pid}' : item.name,
              value: 'MEM ${formatBytes(item.memory)} · ${item.user}',
            ),
        ],
      ),
    );
  }
}

class _ProcessRow extends StatelessWidget {
  const _ProcessRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: AppTokens.s8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyS,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppTokens.s12),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: AppTokens.s12,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyM)),
          Text(
            value,
            style: AppTextStyles.bodyM.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
