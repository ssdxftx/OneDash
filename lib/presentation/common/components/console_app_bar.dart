import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

/// 沉浸式控制台页头。固定使用 console 系列颜色，不跟随主题。
class ConsoleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ConsoleAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.titleLeading,
    this.leading,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget? titleLeading;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(
    subtitle == null ? AppTokens.appBarHeight : AppTokens.appBarLargeHeight,
  );

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        (subtitle == null ? AppTextStyles.titleL : AppTextStyles.headline)
            .copyWith(color: AppTokens.consoleForeground);
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: AppTokens.consoleBackground,
      foregroundColor: AppTokens.consoleForeground,
      titleTextStyle: titleStyle,
      leading: leading,
      actions: actions,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (titleLeading != null) ...[
            titleLeading!,
            const SizedBox(width: AppTokens.s8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppTokens.consoleMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 控制台快捷键按钮。禁用态保持可见，只降低对比度。
class ConsoleToolbarButton extends StatelessWidget {
  const ConsoleToolbarButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppTokens.consoleForeground,
        disabledForegroundColor: AppTokens.consoleMuted,
        minimumSize: const Size(AppTokens.minTapTarget, AppTokens.minTapTarget),
      ),
      child: Text(label, style: AppTextStyles.caption),
    );
  }
}
