import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/dio_client.dart';
import 'package:onedash/core/network/network_exceptions.dart';

import '../support/fake_panel.dart';

void main() {
  test('empty scenario returns an empty page', () async {
    final panel = await FakePanel.start(scenario: 'empty');
    final client = DioClient(
      baseUrl: 'http://127.0.0.1:${panel.port}',
      apiKey: 'test',
      userAgent: 'test',
    );
    addTearDown(() async {
      client.dispose();
      await panel.close();
    });

    final response = await client.get<Map<String, dynamic>>(
      '/api/v2/websites/search',
    );
    expect(response.data?['data']?['total'], 0);
  });

  test('error scenario becomes a server exception', () async {
    final panel = await FakePanel.start(scenario: 'error');
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
      client.get<Map<String, dynamic>>('/api/v2/websites/search'),
      throwsA(isA<ServerException>()),
    );
  });

  test('unauthorized scenario becomes an auth exception', () async {
    final panel = await FakePanel.start(scenario: 'unauthorized');
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
      client.get<Map<String, dynamic>>('/api/v2/websites/search'),
      throwsA(isA<AuthException>()),
    );
  });
}
