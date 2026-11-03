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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rLg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
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
    this.value,
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
  final String? value;
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

    final hasValue = value != null;
    final titleStyle = (hasValue ? AppTextStyles.bodyS : AppTextStyles.bodyL)
        .copyWith(
          color: hasValue && !danger ? scheme.onSurfaceVariant : titleColor,
          fontWeight: FontWeight.w500,
        );
    final valueStyle = AppTextStyles.bodyL.copyWith(
      color: enabled
          ? scheme.onSurface
          : scheme.onSurface.withValues(alpha: 0.38),
      fontWeight: FontWeight.w500,
    );
    final effectiveTrailing =
        trailing ?? (hasValue ? Text(value!, style: valueStyle) : null);

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trailingLimit = constraints.maxWidth.isFinite
                  ? constraints.maxWidth * 0.6
                  : null;
              final stackTrailing =
                  effectiveTrailing != null &&
                  _isText(effectiveTrailing) &&
                  _overflows(
                    context,
                    constraints.maxWidth,
                    titleStyle,
                    effectiveTrailing,
                  );
              return Row(
                crossAxisAlignment: stackTrailing
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
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
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: (subtitleStyle ?? AppTextStyles.bodyS)
                                .copyWith(color: subtitleColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (stackTrailing) ...[
                          const SizedBox(height: 2),
                          _buildTrailing(
                            effectiveTrailing,
                            null,
                            alignStart: true,
                            allowWrap: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (effectiveTrailing != null && !stackTrailing) ...[
                    const SizedBox(width: AppTokens.s12),
                    _buildTrailing(
                      effectiveTrailing,
                      _isText(effectiveTrailing) ? null : trailingLimit,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _isText(Widget widget) => widget is Text && widget.data != null;

  bool _overflows(
    BuildContext context,
    double availableWidth,
    TextStyle titleStyle,
    Widget trailing,
  ) {
    if (!availableWidth.isFinite) return false;
    final textScaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final titlePainter = TextPainter(
      text: TextSpan(text: title, style: titleStyle),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final trailingText = trailing as Text;
    final trailingPainter = TextPainter(
      text: TextSpan(
        text: trailingText.data,
        style: trailingText.style ?? DefaultTextStyle.of(context).style,
      ),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final leadingWidth = leading == null
        ? 0.0
        : AppTokens.iconLeading + AppTokens.s12;
    final rowWidth = availableWidth - leadingWidth;
    return titlePainter.width + AppTokens.s12 + trailingPainter.width >
        rowWidth;
  }

  Widget _buildTrailing(
    Widget child,
    double? maxWidth, {
    bool alignStart = false,
    bool allowWrap = false,
  }) {
    final text = child is Text && child.data != null
        ? Text(
            child.data!,
            style: child.style,
            strutStyle: child.strutStyle,
            textAlign: alignStart
                ? TextAlign.start
                : child.textAlign ?? TextAlign.end,
            textDirection: child.textDirection,
            locale: child.locale,
            softWrap: allowWrap,
            overflow: TextOverflow.ellipsis,
            textScaler: child.textScaler,
            maxLines: allowWrap ? 2 : 1,
            semanticsLabel: child.semanticsLabel,
            textWidthBasis: child.textWidthBasis,
            textHeightBehavior: child.textHeightBehavior,
          )
        : child;
    if (maxWidth == null) return text;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: text,
    );
  }
}
