import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tokens.dart';

/// 标准大标题栏。滚动内容请使用 [SliverAppBarLarge]。
class AppBarLarge extends StatelessWidget implements PreferredSizeWidget {
  const AppBarLarge({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.onTitleLongPress,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onTitleLongPress;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 84);

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return AppBar(
      toolbarHeight: preferredSize.height,
      leading: leading,
      actions: actions,
      title: GestureDetector(
        onLongPress: onTitleLongPress,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.headline.copyWith(
                      color: scheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onTitleLongPress != null) ...[
                  const SizedBox(width: AppTokens.s4),
                  Icon(
                    TablerIcons.chevron_down,
                    size: 18,
                    color: scheme.onSurfaceVariant,
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
    this.onTitleLongPress,
    this.flexibleSpace,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool pinned;
  final VoidCallback? onTitleLongPress;
  final Widget? flexibleSpace;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return SliverAppBar(
      pinned: pinned,
      toolbarHeight: subtitle == null ? 64 : 84,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      actions: actions,
      leading: leading,
      flexibleSpace: flexibleSpace,
      title: GestureDetector(
        onLongPress: onTitleLongPress,
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
                  child: Text(
                    title,
                    style: AppTextStyles.headline.copyWith(
                      color: scheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onTitleLongPress != null) ...[
                  const SizedBox(width: AppTokens.s4),
                  Icon(
                    TablerIcons.chevron_down,
                    size: 18,
                    color: scheme.onSurfaceVariant,
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
      ),
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
