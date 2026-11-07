import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/simple_form_page.dart';

void main() {
  testWidgets('renders fields and invokes the footer save action', (
    tester,
  ) async {
    var saved = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SimpleFormPage(
          title: 'Edit port',
          subtitle: 'demo',
          onSave: () async => saved++,
          children: const [Text('Port'), TextField()],
        ),
      ),
    );

    expect(find.text('Edit port'), findsOneWidget);
    expect(find.text('demo'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saved, 1);
  });

  testWidgets('fits 320dp at 1.3x text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: SimpleFormPage(
          title: 'Create database',
          subtitle: 'mysql',
          onSave: () async {},
          children: const [TextField()],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('showFormSheet opens a bottom sheet at the configured height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showFormSheet<void>(
                context,
                title: 'Quick edit',
                children: const [TextField()],
                onSave: () async {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(FormSheet), findsOneWidget);
    final route = ModalRoute.of(tester.element(find.byType(FormSheet)));
    expect(route, isA<ModalBottomSheetRoute<void>>());
    expect(find.byType(TextField), findsOneWidget);
    final box = tester.getRect(find.byType(FormSheet));
    expect(box.height, closeTo(844 * 0.74, 1));
  });
}
