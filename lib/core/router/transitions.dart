import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';

Page<void> noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

Page<void> fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppTokens.dBase,
    reverseTransitionDuration: AppTokens.dBase,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (context.reduceMotion) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppTokens.curveBase,
        reverseCurve: AppTokens.curveBase,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}

Page<void> slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppTokens.dPage,
    reverseTransitionDuration: AppTokens.dPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (context.reduceMotion) return child;
      final enter = CurvedAnimation(
        parent: animation,
        curve: AppTokens.curveBase,
        reverseCurve: AppTokens.curveEmphasis,
      );
      final exit = CurvedAnimation(
        parent: secondaryAnimation,
        curve: AppTokens.curveFast,
        reverseCurve: Curves.linear,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.06, 0),
        ).animate(exit),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0.96).animate(exit),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(enter),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.85, end: 1).animate(enter),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
