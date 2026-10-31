import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/states/empty_state.dart';

void main() {
  testWidgets('EmptyState shows title, message and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'Nothing here',
            message: 'No data',
            actionLabel: 'Create',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('No data'), findsOneWidget);
    await tester.tap(find.text('Create'));
    expect(tapped, isTrue);
  });
}
