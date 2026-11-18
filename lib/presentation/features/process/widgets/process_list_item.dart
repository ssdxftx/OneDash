import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/tonal_card.dart';

int processInt(Object? value) {
  if (value is int) return value;
  return int.tryParse('${value ?? ''}') ?? 0;
}

double processDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}') ?? 0;
}

String processText(Object? value, [String fallback = '--']) {
  final text = '${value ?? ''}'.trim();
  return text.isEmpty ? fallback : text;
}

String processStatusTone(String status) {
  return switch (status.toLowerCase()) {
    'running' => 'running',
    'sleep' || 'sleeping' || 'idle' => 'stopped',
    'zombie' || 'dead' => 'error',
    'wait' || 'waiting' || 'lock' => 'warning',
    _ => status,
  };
}

class ProcessListItem extends StatelessWidget {
  const ProcessListItem({super.key, required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final colors = context.appColors;
    final pid = processText(item['PID'] ?? item['pid']);
    final name = processText(item['name'] ?? item['Name'], 'PID $pid');
    final status = processText(item['status'], '');
    final cpuPercent = processText(item['cpuPercent'], '0%');
    final cpuValue = processDouble(item['cpuValue']);
    final rss = processText(item['rss'], '-');
    final rssValue = processDouble(item['rssValue']);
    final username = processText(item['username'], '');
    final threads = processInt(item['numThreads']);
    final connections = processInt(item['numConnections']);
    final statusTone = processStatusTone(status);
    final statusColor = context.appColors.status(statusTone);
    final meta = <Widget>[
      if (username.isNotEmpty)
        _ProcessMetaChip(
          icon: TablerIcons.user,
          label: username,
          color: colors.chart2,
        ),
      if (threads > 0)
        _ProcessMetaChip(
          icon: TablerIcons.stack_2,
          label: l10n.process_threads(threads),
          color: colors.chart4,
        ),
      if (connections > 0)
        _ProcessMetaChip(
          icon: TablerIcons.plug,
          label: l10n.process_connections(connections),
          color: colors.chart5,
        ),
    ];

    return TonalCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: AppTokens.toneSurface),
                  borderRadius: BorderRadius.circular(AppTokens.rSm),
                ),
                child: Icon(
                  TablerIcons.terminal_2,
                  size: AppTokens.iconList,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: AppTokens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.titleS,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PID $pid',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (status.isNotEmpty) ...[
                const SizedBox(width: AppTokens.s8),
                _ProcessStatusPill(label: status, color: statusColor),
              ],
              const SizedBox(width: AppTokens.s4),
              Icon(
                TablerIcons.chevron_right,
                size: AppTokens.iconList,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s12),
          Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppTokens.s12),
          _ProcessMetricBar(
            label: 'CPU',
            value: cpuPercent,
            progress: (cpuValue / 100).clamp(0, 1).toDouble(),
            color: colors.chart1,
          ),
          const SizedBox(height: AppTokens.s8),
          _ProcessMetricBar(
            label: l10n.process_memory,
            value: rss,
            progress: (rssValue / (1024 * 1024 * 1024)).clamp(0, 1).toDouble(),
            color: colors.chart3,
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: AppTokens.s12),
            Wrap(
              spacing: AppTokens.s8,
              runSpacing: AppTokens.s4,
              children: meta,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProcessStatusPill extends StatelessWidget {
  const _ProcessStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppTokens.toneSurface),
        borderRadius: BorderRadius.circular(AppTokens.rXs),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProcessMetaChip extends StatelessWidget {
  const _ProcessMetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
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
        color: context.scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTokens.rXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTokens.iconMicro, color: color),
          const SizedBox(width: AppTokens.s4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessMetricBar extends StatelessWidget {
  const _ProcessMetricBar({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 46,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppTokens.s8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.rTrack),
            child: Stack(
              children: [
                Container(
                  height: 5,
                  color: color.withValues(alpha: AppTokens.toneSurface),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0, 1).toDouble(),
                  child: Container(height: 5, color: color),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppTokens.s8),
        SizedBox(
          width: 64,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.caption.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
