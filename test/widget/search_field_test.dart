import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/search_field.dart';

void main() {
  testWidgets('clear action follows controller text without page rebuilds', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SearchField(controller: controller, onChanged: changes.add),
        ),
      ),
    );

    expect(find.byIcon(TablerIcons.x), findsNothing);

    await tester.enterText(find.byType(TextField), 'nginx');
    await tester.pump();
    expect(find.byIcon(TablerIcons.x), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(find.byIcon(TablerIcons.x), findsNothing);
    expect(changes, ['nginx', '']);
  });
}
