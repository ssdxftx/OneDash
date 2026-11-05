import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';

void main() {
  testWidgets('chip labels keep a visible colour', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: Column(
            children: [
              const Chip(label: Text('chip')),
              ActionChip(label: const Text('action'), onPressed: () {}),
              InputChip(label: const Text('input'), onSelected: (_) {}),
              FilterChip(label: const Text('filter'), onSelected: (_) {}),
            ],
          ),
        ),
      ),
    );

    for (final label in ['chip', 'action', 'input', 'filter']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
      final colour = paragraph.text.style?.color;
      expect(colour, isNotNull, reason: '$label label colour');
      expect(colour!.computeLuminance(), lessThan(0.5), reason: label);
    }
  });
}
