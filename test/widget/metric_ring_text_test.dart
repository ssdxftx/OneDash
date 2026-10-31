import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/metric_card.dart';

void main() {
  Widget wrap(Widget child, double scale) {
    return MaterialApp(
      theme: AppTheme.build(Brightness.light),
      builder: (context, appChild) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: appChild!,
      ),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('ring default text stays inside the inner circle at 2x', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const MetricRing(value: 100, label: 'Health'), 2),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('100%'), findsOneWidget);
    final size = tester.getSize(
      find.descendant(
        of: find.byType(MetricRing),
        matching: find.byType(FittedBox),
      ),
    );
    expect(size.width, lessThanOrEqualTo(48));
    expect(size.height, lessThanOrEqualTo(48));
  });

  testWidgets('ring custom center stays inside the inner circle at 2x', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const MetricRing(
          value: 100,
          label: 'Health',
          center: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('100'), Text('优')],
          ),
        ),
        2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final size = tester.getSize(
      find.descendant(
        of: find.byType(MetricRing),
        matching: find.byType(FittedBox),
      ),
    );
    expect(size.width, lessThanOrEqualTo(48));
    expect(size.height, lessThanOrEqualTo(48));
  });
}
