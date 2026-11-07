import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/tokens.dart';

/// Shared title row for pages rendered inside a bottom sheet.
class SheetTitle extends StatelessWidget {
  const SheetTitle({
    super.key,
    required this.title,
    required this.onClose,
    this.subtitle,
    this.leading,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onClose;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTokens.s20, 0, AppTokens.s8, 0),
      child: Row(
        children: [
          if (leading != null) leading!,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (actions != null) ...actions!,
          IconButton(
            tooltip: AppLocalizations.of(context).action_close,
            onPressed: onClose,
            icon: const Icon(TablerIcons.x),
          ),
        ],
      ),
    );
  }
}
