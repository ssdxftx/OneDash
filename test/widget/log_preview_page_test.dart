import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/features/log/screens/log_preview_page.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.build(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  testWidgets('loads lines, filters by search and keeps the buffer', (
    tester,
  ) async {
    final lines = [
      '2026-01-01 10:00:00 INFO boot complete',
      '2026-01-01 10:00:01 ERROR database failed',
      '2026-01-01 10:00:02 INFO ready',
    ];
    await tester.pumpWidget(
      wrap(
        LogPreviewPage(
          title: 'demo.log',
          sources: [LogSourceOption(label: 'main', load: () async => lines)],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('boot complete'), findsOneWidget);
    expect(find.textContaining('database failed'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'error');
    await tester.pump();

    expect(find.textContaining('database failed'), findsOneWidget);
    expect(find.textContaining('boot complete'), findsNothing);
  });

  testWidgets('structured mode renders parsed level and raw mode keeps text', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        LogPreviewPage(
          title: 'demo.log',
          sources: [
            LogSourceOption(
              label: 'main',
              load: () async => ['2026-01-01 10:00:01 ERROR database failed'],
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('database failed'), findsOneWidget);

    await tester.tap(find.text('Structured'));
    await tester.pump();
    expect(find.text('ERROR'), findsWidgets);
    expect(find.textContaining('database failed'), findsOneWidget);
  });

  testWidgets('follow polling appends newly loaded lines', (tester) async {
    final lines = ['first line'];
    await tester.pumpWidget(
      wrap(
        LogPreviewPage(
          title: 'demo.log',
          followInterval: const Duration(seconds: 1),
          sources: [
            LogSourceOption(label: 'main', load: () async => List.of(lines)),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('second line'), findsNothing);

    await tester.tap(find.text('Follow'));
    await tester.pump();
    lines.add('second line');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.textContaining('second line'), findsOneWidget);
  });
}
