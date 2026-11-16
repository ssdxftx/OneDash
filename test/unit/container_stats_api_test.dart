import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/dio_client.dart';
import 'package:onedash/data/api/container_api.dart';

class _StatsAdapter implements HttpClientAdapter {
  final List<Map<String, dynamic>?> queries = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    queries.add(
      options.queryParameters.isEmpty
          ? null
          : Map<String, dynamic>.from(options.queryParameters),
    );
    return ResponseBody.fromString(
      jsonEncode({'code': 200, 'data': <dynamic>[]}),
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
  late _StatsAdapter adapter;
  late ContainerApi api;

  setUp(() {
    client = DioClient(
      baseUrl: 'http://127.0.0.1:1',
      apiKey: 'test',
      userAgent: 'test',
    );
    adapter = _StatsAdapter();
    client.raw.httpClientAdapter = adapter;
    api = ContainerApi(client);
  });

  tearDown(() => client.dispose());

  test('container stats only request running container ids', () async {
    await api.getContainerResourceStats(ids: const ['id-1', 'id-2']);
    expect(adapter.queries.single, {'ids': 'id-1,id-2'});
  });

  test('container stats omit ids when no containers are running', () async {
    await api.getContainerResourceStats(ids: const []);
    expect(adapter.queries.single, isNull);
  });
}
