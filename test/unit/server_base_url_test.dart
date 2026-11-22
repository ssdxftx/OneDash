import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/domain/entities/server.dart';

void main() {
  test('baseUrl formats IPv4, IPv6 and ports', () {
    final ipv4 = Server()
      ..host = '127.0.0.1'
      ..port = 9999;
    final ipv6 = Server()
      ..host = '::1'
      ..port = 9999
      ..isHttps = true;

    expect(ipv4.baseUrl.toString(), 'http://127.0.0.1:9999');
    expect(ipv6.baseUrl.toString(), 'https://[::1]:9999');
  });
}
