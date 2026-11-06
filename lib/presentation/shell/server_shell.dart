import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/router/route_observer.dart';
import '../../core/theme/tokens.dart';
import '../common/components/server_switcher_sheet.dart';
import '../features/servers/providers/servers_provider.dart';
import '../features/settings/providers/app_settings_provider.dart';
import 'nav_visibility.dart';

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

class _ServerShellScaffold extends ConsumerStatefulWidget {
  const _ServerShellScaffold({
    required this.serverId,
    required this.navigationShell,
  });

  final int serverId;
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<_ServerShellScaffold> createState() =>
      _ServerShellScaffoldState();
}

class _ServerShellScaffoldState extends ConsumerState<_ServerShellScaffold>
    with RouteAware {
  bool _visible = true;
  double _accum = 0;
  Timer? _showTimer;
  PageRoute<dynamic>? _route;

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is ScrollStartNotification) {
      _showTimer?.cancel();
      _accum = 0;
    } else if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      _accum = _accum.sign == delta.sign ? _accum + delta : delta;
      if (delta > 0 &&
          _accum > AppTokens.s24 &&
          notification.metrics.pixels > 80) {
        _hide();
      }
      if (delta < 0 && _accum < -AppTokens.s24) _show();
      if (notification.metrics.pixels <= 0) _show();
    } else if (notification is OverscrollNotification) {
      _show();
    } else if (notification is ScrollEndNotification) {
      _showTimer?.cancel();
      _showTimer = Timer(AppTokens.dLoop, _show);
    }
    return false;
  }

  void _show() {
    if (!_visible) setState(() => _visible = true);
  }

  void _hide() {
    if (_visible) setState(() => _visible = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _route) {
      if (_route != null) appRouteObserver.unsubscribe(this);
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didUpdateWidget(covariant _ServerShellScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _visible = true;
      ref.read(bottomNavSuppressedProvider.notifier).state = false;
    }
  }

  @override
  void didPopNext() => _show();

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _showTimer?.cancel();
    super.dispose();
  }

  void _selectDestination(int index) {
    final haptics =
        ref.read(appSettingsControllerProvider).valueOrNull?.hapticsEnabled ??
        true;
    if (haptics) HapticFeedback.selectionClick();
    ref.read(bottomNavSuppressedProvider.notifier).state = false;
    _show();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final shown = _visible && !ref.watch(bottomNavSuppressedProvider);
    final hideDuration = context.motion(const Duration(milliseconds: 240));
    final showDuration = context.motion(const Duration(milliseconds: 200));
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppTokens.contentMaxWidth,
                  ),
                  child: widget.navigationShell,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: !shown,
              child: ExcludeSemantics(
                excluding: !shown,
                child: AnimatedSlide(
                  offset: shown ? Offset.zero : const Offset(0, 1.2),
                  duration: shown ? showDuration : hideDuration,
                  curve: AppTokens.curveBase,
                  child: AnimatedOpacity(
                    opacity: shown ? 1 : 0,
                    duration: shown ? showDuration : hideDuration,
                    curve: AppTokens.curveBase,
                    child: _floatingNav(context, l10n, scheme),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingNav(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    final radius = BorderRadius.circular(AppTokens.rSheet);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTokens.s16,
        0,
        AppTokens.s16,
        AppTokens.s12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.bottomNavMaxWidth,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: NavigationBar(
                height: AppTokens.bottomNavHeight,
                backgroundColor: scheme.surfaceContainer,
                elevation: 0,
                selectedIndex: widget.navigationShell.currentIndex,
                labelBehavior: MediaQuery.textScalerOf(context).scale(1) > 1.2
                    ? NavigationDestinationLabelBehavior.onlyShowSelected
                    : NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: _selectDestination,
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
          ),
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
