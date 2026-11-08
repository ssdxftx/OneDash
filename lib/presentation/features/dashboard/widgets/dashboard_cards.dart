import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../domain/entities/dashboard.dart';
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
    _ServerHeaderCard(dashboard: dashboard, state: state),
    const SizedBox(height: AppTokens.s12),
    _ResourceCard(current: current, disk: disk),
    const SizedBox(height: AppTokens.s12),
    _NetworkTrafficCard(current: current),
    const SizedBox(height: AppTokens.s12),
    _SpeedChartCard(state: state),
    const SizedBox(height: AppTokens.s12),
    _DiskIoCard(state: state),
    if (current.disks.isNotEmpty) ...[
      const SizedBox(height: AppTokens.s12),
      _DiskUsageCard(disks: current.disks),
    ],
    const SizedBox(height: AppTokens.s12),
    _HostDetailsCard(base: dashboard.base),
    if (current.topCpuItems.isNotEmpty || current.topMemItems.isNotEmpty) ...[
      const SizedBox(height: AppTokens.s12),
      _ProcessCard(current: current),
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
      Icon(icon, size: 16, color: color),
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
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTokens.s4),
                    Text(
                      [
                        base.prettyDistro,
                        base.platformVersion,
                      ].where((item) => item.isNotEmpty).join(' · '),
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
              _StatusPill(online: online),
            ],
          ),
          const SizedBox(height: AppTokens.s16),
          Divider(height: 1, color: scheme.outlineVariant),
          const SizedBox(height: AppTokens.s16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _HeaderMetric(
                  icon: TablerIcons.clock,
                  label: l10n.dashboard_uptime,
                  value: formatUptime(current.uptimeSeconds, l10n),
                  alignment: CrossAxisAlignment.start,
                ),
              ),
              Expanded(
                child: _HeaderMetric(
                  icon: TablerIcons.activity,
                  label: l10n.dashboard_load,
                  value:
                      '${current.load1.toStringAsFixed(2)}/${current.load5.toStringAsFixed(2)}/${current.load15.toStringAsFixed(2)}',
                  alignment: CrossAxisAlignment.center,
                ),
              ),
              Expanded(
                child: _HeaderMetric(
                  icon: TablerIcons.cpu,
                  label: l10n.dashboard_processes,
                  value: '${current.procs}',
                  alignment: CrossAxisAlignment.center,
                ),
              ),
              Expanded(
                child: _HeaderMetric(
                  icon: TablerIcons.topology_star,
                  label: l10n.dashboard_arch,
                  value: base.kernelArch.isEmpty ? '-' : base.kernelArch,
                  alignment: CrossAxisAlignment.end,
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
  const _StatusPill({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = online
        ? context.appColors.success
        : context.appColors.warning;
    return Container(
      width: 68,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.activity_heartbeat, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              online ? l10n.servers_online : l10n.servers_offline,
              style: TextStyle(
                fontSize: 10,
                height: 1,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
            Icon(icon, size: 10, color: scheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: switch (alignment) {
            CrossAxisAlignment.end => TextAlign.end,
            CrossAxisAlignment.center => TextAlign.center,
            _ => TextAlign.start,
          },
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
        color: context.appColors.success,
        value:
            '${current.cpuUsed.toStringAsFixed(2)} / $cores ${cores == 1 ? 'Core' : 'Cores'}',
        percent: current.cpuUsedPercent,
      ),
      _ResourceRow(
        icon: TablerIcons.device_sd_card,
        label: l10n.dashboard_memory,
        color: context.appColors.chart4,
        value:
            '${formatBytes(current.memoryUsed)} / ${formatBytes(current.memoryTotal)}',
        percent: current.memoryUsedPercent,
      ),
      if (current.swapMemoryTotal > 0)
        _ResourceRow(
          icon: TablerIcons.arrows_diagonal,
          label: l10n.dashboard_swap,
          color: context.appColors.warning,
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
    required this.value,
    required this.percent,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String value;
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
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTokens.s8),
                    Flexible(
                      flex: 2,
                      child: Text(
                        value,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
          const SizedBox(width: AppTokens.s12),
          SizedBox(
            width: 38,
            child: Text(
              '${clamped.toStringAsFixed(0)}%',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
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
            value: formatBytes(current.netBytesSent),
            color: context.appColors.success,
          ),
          Divider(height: 1, indent: 44, color: context.scheme.outlineVariant),
          _TrafficRow(
            icon: TablerIcons.arrow_down_left,
            label: l10n.dashboard_download,
            value: formatBytes(current.netBytesRecv),
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
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                height: 1.1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              height: 1.1,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedChartCard extends StatelessWidget {
  const _SpeedChartCard({required this.state});

  final OverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final latest = state.speedHistory.isEmpty
        ? SpeedSample(time: _epoch, up: 0, down: 0)
        : state.speedHistory.last;
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
              l10n.dashboard_realtimeSpeed,
              TablerIcons.chart_area_line,
              context.appColors.chart1,
              trailing: Wrap(
                spacing: AppTokens.s12,
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
            ),
          ),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _SpeedChartPainter(
                samples: state.speedHistory,
                now: state.lastUpdated,
                upColor: context.appColors.success,
                downColor: context.appColors.chart2,
                gridColor: context.scheme.outlineVariant,
                labelColor: context.scheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
              child: const SizedBox.expand(),
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
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        SizedBox(
          width: 78,
          child: Transform.translate(
            offset: const Offset(0, -1),
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
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

class _SpeedChartPainter extends CustomPainter {
  _SpeedChartPainter({
    required this.samples,
    required this.now,
    required this.upColor,
    required this.downColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<SpeedSample> samples;
  final DateTime now;
  final Color upColor;
  final Color downColor;
  final Color gridColor;
  final Color labelColor;

  double _maxScale() {
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

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty || size.width <= 0 || size.height <= 0) return;
    final scale = _maxScale();
    const stepCount = 4;
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var index = 0; index <= stepCount; index++) {
      final y = size.height * index / stepCount;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      final value = scale * (1 - index / stepCount);
      final text = TextPainter(
        text: TextSpan(
          text: formatByteRate(value),
          style: TextStyle(fontSize: 10, height: 1, color: labelColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(16, y + 6));
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
      final diff = now.difference(sample.time).inSeconds;
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
            child: Icon(TablerIcons.database, size: 18, color: color),
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
                        style: const TextStyle(
                          fontSize: 14,
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
                      style: const TextStyle(
                        fontSize: 13,
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
              style: const TextStyle(fontSize: 14, height: 1.4),
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
