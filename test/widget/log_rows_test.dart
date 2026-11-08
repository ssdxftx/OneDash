import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/features/log/models/login_log_item.dart';
import 'package:onedash/presentation/features/log/models/operation_log_item.dart';
import 'package:onedash/presentation/features/log/models/ssh_log_item.dart';
import 'package:onedash/presentation/features/log/models/task_log_item.dart';
import 'package:onedash/presentation/features/log/widgets/login_log_row.dart';
import 'package:onedash/presentation/features/log/widgets/operation_log_row.dart';
import 'package:onedash/presentation/features/log/widgets/ssh_log_row.dart';
import 'package:onedash/presentation/features/log/widgets/task_log_row.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget row, {
  double width = 390,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

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
        body: Padding(padding: const EdgeInsets.all(16), child: row),
      ),
    ),
  );
  await tester.pump();
}

OperationLogItem _operation() => OperationLogItem(
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

LoginLogItem _login({bool failed = false, String address = '中国 广东 深圳'}) =>
    LoginLogItem(
      id: 1,
      ip: '203.0.113.8',
      address: address,
      agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
      status: failed ? 'Failed' : 'Success',
      message: failed ? '密码错误' : '',
      createdAt: DateTime(2026, 11, 8, 15, 31, 1),
    );

void main() {
  testWidgets('操作日志行显示中文标题、成功胶囊与到秒时间', (tester) async {
    await _pump(tester, OperationLogRow(item: _operation()));

    expect(find.text('php 版本变更 [domain]'), findsOneWidget);
    expect(find.text('成功'), findsOneWidget);
    expect(find.text('websites'), findsOneWidget);
    expect(find.text('11-08 15:31:01'), findsOneWidget);
    expect(find.textContaining('post /websites'), findsNothing);
  });

  testWidgets('操作日志行在 320dp 1.5 倍字体下不溢出', (tester) async {
    await _pump(
      tester,
      OperationLogRow(item: _operation()),
      width: 320,
      scale: 1.5,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('登录日志行显示归属地、设备名与失败原因', (tester) async {
    await _pump(tester, LoginLogRow(item: _login(failed: true)));

    expect(find.text('203.0.113.8'), findsOneWidget);
    expect(find.text('中国 广东 深圳'), findsOneWidget);
    expect(find.text('macOS'), findsOneWidget);
    expect(find.text('失败'), findsOneWidget);
    expect(find.text('密码错误'), findsOneWidget);
    expect(find.textContaining('Mozilla'), findsNothing);
  });

  testWidgets('登录日志无归属地时仍显示时间且不溢出', (tester) async {
    await _pump(
      tester,
      LoginLogRow(item: _login(address: '')),
      width: 320,
      scale: 1.5,
    );

    expect(find.text('11-08 15:31:01'), findsOneWidget);
    expect(find.text('未知'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SSH 行显示归属地、认证方式与端口', (tester) async {
    final item = SshLogItem(
      date: DateTime(2026, 11, 8, 15, 31, 1),
      dateStr: '',
      area: '中国 广东 深圳',
      user: 'root',
      authMode: 'password',
      address: '203.0.113.8',
      port: '22',
      status: 'Failed',
      message: 'auth failed',
    );
    await _pump(tester, SshLogRow(item: item));

    expect(find.text('root@203.0.113.8'), findsOneWidget);
    expect(find.text('中国 广东 深圳'), findsOneWidget);
    expect(find.text('password'), findsOneWidget);
    expect(find.text(':22'), findsOneWidget);
    expect(find.text('auth failed'), findsOneWidget);
  });

  testWidgets('任务失败行使用列表叉号图标而非对勾', (tester) async {
    final item = TaskLogItem(
      id: '1',
      name: '应用安装',
      operate: 'install',
      status: 'Failed',
      errorMsg: 'install failed',
      currentStep: '',
      createdAt: DateTime(2026, 11, 8, 15, 31, 1),
      endAt: DateTime(2026, 11, 8, 15, 32, 1),
    );
    await _pump(tester, TaskLogRow(item: item));

    final icon = tester.widget<Icon>(
      find
          .descendant(of: find.byType(TaskLogRow), matching: find.byType(Icon))
          .first,
    );
    expect(icon.icon, TablerIcons.playlist_x);
    expect(find.text('install failed'), findsOneWidget);
  });
}
