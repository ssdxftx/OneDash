import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';

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
}
