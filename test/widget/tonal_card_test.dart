import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/buttons.dart';
import 'package:onedash/presentation/common/components/tonal_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.build(Brightness.light),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('TonalCard renders child and handles tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(TonalCard(onTap: () => tapped = true, child: const Text('hello'))),
    );
    expect(find.text('hello'), findsOneWidget);
    await tester.tap(find.text('hello'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('PrimaryButton shows spinner while loading', (tester) async {
    await tester.pumpWidget(
      _wrap(const PrimaryButton(label: 'Save', loading: true)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('DangerButton is disabled when onPressed is null', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const DangerButton(label: 'Delete')));
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
