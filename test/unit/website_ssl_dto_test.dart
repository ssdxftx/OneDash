import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/website/website_detail_dto.dart';
import 'package:onedash/data/dto/website/website_ssl_dto.dart';

void main() {
  test('zero-value SSL payload is not treated as bound', () {
    final detail = WebsiteDetailDto.fromJson({
      'id': 1,
      'webSiteSSLId': 0,
      'webSiteSSL': {
        'id': 0,
        'primaryDomain': '',
        'provider': '',
        'type': '',
        'status': '',
        'expireDate': '0001-01-01T00:00:00Z',
      },
    });
    expect(detail.isSslBound, isFalse);
  });

  test('bound SSL requires a non-zero certificate id', () {
    final detail = WebsiteDetailDto.fromJson({
      'id': 1,
      'webSiteSSLId': 9,
      'webSiteSSL': {
        'id': 9,
        'primaryDomain': 'example.com',
        'provider': 'http',
        'type': 'dv',
        'status': 'ready',
        'expireDate': '2026-03-01T00:00:00Z',
      },
    });
    expect(detail.isSslBound, isTrue);
    expect(detail.ssl?.primaryDomain, 'example.com');
  });

  test('parses Go-encoded and list domains', () {
    expect(
      WebsiteSslDto.fromJson({
        'id': 1,
        'domains': '["example.com","www.example.com"]',
      }).domains,
      ['example.com', 'www.example.com'],
    );
    expect(
      WebsiteSslDto.fromJson({
        'id': 1,
        'domains': ['a.com', 'b.com'],
      }).domains,
      ['a.com', 'b.com'],
    );
  });
}
