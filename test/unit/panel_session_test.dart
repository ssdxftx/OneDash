import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/dio_client.dart';
import 'package:onedash/core/network/panel_session.dart';
import 'package:onedash/data/api/setting_api.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.data, this.responseHeaders = const {}});

  final Object? data;
  final Map<String, List<String>> responseHeaders;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'code': 200, 'data': data}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...responseHeaders,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'core auth current returns the full config through the session',
    () async {
      final adapter = _RecordingAdapter(data: {'apiKey': 'full-key'});
      final client = DioClient(
        baseUrl: 'http://127.0.0.1:1',
        apiKey: 'key',
        userAgent: 'test',
        panelSession: const PanelSession(
          sessionId: 'session-1',
          csrfToken: 'csrf-1',
        ),
      );
      addTearDown(client.dispose);
      client.raw.httpClientAdapter = adapter;

      await client.get('/api/v2/core/auth/current');

      final request = adapter.requests.single;
      expect(request.headers['Cookie'], contains('psession=session-1'));
      expect(request.headers.containsKey('1Panel-Token'), isFalse);
    },
  );

  test('session cookie and CSRF are attached to core requests', () async {
    final adapter = _RecordingAdapter(data: {'items': [], 'total': 0});
    final client = DioClient(
      baseUrl: 'http://127.0.0.1:1',
      apiKey: 'key',
      userAgent: 'test',
      panelSession: const PanelSession(
        sessionId: 'session-1',
        csrfToken: 'csrf-1',
      ),
    );
    addTearDown(client.dispose);
    client.raw.httpClientAdapter = adapter;

    await SettingApi(client).searchApiKeys();

    final request = adapter.requests.single;
    expect(request.headers['Cookie'], contains('psession=session-1'));
    expect(request.headers['Cookie'], contains('pcsrftoken=csrf-1'));
    expect(request.headers['X-CSRF-Token'], 'csrf-1');
    expect(request.headers.containsKey('1Panel-Token'), isFalse);
  });

  test(
    'normal agent requests keep API key headers alongside the session',
    () async {
      final adapter = _RecordingAdapter(data: {'ok': true});
      final client = DioClient(
        baseUrl: 'http://127.0.0.1:1',
        apiKey: 'key',
        userAgent: 'test',
        panelSession: const PanelSession(
          sessionId: 'session-1',
          csrfToken: 'csrf-1',
        ),
      );
      addTearDown(client.dispose);
      client.raw.httpClientAdapter = adapter;

      await client.get('/api/v2/hosts/base');

      final request = adapter.requests.single;
      expect(request.headers['Cookie'], contains('psession=session-1'));
      expect(request.headers.containsKey('X-CSRF-Token'), isFalse);
      expect(request.headers['1Panel-Token'], isNotEmpty);
    },
  );

  test('independent API key create sends the 1Panel fields', () async {
    final adapter = _RecordingAdapter(
      data: {
        'item': {'id': 'key-1', 'name': 'deploy', 'revision': 1},
        'apiKey': 'secret',
      },
    );
    final client = DioClient(
      baseUrl: 'http://127.0.0.1:1',
      apiKey: 'key',
      userAgent: 'test',
      panelSession: const PanelSession(
        sessionId: 'session-1',
        csrfToken: 'csrf-1',
      ),
    );
    addTearDown(client.dispose);
    client.raw.httpClientAdapter = adapter;

    final created = await SettingApi(client).createApiKey(
      requestId: 'request-1',
      name: 'deploy',
      apiKeyValidityTime: 30,
    );

    final request = adapter.requests.single;
    expect(request.path, '/api/v2/core/auth/api/keys/create');
    expect(request.headers.containsKey('1Panel-Token'), isFalse);
    expect(request.data['requestID'], 'request-1');
    expect(request.data['name'], 'deploy');
    expect(request.data['apiKeyValidityTime'], 30);
    expect(created.apiKey, 'secret');
  });

  test('login encodes the password and captures the session cookies', () async {
    final adapter = _RecordingAdapter(
      data: {'mfaStatus': 'Disable', 'mfaSession': ''},
      responseHeaders: {
        'set-cookie': [
          'psession=abc; Path=/; HttpOnly',
          'pcsrftoken=csrf; Path=/',
        ],
      },
    );
    final client = DioClient(
      baseUrl: 'http://127.0.0.1:1',
      apiKey: 'key',
      userAgent: 'test',
    );
    addTearDown(client.dispose);
    client.raw.httpClientAdapter = adapter;

    final result = await SettingApi(client).loginPanel(
      name: 'admin',
      password: 'secret',
      language: 'zh',
      entrance: 'entrance-code',
    );

    expect(adapter.requests.first.path, '/api/v2/core/auth/setting');
    final request = adapter.requests.last;
    expect(request.path, '/api/v2/core/auth/login');
    expect(request.headers.containsKey('1Panel-Token'), isFalse);
    expect(request.data['password'], 'secret');
    expect(
      request.headers['EntranceCode'],
      base64Encode(utf8.encode('entrance-code')),
    );
    expect(result.session?.sessionId, 'abc');
    expect(result.session?.csrfToken, 'csrf');
    expect(client.session?.sessionId, 'abc');
  });
}
