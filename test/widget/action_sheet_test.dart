import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/action_sheet.dart';

void main() {
  Widget build({double scale = 1, VoidCallback? onDisabledTap}) {
    return MaterialApp(
      theme: AppTheme.build(Brightness.light),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: ActionSheetScaffold(
            infoCard: const ActionSheetInfoCard(
              leading: Icon(Icons.inbox),
              title: 'demo-container',
              subtitle: 'nginx:alpine',
              trailing: ActionSheetStatusPill(
                label: 'Running',
                color: Colors.green,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionSheetSection(
                  title: 'Lifecycle',
                  icon: Icons.play_arrow,
                  children: [
                    ActionSheetRow(
                      icon: Icons.play_arrow,
                      iconColor: Colors.green,
                      title: 'Start',
                      onTap: () {},
                    ),
                    ActionSheetRow(
                      icon: Icons.pause,
                      iconColor: Colors.orange,
                      title: 'Pause',
                      enabled: false,
                      onTap: onDisabledTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders section, info card and rows', (tester) async {
    await tester.pumpWidget(build());
    expect(find.text('Lifecycle'), findsOneWidget);
    expect(find.text('demo-container'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
  });

  testWidgets('disabled row ignores taps', (tester) async {
    var tapped = false;
    await tester.pumpWidget(build(onDisabledTap: () => tapped = true));
    await tester.tap(find.text('Pause'));
    expect(tapped, isFalse);
  });

  testWidgets('fits 320dp at 1.3x text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(build(scale: 1.3));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('long action lists scroll instead of overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final rows = List.generate(
      20,
      (index) => ActionSheetRow(
        icon: Icons.delete,
        iconColor: Colors.red,
        title: 'Action $index',
        onTap: () {},
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              height: 640,
              child: ActionSheetScaffold(
                infoCard: const ActionSheetInfoCard(
                  leading: Icon(Icons.inbox),
                  title: 'demo-container',
                  subtitle: 'nginx:alpine',
                ),
                child: ActionSheetSection(
                  title: 'Lifecycle',
                  icon: Icons.play_arrow,
                  children: rows,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Action 19'), 200);
    expect(find.text('Action 19'), findsOneWidget);
  });
}
