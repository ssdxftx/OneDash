import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/theme/tokens.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    this.actions,
    this.height = AppTokens.appBarHeight,
  });

  final int selectedCount;
  final VoidCallback onCancel;
  final List<Widget>? actions;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      toolbarHeight: height,
      leading: IconButton(
        tooltip: l10n.files_cancelSelection,
        icon: const Icon(TablerIcons.x),
        onPressed: onCancel,
      ),
      title: Text(
        l10n.files_selectCount(selectedCount),
        style: AppTextStyles.titleM,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: actions,
    );
  }
}
