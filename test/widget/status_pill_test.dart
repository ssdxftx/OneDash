import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/core/theme/tokens.dart';
import 'package:onedash/presentation/common/components/status_pill.dart';

double _contrastRatio(Color foreground, Color background) {
  final l1 = foreground.computeLuminance();
  final l2 = background.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  testWidgets('pill text keeps 4.5:1 on its own tint', (tester) async {
    for (final brightness in Brightness.values) {
      final scheme = AppTheme.schemeFor(brightness);
      final colors = brightness == Brightness.light
          ? OneDashColors.light
          : OneDashColors.dark;
      final tones = {
        'success': colors.success,
        'warning': colors.warning,
        'danger': colors.danger,
      };
      for (final entry in tones.entries) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.build(brightness),
            themeAnimationDuration: Duration.zero,
            home: Scaffold(
              body: Center(
                child: StatusPill(label: 'X', tone: entry.value),
              ),
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('X')).style!.color!;
        final deco =
            tester
                    .widget<Container>(
                      find
                          .descendant(
                            of: find.byType(StatusPill),
                            matching: find.byType(Container),
                          )
                          .first,
                    )
                    .decoration!
                as BoxDecoration;
        final fill = Color.alphaBlend(deco.color!, scheme.surfaceContainerLow);

        expect(
          _contrastRatio(text, fill),
          greaterThanOrEqualTo(4.5),
          reason: '$brightness ${entry.key} pill text',
        );
      }
    }
  });
}
