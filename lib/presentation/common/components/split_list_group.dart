import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

/// 一组列表项共用一张圆角卡，内部 1px 分隔线，首尾无分隔线。
class SplitListGroup extends StatelessWidget {
  const SplitListGroup({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: AppTokens.s16,
            endIndent: AppTokens.s16,
            color: scheme.outlineVariant,
          ),
        );
      }
      rows.add(children[i]);
    }

    return Padding(
      padding: padding,
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.rLg),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}

/// SplitListGroup 内的标准行。
class SplitListTile extends StatelessWidget {
  const SplitListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleStyle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.danger = false,
    this.enabled = true,
    this.minHeight = AppTokens.rowOneLine,
  });

  final String title;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool danger;
  final bool enabled;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.appColors;
    final titleColor = danger
        ? scheme.error
        : enabled
        ? scheme.onSurface
        : scheme.onSurface.withValues(alpha: 0.38);
    final subtitleColor = enabled
        ? scheme.onSurfaceVariant
        : scheme.onSurfaceVariant.withValues(alpha: 0.38);

    return InkWell(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.s16,
            vertical: AppTokens.s12,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: AppTokens.iconLeading,
                    color: danger ? colors.danger : scheme.onSurfaceVariant,
                  ),
                  child: leading!,
                ),
                const SizedBox(width: AppTokens.s12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyL.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: (subtitleStyle ?? AppTextStyles.bodyS).copyWith(
                          color: subtitleColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppTokens.s12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
