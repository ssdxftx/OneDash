import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/generated/app_localizations.dart';
import 'app_bar_large.dart';

/// Returns from a panel's tab shell to the panel list.
class BackToServersButton extends StatelessWidget {
  const BackToServersButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: TablerIcons.arrow_left,
      tooltip: AppLocalizations.of(context).servers_backToList,
      onPressed: () => GoRouter.of(context).go('/'),
    );
  }
}
