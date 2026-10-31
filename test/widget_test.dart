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
}
