import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/dio_client.dart';
import 'package:onedash/core/network/network_exceptions.dart';
import 'package:onedash/data/api/task_waiter.dart';

import '../support/fake_panel.dart';

void main() {
  test('Success 状态直接结束等待', () async {
    final panel = await FakePanel.start();
    final client = DioClient(
      baseUrl: 'http://127.0.0.1:${panel.port}',
      apiKey: 'test',
      userAgent: 'test',
    );
    addTearDown(() async {
      client.dispose();
      await panel.close();
    });

    await TaskWaiter(client, maxAttempts: 2).waitFor('task-1');
  });

  test('Failed 状态抛出最后一行任务日志', () async {
    final panel = await FakePanel.start(scenario: 'taskFailed');
    final client = DioClient(
      baseUrl: 'http://127.0.0.1:${panel.port}',
      apiKey: 'test',
      userAgent: 'test',
    );
    addTearDown(() async {
      client.dispose();
      await panel.close();
    });

    await expectLater(
      TaskWaiter(
        client,
        interval: Duration.zero,
        maxAttempts: 2,
      ).waitFor('task-2'),
      throwsA(
        isA<TaskFailedException>()
            .having((error) => error.timedOut, 'timedOut', isFalse)
            .having(
              (error) => error.detail,
              'detail',
              contains('image not found'),
            ),
      ),
    );
  });

  test('Executing 超过等待次数后抛出超时异常', () async {
    final panel = await FakePanel.start(scenario: 'taskRunning');
    final client = DioClient(
      baseUrl: 'http://127.0.0.1:${panel.port}',
      apiKey: 'test',
      userAgent: 'test',
    );
    addTearDown(() async {
      client.dispose();
      await panel.close();
    });

    await expectLater(
      TaskWaiter(
        client,
        interval: Duration.zero,
        maxAttempts: 2,
      ).waitFor('task-3'),
      throwsA(
        isA<TaskFailedException>().having(
          (error) => error.timedOut,
          'timedOut',
          isTrue,
        ),
      ),
    );
  });
}
