import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

/// 只读状态胶囊：成功/失败、执行中一类的一句话状态。
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.tone,
    this.dense = false,
    this.showDot = false,
    this.minWidth,
  });

  final String label;
  final Color tone;
  final bool dense;
  final bool showDot;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.caption.copyWith(
        color: tone,
        fontWeight: FontWeight.w600,
      ),
    );
    return Container(
      constraints: BoxConstraints(minWidth: minWidth ?? 0),
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppTokens.s8 : AppTokens.s12,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppTokens.rXs),
      ),
      child: showDot
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppTokens.rXs,
                  height: AppTokens.rXs,
                  decoration: BoxDecoration(
                    color: tone,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppTokens.s4),
                Flexible(child: text),
              ],
            )
          : text,
    );
  }
}
