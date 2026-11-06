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
    this.onTitleTap,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onTitleTap;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 84);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      leading: leading,
      actions: actions,
      title: _TitleBlock(title: title, subtitle: subtitle, onTap: onTitleTap),
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
      toolbarHeight: subtitle == null ? 64 : 84,
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
  const _TitleBlock({required this.title, this.subtitle, this.onTap});

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

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
                child: Text(
                  title,
                  style: AppTextStyles.headline.copyWith(
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (interactive) ...[
                const SizedBox(width: AppTokens.s4),
                Icon(
                  TablerIcons.chevron_down,
                  size: 18,
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
