import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/metric_card.dart';

Widget _wrap(Widget child, {double scale = 1}) {
  return MaterialApp(
    theme: AppTheme.build(Brightness.light),
    builder: (context, appChild) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: appChild!,
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('MetricCard works without a bounded height', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Center(
          child: SizedBox(
            width: 200,
            child: MetricCard(title: 'CPU', value: '42.5', unit: '%'),
          ),
        ),
      ),
    );
    expect(find.text('CPU'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MetricCard fits a 176px grid cell at 1.5x text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 176,
          children: const [
            MetricCard(
              title: 'CPU',
              value: '42.5',
              unit: '%',
              caption: '8 cores',
              status: 'running',
              sparkline: SizedBox(height: 28),
            ),
          ],
        ),
        scale: 1.5,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  for (final width in [240.0, 320.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('value is not ellipsized at ${width}dp ${scale}x', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrap(
            const Center(
              child: SizedBox(
                width: 200,
                child: MetricCard(
                  title: 'Network',
                  value: '123.4',
                  unit: 'MB/s',
                  caption: 'down',
                ),
              ),
            ),
            scale: scale,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(
            of: find.byType(MetricCard),
            matching: find.textContaining('123.4', findRichText: true),
          ),
        );
        expect(paragraph.didExceedMaxLines, isFalse);
      });
    }
  }

  for (final width in [240.0, 390.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('network card fits a 136dp cell at ${width}dp ${scale}x', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrap(
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 136 + (scale - 1) * 80,
              children: const [
                MetricCard(
                  title: '网络',
                  value: '0 B/s',
                  caption: '↑ 0 B/s\n累计 3.0 KB',
                  captionMaxLines: 2,
                  status: 'running',
                ),
              ],
            ),
            scale: scale,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.textContaining('累计 3.0 KB', findRichText: true),
          findsOneWidget,
        );
      });
    }
  }
}
