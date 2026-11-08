import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/common/task_log_dto.dart';
import 'package:onedash/presentation/common/components/task_log_sheet.dart';

TaskLogDto _log({
  required bool end,
  required String status,
  List<String> lines = const [],
  int total = 0,
}) => TaskLogDto(
  end: end,
  path: '/opt/1panel/task.log',
  total: total,
  taskStatus: status,
  lines: lines,
  scope: '',
  totalLines: lines.length,
);

Future<void> _openSheet(
  WidgetTester tester,
  TaskLogReader reader, {
  VoidCallback? onFinished,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(Brightness.light),
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showTaskLogSheet(
              context,
              title: '安装应用',
              taskID: 'task-1',
              reader: reader,
              onFinished: onFinished,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('任务日志弹层显示路径、正文与状态', (tester) async {
    var finished = 0;
    await _openSheet(
      tester,
      (_) async => _log(
        end: true,
        status: 'Success',
        lines: const ['step 1', 'step 2'],
        total: 2,
      ),
      onFinished: () => finished++,
    );

    expect(find.text('安装应用'), findsOneWidget);
    expect(find.text('/opt/1panel/task.log'), findsOneWidget);
    expect(find.text('step 1'), findsOneWidget);
    expect(find.text('step 2'), findsOneWidget);
    expect(find.text('成功'), findsOneWidget);
    expect(find.text('2 行'), findsOneWidget);
    expect(finished, 1);

    await tester.tap(find.text('关闭'));
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('执行中每 2 秒轮询，结束后停止并回调一次', (tester) async {
    var calls = 0;
    var finished = 0;
    await _openSheet(tester, (_) async {
      calls++;
      if (calls == 1) {
        return _log(
          end: false,
          status: 'Executing',
          lines: const ['running'],
          total: 1,
        );
      }
      return _log(
        end: true,
        status: 'Success',
        lines: const ['running', 'done'],
        total: 2,
      );
    }, onFinished: () => finished++);

    expect(find.text('执行中'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(calls, 2);
    expect(find.text('done'), findsOneWidget);
    expect(find.text('成功'), findsOneWidget);
    expect(finished, 1);

    await tester.pump(const Duration(seconds: 4));
    expect(calls, 2);

    await tester.tap(find.text('关闭'));
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('上一次请求未返回时定时器不叠加并发请求', (tester) async {
    final first = Completer<TaskLogDto>();
    var calls = 0;
    await _openSheet(tester, (_) {
      calls++;
      return first.future;
    });

    expect(calls, 1);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(calls, 1);

    first.complete(
      _log(end: true, status: 'Success', lines: const ['done'], total: 1),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('done'), findsOneWidget);

    await tester.tap(find.text('关闭'));
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('日志已被清理时显示提示', (tester) async {
    await _openSheet(
      tester,
      (_) async => _log(end: true, status: 'Failed', lines: const [], total: 0),
    );

    expect(find.text('该任务的日志已被清理'), findsOneWidget);

    await tester.tap(find.text('关闭'));
    await tester.pump(const Duration(milliseconds: 600));
  });
}
