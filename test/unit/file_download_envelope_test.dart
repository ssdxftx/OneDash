import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/dio_client.dart';
import 'package:onedash/core/network/network_exceptions.dart';
import 'package:onedash/data/api/file_api.dart';

import '../support/fake_panel.dart';

void main() {
  test('byte downloads surface business error envelopes', () async {
    final panel = await FakePanel.start(scenario: 'businessError');
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
      FileApi(client).downloadBytes(path: '/tmp/demo'),
      throwsA(isA<ApiBusinessException>()),
    );
  });

  test('file downloads surface business error envelopes', () async {
    final panel = await FakePanel.start(scenario: 'businessError');
    final client = DioClient(
      baseUrl: 'http://127.0.0.1:${panel.port}',
      apiKey: 'test',
      userAgent: 'test',
    );
    final target = File(
      '${Directory.systemTemp.path}/onedash-download-${DateTime.now().microsecondsSinceEpoch}',
    );
    addTearDown(() async {
      client.dispose();
      await panel.close();
      if (target.existsSync()) await target.delete();
    });

    await expectLater(
      client.download('/api/v2/files/download', savePath: target.path),
      throwsA(isA<ApiBusinessException>()),
    );
  });

  test('depth size matches the requested directory', () async {
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

    expect(await FileApi(client).getDepthSize('/data/'), 99);
    expect(await FileApi(client).getDepthSize('/missing'), 0);
  });
}
