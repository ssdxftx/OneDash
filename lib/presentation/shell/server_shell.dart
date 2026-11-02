import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../common/components/server_switcher_sheet.dart';
import '../features/servers/providers/servers_provider.dart';

class ServerShell extends ConsumerWidget {
  const ServerShell({
    super.key,
    required this.serverId,
    required this.navigationShell,
  });

  final int serverId;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ServerShellScaffold(
      serverId: serverId,
      navigationShell: navigationShell,
    );
  }
}

class _ServerShellScaffold extends ConsumerWidget {
  const _ServerShellScaffold({
    required this.serverId,
    required this.navigationShell,
  });

  final int serverId;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          labelBehavior: MediaQuery.textScalerOf(context).scale(1) > 1.2
              ? NavigationDestinationLabelBehavior.onlyShowSelected
              : NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            HapticFeedback.selectionClick();
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(TablerIcons.dashboard),
              selectedIcon: const Icon(TablerIcons.dashboard_filled),
              label: l10n.nav_overview,
            ),
            NavigationDestination(
              icon: const Icon(TablerIcons.world),
              selectedIcon: const Icon(TablerIcons.world),
              label: l10n.nav_websites,
            ),
            NavigationDestination(
              icon: const Icon(TablerIcons.folder),
              selectedIcon: const Icon(TablerIcons.folder_filled),
              label: l10n.nav_files,
            ),
            NavigationDestination(
              icon: const Icon(TablerIcons.box),
              selectedIcon: const Icon(TablerIcons.box),
              label: l10n.nav_containers,
            ),
            NavigationDestination(
              icon: const Icon(TablerIcons.dots),
              selectedIcon: const Icon(TablerIcons.dots),
              label: l10n.nav_more,
            ),
          ],
        ),
      ),
    );
  }
}

/// 供各 Tab 页面复用的标题栏动作：长按标题呼出面板切换器。
void openServerSwitcher(BuildContext context, WidgetRef ref, int serverId) {
  showServerSwitcher(context, ref, currentServerId: serverId);
}

String serverTitle(WidgetRef ref, int serverId) {
  final server = ref.watch(serverByIdProvider(serverId)).valueOrNull;
  return server?.displayName ?? 'OneDash';
}
