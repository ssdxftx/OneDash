import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

/// 只读状态胶囊：成功/失败、执行中一类的一句话状态。
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.tone,
    this.dense = false,
  });

  final String label;
  final Color tone;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppTokens.s8 : AppTokens.s12,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.rXs),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: tone,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
