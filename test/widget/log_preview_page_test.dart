import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/features/log/screens/log_preview_page.dart';

Future<void> _loadFont() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = await File('assets/fonts/MiSans-Regular.ttf').readAsBytes();
  await ui.loadFontFromList(Uint8List.fromList(bytes), fontFamily: 'MiSans');
}

void main() {
  setUpAll(_loadFont);

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

  testWidgets('loads earlier lines from the server page', (tester) async {
    final pages = <int>[];
    await tester.pumpWidget(
      wrap(
        LogPreviewPage(
          title: 'demo.log',
          sources: [
            LogSourceOption(
              label: 'main',
              load: () async => ['newest'],
              loadPage: (page, size) async {
                pages.add(page);
                return page == 1
                    ? const LogBatch(lines: ['newest'], end: false)
                    : const LogBatch(lines: ['older'], end: true);
              },
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('older'), findsNothing);

    await tester.tap(find.text('Load earlier lines'));
    await tester.pumpAndSettle();
    expect(pages, [1, 2]);
    expect(find.textContaining('older'), findsOneWidget);
    expect(find.textContaining('newest'), findsOneWidget);
  });

  testWidgets('deduplicates a repeated page and stops paging', (tester) async {
    await tester.pumpWidget(
      wrap(
        LogPreviewPage(
          title: 'demo.log',
          sources: [
            LogSourceOption(
              label: 'main',
              load: () async => ['newest'],
              loadPage: (page, size) async =>
                  const LogBatch(lines: ['newest'], end: false),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load earlier lines'));
    await tester.pumpAndSettle();

    expect(find.textContaining('newest'), findsOneWidget);
    expect(find.text('Start of file reached'), findsOneWidget);
    expect(find.text('Load earlier lines'), findsNothing);
  });

  testWidgets('keeps structured access paths readable at 320dp and 1.3x', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: LogPreviewPage(
          title: 'access.log',
          sources: [
            LogSourceOption(
              label: 'main',
              load: () async => [
                '1.2.3.4 - - [05/Nov/2026:09:12:03 +0800] '
                    '"GET /api/v1/very/long/endpoint HTTP/1.1" 200 123 '
                    '"-" "UA" 0.012',
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Structured'));
    await tester.pump();

    final badge = tester.getRect(find.text('200').first);
    final path = find.text('/api/v1/very/long/endpoint');
    expect(path, findsOneWidget);
    expect(tester.getSize(path).width, greaterThanOrEqualTo(96));
    expect(tester.getRect(path).top, greaterThan(badge.bottom));
  });

  testWidgets('keeps access rows on one line from 360dp', (tester) async {
    addTearDown(tester.view.reset);
    for (final width in [360.0, 390.0, 412.0]) {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        wrap(
          LogPreviewPage(
            title: 'access.log',
            sources: [
              LogSourceOption(
                label: 'main',
                load: () async => [
                  '1.2.3.4 - - [05/Nov/2026:09:12:03 +0800] '
                      '"GET /api/v1/very/long/endpoint HTTP/1.1" 200 123 '
                      '"-" "UA" 0.012',
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Structured'));
      await tester.pump();

      final badge = tester.getRect(find.text('200').first);
      final path = tester.getRect(
        find.text('/api/v1/very/long/endpoint').first,
      );
      expect(
        (path.center.dy - badge.center.dy).abs(),
        lessThan(6),
        reason: '${width}dp should keep the status and path on one line',
      );
      expect(
        path.width,
        greaterThanOrEqualTo(150),
        reason: '${width}dp path width ${path.width}',
      );
      if (width == 360) {
        expect(
          find.text('0.012s'),
          findsNothing,
          reason: '360dp should drop the duration before wrapping',
        );
        expect(
          find.text('GET'),
          findsOneWidget,
          reason: '360dp keeps the method after dropping the duration',
        );
      } else {
        expect(
          find.text('0.012s'),
          findsOneWidget,
          reason: '${width}dp has room for the duration',
        );
        expect(
          find.text('GET'),
          findsOneWidget,
          reason: '${width}dp has room for the method',
        );
      }
    }
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
