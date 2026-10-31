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
}
