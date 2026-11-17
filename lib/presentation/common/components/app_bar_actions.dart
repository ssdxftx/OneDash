import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/generated/app_localizations.dart';
import 'app_bar_large.dart';
import 'bottom_sheet_surface.dart';

/// 页头动作的描述项。收进「更多」菜单时用 [label] 作文字。
class AppBarAction {
  const AppBarAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.label,
    this.overflowOnly = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final String? label;
  final bool overflowOnly;
}

/// 页头动作排布：超过 [maxInline] 个时保留刷新与新建，其余收进「更多」菜单。
class AppBarActions extends StatelessWidget {
  const AppBarActions({super.key, required this.actions, this.maxInline = 2});

  final List<AppBarAction> actions;
  final int maxInline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (inline, overflow) = _split();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final action in inline)
          AppIconButton(
            icon: action.icon,
            tooltip: action.tooltip,
            onPressed: action.onPressed,
          ),
        if (overflow.isNotEmpty)
          AppIconButton(
            icon: TablerIcons.dots,
            tooltip: l10n.action_more,
            onPressed: () async {
              final picked = await showSelectionMenu<AppBarAction>(
                context,
                options: [
                  for (final action in overflow)
                    SelectionOption<AppBarAction>(
                      value: action,
                      label: action.label ?? action.tooltip,
                      icon: action.icon,
                    ),
                ],
              );
              picked?.onPressed?.call();
            },
          ),
      ],
    );
  }

  (List<AppBarAction>, List<AppBarAction>) _split() {
    if (actions.length <= maxInline) return (actions, const []);
    final pinned = <int>{};
    final refresh = actions.indexWhere(
      (action) => action.icon == TablerIcons.refresh,
    );
    if (refresh >= 0) pinned.add(refresh);
    final plus = actions.lastIndexWhere(
      (action) => action.icon == TablerIcons.plus,
    );
    if (plus >= 0 && !actions[plus].overflowOnly) pinned.add(plus);
    for (var i = 0; i < actions.length && pinned.length < maxInline; i++) {
      if (!actions[i].overflowOnly) {
        pinned.add(i);
      }
    }
    final inline = <AppBarAction>[];
    if (refresh >= 0 && pinned.contains(refresh)) inline.add(actions[refresh]);
    for (var i = 0; i < actions.length; i++) {
      if (pinned.contains(i) && i != refresh && i != plus) {
        inline.add(actions[i]);
      }
    }
    if (plus >= 0 && pinned.contains(plus)) inline.add(actions[plus]);
    final overflow = <AppBarAction>[
      for (var i = 0; i < actions.length; i++)
        if (!pinned.contains(i)) actions[i],
    ];
    return (inline, overflow);
  }
}
