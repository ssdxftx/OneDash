import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/dio_client.dart';
import 'package:onedash/data/api/log_api.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.data = const {'total': 0, 'items': <dynamic>[]}});

  final Object data;
  final List<Map<String, dynamic>> bodies = [];
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    bodies.add(Map<String, dynamic>.from(options.data as Map));
    return ResponseBody.fromString(
      jsonEncode({'code': 200, 'data': data}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late DioClient client;
  late _RecordingAdapter adapter;
  late LogApi api;

  setUp(() {
    client = DioClient(
      baseUrl: 'http://127.0.0.1:1',
      apiKey: 'test',
      userAgent: 'test',
    );
    adapter = _RecordingAdapter();
    client.raw.httpClientAdapter = adapter;
    api = LogApi(client);
  });

  tearDown(() => client.dispose());

  test('SSH 日志空 status 兜底为 All', () async {
    await api.searchSshLogs(status: '');
    expect(adapter.bodies.single['Status'], 'All');
    expect(adapter.bodies.single.containsKey('info'), isFalse);
  });

  test('SSH 日志显式 status 原样发送', () async {
    await api.searchSshLogs(status: 'Failed', info: 'root');
    expect(adapter.bodies.single['Status'], 'Failed');
    expect(adapter.bodies.single['info'], 'root');
  });

  test('SSH 导出空 status 兜底为 All', () async {
    client.raw.httpClientAdapter = _RecordingAdapter(data: '/tmp/ssh.csv');
    adapter = client.raw.httpClientAdapter as _RecordingAdapter;
    await api.exportSshLogs(status: '');
    expect(adapter.paths.single, '/api/v2/hosts/ssh/log/export');
    expect(adapter.bodies.single['Status'], 'All');
  });
}
