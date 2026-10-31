import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';

void main() {
  testWidgets('theme builds for both brightnesses', (tester) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(brightness),
          home: const Scaffold(body: Text('OneDash')),
        ),
      );
      expect(find.text('OneDash'), findsOneWidget);
    }
  });

  test('accent seed changes the generated primary color', () {
    final forest = AppTheme.build(
      Brightness.light,
      seedColor: const Color(0xFF3F7F5F),
    );
    final ocean = AppTheme.build(
      Brightness.light,
      seedColor: const Color(0xFF2F6F8F),
    );

    expect(forest.colorScheme.primary, isNot(ocean.colorScheme.primary));
  });
}
