import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/charts/area_chart.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.build(Brightness.light),
    home: Scaffold(
      body: Center(child: SizedBox(width: 160, height: 28, child: child)),
    ),
  );

  testWidgets('empty sparkline shows the collecting placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const Sparkline(values: [], placeholder: 'Collecting…')),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Collecting…'), findsOneWidget);
  });

  testWidgets('single sample still shows the placeholder', (tester) async {
    await tester.pumpWidget(
      wrap(const Sparkline(values: [1], placeholder: 'Collecting…')),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Collecting…'), findsOneWidget);
  });

  testWidgets('three samples draw the line without the placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const Sparkline(values: [1, 2, 3], placeholder: 'Collecting…')),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Collecting…'), findsNothing);
  });

  testWidgets('unlabeled sparkline draws no dashed divider', (tester) async {
    await tester.pumpWidget(wrap(const Sparkline(values: [])));

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(Sparkline),
        matching: find.byType(CustomPaint),
      ),
      findsNothing,
    );
  });

  testWidgets('area chart shows the collecting placeholder below 3 samples', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 160,
              child: AreaChart(
                seriesA: [0],
                seriesB: [0],
                placeholder: 'Collecting…',
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Collecting…'), findsOneWidget);
  });

  testWidgets('area chart draws normally with 3 samples', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 160,
              child: AreaChart(
                seriesA: [1, 2, 3],
                seriesB: [1, 2, 3],
                placeholder: 'Collecting…',
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Collecting…'), findsNothing);
  });

  testWidgets('area chart morphs between same-length series', (tester) async {
    var series = <double>[1, 2, 3];
    late StateSetter setHost;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              setHost = setState;
              return Center(
                child: SizedBox(
                  width: 300,
                  height: 160,
                  child: AreaChart(seriesA: series),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final before =
        tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(AreaChart),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter
            as dynamic;
    final beforeSeries = List<double>.from(before.seriesA as List<double>);

    setHost(() => series = [3, 2, 1]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final middle =
        tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(AreaChart),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter
            as dynamic;
    final middleSeries = List<double>.from(middle.seriesA as List<double>);
    expect(middleSeries, isNot(equals(beforeSeries)));
    expect(middleSeries, isNot(equals([3.0, 2.0, 1.0])));

    await tester.pumpAndSettle();
    final after =
        tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(AreaChart),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter
            as dynamic;
    expect(after.seriesA, [3.0, 2.0, 1.0]);
  });
}
