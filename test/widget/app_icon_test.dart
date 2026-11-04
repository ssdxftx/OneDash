import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/app_icon.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.build(Brightness.light),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('falls back to the first letter when the icon is missing', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const AppIcon(name: 'redis')));
    expect(find.text('R'), findsOneWidget);
  });

  testWidgets('decodes a data URI base64 icon', (tester) async {
    const pixel =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
        'YAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
    await tester.pumpWidget(
      wrap(const AppIcon(name: 'redis', icon: 'data:image/png;base64,$pixel')),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('uses the full rune for emoji initials', (tester) async {
    await tester.pumpWidget(wrap(const AppIcon(name: '🚀 rocket')));
    expect(find.text('🚀'), findsOneWidget);
  });

  testWidgets('falls back for malformed base64 payloads', (tester) async {
    await tester.pumpWidget(
      wrap(const AppIcon(name: 'redis', icon: 'not-base64')),
    );
    await tester.pump();
    expect(find.text('R'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
