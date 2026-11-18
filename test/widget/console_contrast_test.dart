import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/core/theme/tokens.dart';
import 'package:onedash/presentation/common/components/console_app_bar.dart';

double _contrastRatio(Color foreground, Color background) {
  final l1 = foreground.computeLuminance();
  final l2 = background.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  testWidgets('console app bar keeps readable text in light theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          appBar: ConsoleAppBar(title: 'Connecting', subtitle: 'demo-host'),
        ),
      ),
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, AppTokens.consoleBackground);

    final title = tester.widget<Text>(find.text('Connecting')).style!.color!;
    expect(title, AppTokens.consoleForeground);
    expect(
      _contrastRatio(title, AppTokens.consoleBackground),
      greaterThanOrEqualTo(7),
    );

    final subtitle = tester.widget<Text>(find.text('demo-host')).style!.color!;
    expect(
      _contrastRatio(subtitle, AppTokens.consoleBackground),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('console toolbar buttons stay visible when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          backgroundColor: AppTokens.consoleToolbar,
          body: Center(child: ConsoleToolbarButton(label: 'Ctrl+C')),
        ),
      ),
    );

    final button = tester.widget<TextButton>(find.byType(TextButton));
    final enabled = button.style!.foregroundColor!.resolve({})!;
    final disabled = button.style!.foregroundColor!.resolve({
      WidgetState.disabled,
    })!;

    expect(enabled, AppTokens.consoleForeground);
    expect(disabled, AppTokens.consoleMuted);
    expect(
      _contrastRatio(enabled, AppTokens.consoleToolbar),
      greaterThanOrEqualTo(7),
    );
    expect(
      _contrastRatio(disabled, AppTokens.consoleToolbar),
      greaterThanOrEqualTo(3),
    );
  });
}
