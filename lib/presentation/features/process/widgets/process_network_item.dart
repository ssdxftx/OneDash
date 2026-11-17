import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/tokens.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/tonal_card.dart';
import 'process_list_item.dart';

class ProcessNetworkItem extends StatelessWidget {
  const ProcessNetworkItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.detailLabel,
  });

  final Map<String, dynamic> item;
  final VoidCallback? onTap;
  final String detailLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final pid = processInt(item['PID'] ?? item['pid']);
    final name = processText(item['name'] ?? item['Name'], '');
    final type = processText(item['type'], 'unknown');
    final status = processText(item['status'], '');
    final local = _formatAddress(item['localaddr']);
    final remote = _formatAddress(item['remoteaddr']);

    return TonalCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NetworkTypeBadge(type: type),
              if (status.isNotEmpty) ...[
                const SizedBox(width: AppTokens.s8),
                _NetworkStatusBadge(status: status),
              ],
              const Spacer(),
              if (pid > 0)
                Text(
                  'PID $pid',
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              if (onTap != null) ...[
                const SizedBox(width: AppTokens.s4),
                Icon(
                  TablerIcons.chevron_right,
                  size: AppTokens.iconList,
                  color: scheme.onSurfaceVariant,
                  semanticLabel: detailLabel,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Row(
            children: [
              Expanded(
                child: Text(
                  local,
                  style: AppTextStyles.mono.copyWith(color: scheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8),
                child: Icon(
                  TablerIcons.arrow_right,
                  size: AppTokens.iconMicro,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: Text(
                  remote,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.mono.copyWith(color: scheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: AppTokens.s4),
            Text(
              name,
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  static String _formatAddress(Object? address) {
    if (address == null) return '--';
    if (address is Map) {
      final ip = '${address['ip'] ?? ''}';
      final port = '${address['port'] ?? ''}';
      if (ip.isEmpty && port.isEmpty) return '--';
      return '$ip:$port';
    }
    final text = '$address';
    return text.isEmpty ? '--' : text;
  }
}

class _NetworkTypeBadge extends StatelessWidget {
  const _NetworkTypeBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type.toLowerCase()) {
      'tcp' || 'tcp4' => context.appColors.info,
      'tcp6' => context.appColors.chart4,
      'udp' || 'udp4' => context.appColors.warning,
      'udp6' => context.appColors.chart3,
      _ => context.appColors.neutral,
    };
    return StatusPill(label: type, tone: color, dense: true);
  }
}

class _NetworkStatusBadge extends StatelessWidget {
  const _NetworkStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toUpperCase()) {
      'LISTEN' => context.appColors.success,
      'ESTABLISHED' => context.appColors.info,
      'TIME_WAIT' => context.appColors.neutral,
      'CLOSE_WAIT' || 'NONE' => context.appColors.danger,
      _ => context.appColors.neutral,
    };
    return StatusPill(label: status, tone: color, dense: true);
  }
}
