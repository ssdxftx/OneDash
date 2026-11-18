import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/app_bar_actions.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.build(Brightness.light),
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: Scaffold(appBar: AppBar(actions: [child])),
  );
}

void main() {
  testWidgets('two actions stay inline', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppBarActions(
          actions: [
            AppBarAction(
              icon: TablerIcons.refresh,
              tooltip: 'Refresh',
              onPressed: () {},
            ),
            AppBarAction(
              icon: TablerIcons.search,
              tooltip: 'Search',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.byIcon(TablerIcons.refresh), findsOneWidget);
    expect(find.byIcon(TablerIcons.search), findsOneWidget);
    expect(find.byIcon(TablerIcons.dots), findsNothing);
  });

  testWidgets('three actions collapse to refresh and more', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppBarActions(
          maxInline: 1,
          actions: [
            AppBarAction(
              icon: TablerIcons.refresh,
              tooltip: 'Refresh',
              onPressed: () {},
            ),
            AppBarAction(
              icon: TablerIcons.adjustments,
              tooltip: 'Options',
              onPressed: () {},
            ),
            AppBarAction(
              icon: TablerIcons.terminal_2,
              tooltip: 'Terminal',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    final icons = tester
        .widgetList<Icon>(
          find.descendant(
            of: find.byType(AppBarActions),
            matching: find.byType(Icon),
          ),
        )
        .map((icon) => icon.icon)
        .toList();
    expect(icons, [TablerIcons.refresh, TablerIcons.dots]);
  });

  testWidgets('overflow keeps refresh first and create last', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppBarActions(
          actions: [
            AppBarAction(
              icon: TablerIcons.search,
              tooltip: 'Search',
              onPressed: () {},
            ),
            AppBarAction(
              icon: TablerIcons.refresh,
              tooltip: 'Refresh',
              onPressed: () {},
            ),
            AppBarAction(
              icon: TablerIcons.trash,
              tooltip: 'Delete',
              onPressed: () {},
            ),
            AppBarAction(
              icon: TablerIcons.plus,
              tooltip: 'Create',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    final icons = tester
        .widgetList<Icon>(
          find.descendant(
            of: find.byType(AppBarActions),
            matching: find.byType(Icon),
          ),
        )
        .map((icon) => icon.icon)
        .toList();
    expect(icons, [TablerIcons.refresh, TablerIcons.plus, TablerIcons.dots]);
  });
}
