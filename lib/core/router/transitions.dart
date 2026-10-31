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
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppTokens.curveBase,
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
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.85, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
