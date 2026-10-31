import 'package:flutter/material.dart';
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
}
