import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/network/network_exceptions.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/task_progress_sheet.dart';

void main() {
  Widget host(TaskRunner task) {
    return MaterialApp(
      theme: AppTheme.build(Brightness.light),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: TaskProgressSheet(title: 'Container task', task: task),
      ),
    );
  }

  testWidgets('shows success and closes', (tester) async {
    await tester.pumpWidget(host((controller) async {}));
    await tester.pump();
    expect(find.text('Container task'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows panel log line on failure', (tester) async {
    await tester.pumpWidget(
      host(
        (controller) async => throw const TaskFailedException(
          subject: 'Container task',
          detail: 'image not found',
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('image not found'), findsOneWidget);
    expect(find.textContaining('Task failed'), findsOneWidget);
  });

  testWidgets('running state exposes background continue', (tester) async {
    final completer = Completer<void>();
    await tester.pumpWidget(host((controller) => completer.future));
    await tester.pump();
    expect(find.text('Running…'), findsOneWidget);
    expect(find.text('Continue in background'), findsOneWidget);
    completer.complete();
    await tester.pump();
  });
}
