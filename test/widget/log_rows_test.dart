import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/features/log/models/operation_log_item.dart';
import 'package:onedash/presentation/features/log/widgets/operation_log_row.dart';

void main() {
  Future<void> pumpRow(
    WidgetTester tester, {
    double width = 390,
    double scale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final item = OperationLogItem(
      id: 1,
      source: 'websites',
      method: 'post',
      path: '/websites/php/version',
      status: 'Success',
      message: '',
      detailZH: 'php 版本变更 [domain]',
      detailEN: 'Change PHP version',
      createdAt: DateTime(2026, 11, 8, 15, 31, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: OperationLogRow(item: item),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('操作日志行显示中文标题、成功胶囊与到秒时间', (tester) async {
    await pumpRow(tester);

    expect(find.text('php 版本变更 [domain]'), findsOneWidget);
    expect(find.text('成功'), findsOneWidget);
    expect(find.text('websites'), findsOneWidget);
    expect(find.text('11-08 15:31:01'), findsOneWidget);
    expect(find.textContaining('post /websites'), findsNothing);
  });

  testWidgets('操作日志行在 320dp 1.5 倍字体下不溢出', (tester) async {
    await pumpRow(tester, width: 320, scale: 1.5);
    expect(tester.takeException(), isNull);
  });
}
