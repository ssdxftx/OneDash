import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/core/theme/tokens.dart';

double contrastRatio(Color foreground, Color background) {
  final l1 = foreground.computeLuminance();
  final l2 = background.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('semantic colors meet 4.5:1 on light surface', () {
    final scheme = AppTheme.schemeFor(Brightness.light);
    const colors = OneDashColors.light;
    final pairs = <String, Color>{
      'success': colors.success,
      'warning': colors.warning,
      'danger': scheme.error,
      'info': colors.info,
    };
    for (final entry in pairs.entries) {
      final ratio = contrastRatio(entry.value, scheme.surface);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: '${entry.key} ratio $ratio',
      );
    }
  });

  test('semantic colors meet 4.5:1 on dark surface', () {
    final scheme = AppTheme.schemeFor(Brightness.dark);
    const colors = OneDashColors.dark;
    final pairs = <String, Color>{
      'success': colors.success,
      'warning': colors.warning,
      'danger': scheme.error,
      'info': colors.info,
    };
    for (final entry in pairs.entries) {
      final ratio = contrastRatio(entry.value, scheme.surface);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: '${entry.key} ratio $ratio',
      );
    }
  });

  test('OLED dark theme uses pure black surfaces', () {
    final scheme = AppTheme.schemeFor(Brightness.dark, oled: true);
    expect(scheme.surface, Colors.black);
    expect(scheme.surfaceContainerLowest, Colors.black);
  });

  test('body text meets 4.5:1 on both surfaces', () {
    for (final brightness in Brightness.values) {
      final scheme = AppTheme.schemeFor(brightness);
      final ratio = contrastRatio(scheme.onSurface, scheme.surface);
      expect(ratio, greaterThanOrEqualTo(4.5));
    }
  });

  test('input hint keeps 4.5:1 against its fill', () {
    for (final brightness in Brightness.values) {
      final input = AppTheme.build(brightness).inputDecorationTheme;
      final hint = input.hintStyle!.color!;
      final fill = input.fillColor!;
      final blended = Color.alphaBlend(hint, fill);
      final ratio = contrastRatio(blended, fill);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: '$brightness hint ratio $ratio',
      );
    }
  });
}
