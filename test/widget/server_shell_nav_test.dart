import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/core/theme/tokens.dart';
import 'package:onedash/presentation/shell/server_shell.dart';

GoRouter _router() {
  return GoRouter(
    initialLocation: '/a',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ServerShell(serverId: 1, navigationShell: navigationShell),
        branches: [
          for (final path in ['a', 'b', 'c', 'd', 'e'])
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/$path',
                  builder: (context, state) => Scaffold(
                    body: ListView.builder(
                      itemExtent: 80,
                      itemCount: 30,
                      itemBuilder: (context, index) =>
                          Text('item $path $index'),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}

Widget _app(GoRouter router, {bool reduceMotion = false}) {
  return ProviderScope(
    child: MaterialApp.router(
      theme: AppTheme.build(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );
}

void main() {
  testWidgets('floating nav hides on scroll up and returns after idle', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_router()));
    await tester.pumpAndSettle();

    final list = find.byType(ListView).first;
    await tester.drag(list, const Offset(0, -260));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    var slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
    expect(slide.offset, isNot(Offset.zero));

    await tester.pump(const Duration(milliseconds: 1300));
    slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
    expect(slide.offset, Offset.zero);
  });

  testWidgets('scroll down shows the nav again', (tester) async {
    await tester.pumpWidget(_app(_router()));
    await tester.pumpAndSettle();

    final list = find.byType(ListView).first;
    await tester.drag(list, const Offset(0, -400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset,
      isNot(Offset.zero),
    );

    await tester.drag(list, const Offset(0, 200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset,
      Offset.zero,
    );
  });

  testWidgets('reduce motion uses zero duration', (tester) async {
    await tester.pumpWidget(_app(_router(), reduceMotion: true));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -260));
    await tester.pump();

    final slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
    expect(slide.duration, Duration.zero);
    expect(slide.offset, isNot(Offset.zero));
  });

  testWidgets('nav stays within max width and above safe area', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(_router()));
    await tester.pumpAndSettle();

    final nav = tester.getRect(find.byType(NavigationBar));
    expect(nav.width, lessThanOrEqualTo(AppTokens.bottomNavMaxWidth));
    final screen = tester.view.physicalSize.width;
    expect(nav.center.dx, closeTo(screen / 2, 1));
  });
}
