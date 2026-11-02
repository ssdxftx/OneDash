import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tokens.dart';

/// 底部动作面板骨架：可选信息卡 + 分组动作。
class ActionSheetScaffold extends StatelessWidget {
  const ActionSheetScaffold({super.key, this.infoCard, required this.child});

  final Widget? infoCard;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (infoCard != null) ...[
            infoCard!,
            const SizedBox(height: AppTokens.s20),
          ],
          child,
        ],
      ),
    );
  }
}

/// 顶部信息卡：图标、标题、副标题和状态徽章。
class ActionSheetInfoCard extends StatelessWidget {
  const ActionSheetInfoCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Row(
      children: [
        SizedBox.square(dimension: 56, child: leading),
        const SizedBox(width: AppTokens.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.titleL,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
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
    );
  }
}

/// 状态徽章。
class ActionSheetStatusPill extends StatelessWidget {
  const ActionSheetStatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: AppTokens.s4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.rFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 动作分组：标题行 + 组内动作。
class ActionSheetSection extends StatelessWidget {
  const ActionSheetSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final rows = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) {
        rows.add(
          Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.6),
          ),
        );
      }
      rows.add(children[index]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTokens.s4,
            bottom: AppTokens.s8,
          ),
          child: Row(
            children: [
              Icon(icon, size: AppTokens.iconList, color: scheme.primary),
              const SizedBox(width: AppTokens.s8),
              Text(
                title,
                style: AppTextStyles.titleS.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTokens.rLg),
          clipBehavior: Clip.antiAlias,
          child: Column(mainAxisSize: MainAxisSize.min, children: rows),
        ),
        const SizedBox(height: AppTokens.s20),
      ],
    );
  }
}

/// 动作行：图标、标题、副标题、尾随内容和禁用/危险状态。
class ActionSheetRow extends StatelessWidget {
  const ActionSheetRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.danger = false,
    this.enabled = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.appColors;
    final effectiveColor = danger ? colors.danger : iconColor;
    final titleColor = danger ? colors.danger : scheme.onSurface;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.38,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppTokens.rowOneLine),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s12,
              vertical: AppTokens.s8,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTokens.rSm),
                  ),
                  child: Icon(
                    icon,
                    size: AppTokens.iconList,
                    color: effectiveColor,
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
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
                          style: AppTextStyles.caption.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppTokens.s8),
                  trailing!,
                ] else if (enabled && onTap != null)
                  Icon(
                    TablerIcons.chevron_right,
                    size: AppTokens.iconList,
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
