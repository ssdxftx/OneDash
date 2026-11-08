import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/tokens.dart';

/// 日志时间统一格式：MM-dd HH:mm:ss。
String formatLogTime(DateTime time) {
  final local = time.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
}

/// 34×34 圆角底托 + 18dp 图标，四个日志行共用。
class StatusIconBlock extends StatelessWidget {
  const StatusIconBlock({super.key, required this.tone, required this.icon});

  final Color tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTokens.rXs),
      ),
      child: Icon(icon, size: 18, color: tone),
    );
  }
}

/// 图标 + 小字元信息（归属地 / 设备 / 时间）。
class MetaInfo extends StatelessWidget {
  const MetaInfo({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppTokens.s4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// 中性灰 chip，用于 source / authMode / port 这类非按钮标签。
class SourceChip extends StatelessWidget {
  const SourceChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppTokens.rXs),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

/// 失败原因红字。
class LogErrorText extends StatelessWidget {
  const LogErrorText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.caption.copyWith(color: context.appColors.danger),
    );
  }
}

/// 详情弹层的字段行。
class LogDetailField extends StatelessWidget {
  const LogDetailField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: AppTextStyles.bodyS.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: SelectableText(value, style: AppTextStyles.bodyS)),
        ],
      ),
    );
  }
}

/// 详情弹层头部：标题 + 状态胶囊 + 时间。
class LogDetailHeader extends StatelessWidget {
  const LogDetailHeader({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.tone,
    required this.time,
    this.icon = TablerIcons.clipboard_text,
  });

  final String title;
  final String statusLabel;
  final Color tone;
  final String time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: tone),
            const SizedBox(width: AppTokens.s8),
            Expanded(child: Text(title, style: AppTextStyles.titleL)),
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
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTokens.rXs),
              ),
              child: Text(
                statusLabel,
                style: AppTextStyles.caption.copyWith(
                  color: tone,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppTokens.s8),
            Text(
              time,
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        Divider(height: 1, color: scheme.outlineVariant),
        const SizedBox(height: AppTokens.s16),
      ],
    );
  }
}
