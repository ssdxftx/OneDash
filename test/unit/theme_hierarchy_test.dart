import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/core/theme/tokens.dart';

void main() {
  test('text theme sizes step down without inversion', () {
    final text = AppTheme.build(Brightness.light).textTheme;
    final sizes = [
      text.displayLarge!.fontSize!,
      text.displayMedium!.fontSize!,
      text.displaySmall!.fontSize!,
      text.headlineLarge!.fontSize!,
      text.headlineMedium!.fontSize!,
      text.headlineSmall!.fontSize!,
      text.titleLarge!.fontSize!,
      text.titleMedium!.fontSize!,
      text.titleSmall!.fontSize!,
    ];
    for (var i = 1; i < sizes.length; i++) {
      expect(sizes[i], lessThan(sizes[i - 1]));
    }
  });

  test('sheet emphasis curve never moves backwards', () {
    var previous = 0.0;
    for (var step = 1; step <= 100; step++) {
      final value = AppTokens.curveEmphasis.transform(step / 100);
      expect(value, greaterThanOrEqualTo(previous));
      previous = value;
    }
  });

  test('input corners use the 14dp step below cards', () {
    for (final brightness in Brightness.values) {
      final input = AppTheme.build(brightness).inputDecorationTheme;
      final borders = [
        input.border,
        input.enabledBorder,
        input.focusedBorder,
        input.errorBorder,
        input.focusedErrorBorder,
      ];
      for (final border in borders) {
        final radius = (border! as OutlineInputBorder).borderRadius.resolve(
          TextDirection.ltr,
        );
        expect(radius.topLeft.x, AppTokens.rMd);
      }
      expect(AppTokens.rSm, lessThan(AppTokens.rMd));
      expect(AppTokens.rMd, lessThan(AppTokens.rLg));
      expect(AppTokens.rLg, lessThan(AppTokens.rSheet));
    }
  });
}
