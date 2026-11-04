import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/buttons.dart';

void main() {
  testWidgets('non-expanded buttons keep long labels inside a row', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: Row(
            children: [
              DangerButton(
                expanded: false,
                icon: Icons.delete,
                label: 'Delete this very long resource name',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
