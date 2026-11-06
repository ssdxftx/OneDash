import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/tonal_card.dart';
import 'package:onedash/presentation/features/log/screens/log_preview_page.dart';

const _lines = <String>[
  '10.0.0.1 - - [06/Nov/2026:01:02:03 +0800] "GET /api/v1/very/long/path/that/keeps/going/for/testing HTTP/1.1" 200 123 "-" "curl/8"',
  '10.0.0.2 - - [06/Nov/2026:01:02:04 +0800] "POST /missing HTTP/1.1" 404 12 "-" "Mozilla/5.0"',
  '10.0.0.3 - - [06/Nov/2026:01:02:05 +0800] "GET /broken HTTP/1.1" 502 0 "-" "Mozilla/5.0"',
];

void main() {
  testWidgets('access logs render as cards without overflow at 320dp/2x', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: LogPreviewPage(
              title: 'Logs',
              sources: [
                LogSourceOption(label: 'access', load: () async => _lines),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(TonalCard), findsNWidgets(_lines.length));

    final longPath = tester.widget<Text>(
      find.textContaining('/api/v1/very/long/path'),
    );
    expect(longPath.maxLines, 1);
    expect(longPath.overflow, TextOverflow.ellipsis);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );
  });
}
