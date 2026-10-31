import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/core/theme/theme_controller.dart';

double _hueDistance(Color a, Color b) {
  final ha = HSLColor.fromColor(a).hue;
  final hb = HSLColor.fromColor(b).hue;
  final diff = (ha - hb).abs();
  return math.min(diff, 360 - diff);
}

double _channelDistance(Color a, Color b) {
  final dr = (a.r - b.r) * 255;
  final dg = (a.g - b.g) * 255;
  final db = (a.b - b.b) * 255;
  return math.sqrt(dr * dr + dg * dg + db * db);
}

void main() {
  test('eight accent presets produce distinguishable primaries', () {
    final primaries = {
      for (final preset in AccentPreset.values)
        preset: AppTheme.schemeFor(
          Brightness.light,
          seedColor: preset.color,
        ).primary,
    };

    expect(primaries.values.toSet().length, AccentPreset.values.length);

    final presets = primaries.keys.toList();
    for (var i = 0; i < presets.length; i++) {
      for (var j = i + 1; j < presets.length; j++) {
        final a = primaries[presets[i]]!;
        final b = primaries[presets[j]]!;
        expect(
          _hueDistance(a, b) >= 8 || _channelDistance(a, b) >= 12,
          isTrue,
          reason: '${presets[i].name} and ${presets[j].name} look too close',
        );
      }
    }
  });
}
