import 'package:flutter/material.dart';

/// Tracks routes for shell visibility and for global overlay depth.
///
/// [popupDepth] rises for every [PopupRoute] on the root navigator, so bottom
/// sheets and dialogs can hide the floating navigation without each caller
/// having to coordinate with the shell.
class AppRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  final ValueNotifier<int> popupDepth = ValueNotifier<int>(0);

  void _increment(Route<dynamic> route) {
    if (route is PopupRoute) popupDepth.value++;
  }

  void _decrement(Route<dynamic> route) {
    if (route is PopupRoute) {
      popupDepth.value = (popupDepth.value - 1).clamp(0, 99);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _increment(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _decrement(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _decrement(route);
  }
}

final appRouteObserver = AppRouteObserver();
