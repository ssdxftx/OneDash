import 'package:flutter/material.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/tokens.dart';

const double _dividerIndentWithLeading =
    AppTokens.s16 + AppTokens.iconLeading + AppTokens.s12;

/// 一组列表项共用一张圆角卡，内部 1px 分隔线，首尾无分隔线。
class SplitListGroup extends StatelessWidget {
  const SplitListGroup({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
    this.flat = false,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        final previous = children[i - 1];
        final hasLeading =
            previous is SplitListTile && previous.leading != null;
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: hasLeading ? _dividerIndentWithLeading : AppTokens.s16,
            endIndent: AppTokens.s16,
            color: scheme.outlineVariant,
          ),
        );
      }
      rows.add(children[i]);
    }

    final body = Column(mainAxisSize: MainAxisSize.min, children: rows);
    if (flat) return Padding(padding: padding, child: body);
    return Padding(
      padding: padding,
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rLg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: body,
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
    this.subtitleMaxLines = 2,
    this.value,
    this.valueStyle,
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
  final int? subtitleMaxLines;
  final String? value;
  final TextStyle? valueStyle;
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
    final placeholder = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    )?.common_notAvailable;
    final isPlaceholder =
        hasValue && placeholder != null && value == placeholder;
    final titleStyle = (hasValue ? AppTextStyles.bodyS : AppTextStyles.bodyL)
        .copyWith(
          color: hasValue && !danger ? scheme.onSurfaceVariant : titleColor,
          fontWeight: FontWeight.w500,
        );
    final baseValueStyle = AppTextStyles.bodyL.copyWith(
      color: enabled
          ? isPlaceholder
                ? scheme.onSurfaceVariant
                : scheme.onSurface
          : scheme.onSurface.withValues(alpha: 0.38),
      fontWeight: FontWeight.w500,
    );
    final effectiveValueStyle = valueStyle == null
        ? baseValueStyle
        : baseValueStyle.merge(valueStyle);
    final valueWidget = hasValue
        ? Text(value!, style: effectiveValueStyle)
        : null;
    final effectiveTrailing = trailing ?? valueWidget;

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
              final hasCombo = valueWidget != null && trailing != null;
              final comboLimit = hasCombo && trailingLimit != null
                  ? trailingLimit -
                        _trailingWidth(context, trailing!) -
                        AppTokens.s8
                  : null;
              final stackValueOnly =
                  valueWidget != null &&
                  trailing == null &&
                  _overflows(
                    context,
                    constraints.maxWidth,
                    titleStyle,
                    valueWidget,
                  );
              final stackValue =
                  (hasCombo &&
                      _comboOverflows(
                        context,
                        constraints.maxWidth,
                        titleStyle,
                        valueWidget,
                        trailing!,
                        comboLimit,
                      )) ||
                  stackValueOnly;
              final trailingText =
                  valueWidget == null && _isText(effectiveTrailing)
                  ? effectiveTrailing
                  : null;
              final stackTrailing =
                  trailingText != null &&
                  _overflows(
                    context,
                    constraints.maxWidth,
                    titleStyle,
                    trailingText,
                  );
              return Row(
                crossAxisAlignment: stackTrailing || stackValue
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
                        if (stackValue && trailing != null)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: titleStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing!,
                            ],
                          )
                        else
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
                            maxLines: subtitleMaxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (stackValue) ...[
                          const SizedBox(height: 2),
                          _buildTrailing(
                            valueWidget,
                            null,
                            alignStart: true,
                            allowWrap: true,
                          ),
                        ],
                        if (stackTrailing) ...[
                          const SizedBox(height: 2),
                          _buildTrailing(
                            trailingText,
                            null,
                            alignStart: true,
                            allowWrap: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (effectiveTrailing != null &&
                      !stackTrailing &&
                      !stackValue) ...[
                    const SizedBox(width: AppTokens.s12),
                    if (hasCombo)
                      _buildComboValue(
                        valueWidget,
                        trailing!,
                        stackValue: stackValue,
                        valueLimit: comboLimit,
                      )
                    else
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

  bool _isText(Widget? widget) => widget is Text && widget.data != null;

  Widget _buildComboValue(
    Widget value,
    Widget trailing, {
    required bool stackValue,
    required double? valueLimit,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!stackValue) ...[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: valueLimit ?? double.infinity,
            ),
            child: _buildTrailing(value, null),
          ),
          const SizedBox(width: AppTokens.s8),
        ],
        trailing,
      ],
    );
  }

  bool _comboOverflows(
    BuildContext context,
    double availableWidth,
    TextStyle titleStyle,
    Widget value,
    Widget trailing,
    double? valueLimit,
  ) {
    if (!availableWidth.isFinite) return false;
    final textScaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final titlePainter = TextPainter(
      text: TextSpan(text: title, style: titleStyle),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    );
    final valueText = value as Text;
    final valuePainter = TextPainter(
      text: TextSpan(
        text: valueText.data,
        style: valueText.style ?? DefaultTextStyle.of(context).style,
      ),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    );
    try {
      titlePainter.layout();
      valuePainter.layout();
      final leadingWidth = leading == null
          ? 0.0
          : AppTokens.iconLeading + AppTokens.s12;
      final rowWidth = availableWidth - leadingWidth;
      final combined =
          titlePainter.width +
          AppTokens.s12 +
          valuePainter.width +
          AppTokens.s8 +
          _trailingWidth(context, trailing);
      final valueOverLimit =
          valueLimit != null && valuePainter.width > valueLimit;
      return combined > rowWidth || valueOverLimit;
    } finally {
      titlePainter.dispose();
      valuePainter.dispose();
    }
  }

  double _trailingWidth(BuildContext context, Widget trailing) {
    if (trailing is IconButton) return 48;
    if (trailing is Text && trailing.data != null) {
      final painter = TextPainter(
        text: TextSpan(
          text: trailing.data,
          style: trailing.style ?? DefaultTextStyle.of(context).style,
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      );
      try {
        painter.layout();
        return painter.width;
      } finally {
        painter.dispose();
      }
    }
    if (trailing is SizedBox && trailing.width != null) {
      return trailing.width!;
    }
    if (trailing is Row) {
      return trailing.children
          .map((child) => _trailingWidth(context, child))
          .fold<double>(0, (sum, width) => sum + width);
    }
    return 48;
  }

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
    );
    final trailingText = trailing as Text;
    final trailingPainter = TextPainter(
      text: TextSpan(
        text: trailingText.data,
        style: trailingText.style ?? DefaultTextStyle.of(context).style,
      ),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    );
    try {
      titlePainter.layout();
      trailingPainter.layout();
      final leadingWidth = leading == null
          ? 0.0
          : AppTokens.iconLeading + AppTokens.s12;
      final rowWidth = availableWidth - leadingWidth;
      return titlePainter.width + AppTokens.s12 + trailingPainter.width >
          rowWidth;
    } finally {
      titlePainter.dispose();
      trailingPainter.dispose();
    }
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
    final widget = text is Icon
        ? IconTheme(
            data: const IconThemeData(size: AppTokens.iconList),
            child: text,
          )
        : text;
    if (maxWidth == null) return widget;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: widget,
    );
  }
}
