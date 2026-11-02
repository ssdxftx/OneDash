import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import 'pressable_scale.dart';

/// 全应用唯一的卡片容器：surfaceContainerLow + 18dp 圆角 + 无阴影。
class TonalCard extends StatelessWidget {
  const TonalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTokens.s16),
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderRadius = AppTokens.rLg,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double borderRadius;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final content = Material(
      color: color ?? scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: clipBehavior,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap == null && onLongPress == null) return content;
    return PressableScale(
      onTap: onTap,
      onLongPress: onLongPress,
      child: content,
    );
  }
}
