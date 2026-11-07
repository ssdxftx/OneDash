import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/presentation/features/log/log_parser.dart';

void main() {
  test('parses nginx combined access lines', () {
    final parsed = parseLogLine(
      '203.0.113.10 - - [05/Nov/2026:06:10:12 +0800] '
      '"GET /api/health HTTP/1.1" 200 1200 "-" "curl/8.0" 0.012',
    );
    expect(parsed.format, LogFormat.nginxAccess);
    expect(parsed.status, 200);
    expect(parsed.method, 'GET');
    expect(parsed.path, '/api/health');
    expect(parsed.ip, '203.0.113.10');
    expect(parsed.bytes, 1200);
    expect(parsed.userAgent, 'curl/8.0');
    expect(parsed.duration, '0.012s');
    expect(parsed.level, LogLevel.info);
  });

  test('maps access status codes to levels and paths', () {
    for (final (status, level, path) in [
      (200, LogLevel.info, '/ok'),
      (404, LogLevel.warn, '/missing'),
      (500, LogLevel.error, '/boom'),
    ]) {
      final parsed = parseLogLine(
        '10.0.0.1 - - [05/Nov/2026:06:10:12 +0800] '
        '"POST $path HTTP/1.1" $status 12 "-" "agent"',
      );
      expect(parsed.status, status);
      expect(parsed.level, level);
      expect(parsed.path, path);
    }
  });

  test('parses nginx error lines and keeps the message', () {
    final parsed = parseLogLine(
      '2026/11/05 06:10:12 [error] 123#0: *45 connect() failed, '
      'client: 1.2.3.4, request: "GET /x HTTP/1.1", upstream: "http://10.0.0.2:80"',
    );
    expect(parsed.format, LogFormat.nginxError);
    expect(parsed.level, LogLevel.error);
    expect(parsed.ip, '1.2.3.4');
    expect(parsed.upstream, 'http://10.0.0.2:80');
    expect(parsed.message, contains('connect() failed'));
  });

  test('keeps JSON lines as-is when structured fields exist', () {
    final parsed = parseLogLine(
      '{"level":"warn","message":"disk low","time":"2026-03-01T10:00:00Z"}',
    );
    expect(parsed.format, LogFormat.json);
    expect(parsed.level, LogLevel.warn);
    expect(parsed.message, 'disk low');
    expect(parsed.time, '2026-03-01T10:00:00Z');
  });

  test('parses XFF when the log adds a third quoted field', () {
    final parsed = parseLogLine(
      '203.0.113.10 - - [05/Nov/2026:06:10:12 +0800] '
      '"GET /api/health HTTP/1.1" 200 1200 "-" "curl/8.0" '
      '"198.51.100.7, 203.0.113.10" 0.012',
    );
    expect(parsed.format, LogFormat.nginxAccess);
    expect(parsed.xff, '198.51.100.7, 203.0.113.10');
    expect(parsed.duration, '0.012s');
  });

  test('falls back to the original line on unknown formats', () {
    const raw = 'plain text with no timestamp';
    final parsed = parseLogLine(raw);
    expect(parsed.format, LogFormat.plain);
    expect(parsed.message, raw);
  });
}
