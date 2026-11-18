import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tokens.dart';

bool _fitsOneLine(
  BuildContext context,
  String text,
  TextStyle style,
  double maxWidth,
) {
  if (!maxWidth.isFinite || maxWidth <= 0) return true;
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final fits = painter.width <= maxWidth;
  painter.dispose();
  return fits;
}

/// 标准大标题栏。滚动内容请使用 [SliverAppBarLarge]。
class AppBarLarge extends StatelessWidget implements PreferredSizeWidget {
  const AppBarLarge({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.onTitleTap,
    this.bottom,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onTitleTap;
  final PreferredSizeWidget? bottom;
  final bool compact;

  @override
  Size get preferredSize => Size.fromHeight(
    (compact
            ? AppTokens.appBarCompactHeight
            : subtitle == null
            ? AppTokens.appBarHeight
            : AppTokens.appBarLargeHeight) +
        (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: compact
          ? AppTokens.appBarCompactHeight
          : subtitle == null
          ? AppTokens.appBarHeight
          : AppTokens.appBarLargeHeight,
      leading: leading,
      actions: actions,
      bottom: bottom,
      title: _TitleBlock(
        title: title,
        subtitle: subtitle,
        onTap: onTitleTap,
        compact: compact,
      ),
    );
  }
}

class SliverAppBarLarge extends StatelessWidget {
  const SliverAppBarLarge({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.pinned = true,
    this.onTitleTap,
    this.flexibleSpace,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool pinned;
  final VoidCallback? onTitleTap;
  final Widget? flexibleSpace;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return SliverAppBar(
      pinned: pinned,
      toolbarHeight: subtitle == null
          ? AppTokens.appBarHeight
          : AppTokens.appBarLargeHeight,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: scheme.outlineVariant,
      scrolledUnderElevation: 2,
      actions: actions,
      leading: leading,
      flexibleSpace: flexibleSpace,
      title: _TitleBlock(title: title, subtitle: subtitle, onTap: onTitleTap),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({
    required this.title,
    this.subtitle,
    this.onTap,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final interactive = onTap != null;
    final block = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final base = compact
                        ? AppTextStyles.titleM
                        : AppTextStyles.headline;
                    final fallback = compact
                        ? AppTextStyles.titleS
                        : AppTextStyles.titleL;
                    final style =
                        _fitsOneLine(context, title, base, constraints.maxWidth)
                        ? base
                        : fallback;
                    return Text(
                      title,
                      style: style.copyWith(color: scheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              if (interactive) ...[
                const SizedBox(width: AppTokens.s4),
                Icon(
                  TablerIcons.chevron_down,
                  size: AppTokens.iconInline,
                  color: scheme.onSurfaceVariant,
                  semanticLabel: null,
                ),
              ],
            ],
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTextStyles.bodyS.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
    return Semantics(
      button: interactive,
      label: title,
      child: ExcludeSemantics(child: block),
    );
  }
}

/// 统一图标按钮，保证 48dp 点击区与语义标签。
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: AppTokens.iconNav,
      color: color,
      constraints: const BoxConstraints(
        minWidth: AppTokens.minTapTarget,
        minHeight: AppTokens.minTapTarget,
      ),
      icon: Icon(icon),
    );
  }
}
