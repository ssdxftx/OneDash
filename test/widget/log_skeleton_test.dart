import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/common/components/tonal_card.dart';
import 'package:onedash/presentation/features/log/models/login_log_item.dart';
import 'package:onedash/presentation/features/log/models/operation_log_item.dart';
import 'package:onedash/presentation/features/log/models/ssh_log_item.dart';
import 'package:onedash/presentation/features/log/models/task_log_item.dart';
import 'package:onedash/presentation/features/log/widgets/login_log_row.dart';
import 'package:onedash/presentation/features/log/widgets/log_row_skeleton.dart';
import 'package:onedash/presentation/features/log/widgets/operation_log_row.dart';
import 'package:onedash/presentation/features/log/widgets/ssh_log_row.dart';
import 'package:onedash/presentation/features/log/widgets/task_log_row.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(Brightness.light),
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(child: SizedBox(width: 390, child: child)),
      ),
    ),
  );
  await tester.pump();
}

Future<double> _height(WidgetTester tester, Widget child) async {
  await _pump(tester, child);
  return tester.getSize(find.byType(TonalCard).first).height;
}

void main() {
  testWidgets('操作日志骨架与真卡同构且高度差不超过 1dp', (tester) async {
    final real = await _height(
      tester,
      OperationLogRow(
        item: OperationLogItem(
          id: 1,
          source: 'websites',
          method: 'post',
          path: '/websites/php/version',
          status: 'Success',
          message: '',
          detailZH: '应用商店同步',
          detailEN: 'Sync app store',
          createdAt: DateTime(2026, 11, 8, 15, 31, 1),
        ),
      ),
    );
    final skeleton = await _height(
      tester,
      const LogRowSkeletonCard(style: LogSkeletonStyle.operation),
    );
    expect((real - skeleton).abs(), lessThanOrEqualTo(1));
  });

  testWidgets('登录日志骨架与真卡同构且高度差不超过 1dp', (tester) async {
    final real = await _height(
      tester,
      LoginLogRow(
        item: LoginLogItem(
          id: 1,
          ip: '203.0.113.8',
          address: '中国 广东 深圳',
          agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
          status: 'Success',
          message: '',
          createdAt: DateTime(2026, 11, 8, 15, 31, 1),
        ),
      ),
    );
    final skeleton = await _height(
      tester,
      const LogRowSkeletonCard(style: LogSkeletonStyle.login),
    );
    expect((real - skeleton).abs(), lessThanOrEqualTo(1));
  });

  testWidgets('SSH 日志骨架与真卡同构且高度差不超过 1dp', (tester) async {
    final real = await _height(
      tester,
      SshLogRow(
        item: SshLogItem(
          date: DateTime(2026, 11, 8, 15, 31, 1),
          dateStr: '',
          area: '中国 广东 深圳 南山区',
          user: 'root',
          authMode: 'password',
          address: '203.0.113.8',
          port: '22',
          status: 'Success',
          message: '',
        ),
      ),
    );
    final skeleton = await _height(
      tester,
      const LogRowSkeletonCard(style: LogSkeletonStyle.ssh),
    );
    expect((real - skeleton).abs(), lessThanOrEqualTo(1));
  });

  testWidgets('任务日志骨架与真卡同构且高度差不超过 1dp', (tester) async {
    final real = await _height(
      tester,
      TaskLogRow(
        item: TaskLogItem(
          id: '1',
          name: '应用安装',
          operate: 'install',
          status: 'Success',
          errorMsg: '',
          currentStep: '',
          createdAt: DateTime(2026, 11, 8, 15, 31, 1),
          endAt: DateTime(2026, 11, 8, 15, 32, 1),
        ),
      ),
    );
    final skeleton = await _height(
      tester,
      const LogRowSkeletonCard(style: LogSkeletonStyle.task),
    );
    expect((real - skeleton).abs(), lessThanOrEqualTo(1));
  });
}
