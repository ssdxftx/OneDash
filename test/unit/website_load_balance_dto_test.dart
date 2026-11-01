import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/website/website_load_balance_dto.dart';

void main() {
  test('load balance DTO parses servers and preserves request field names', () {
    final dto = WebsiteLoadBalanceDto.fromJson({
      'name': 'api',
      'algorithm': 'least_conn',
      'servers': [
        {
          'server': '127.0.0.1:8080',
          'weight': 2,
          'failTimeout': 15,
          'failTimeoutUnit': 's',
          'maxFails': 4,
          'maxConns': 100,
          'flag': 'backup',
        },
      ],
    });

    expect(dto.name, 'api');
    expect(dto.algorithm, 'least_conn');
    expect(dto.servers.single.weight, 2);
    expect(dto.servers.single.flag, 'backup');

    final req = WebsiteLoadBalanceReq(
      websiteId: 7,
      name: dto.name,
      algorithm: dto.algorithm,
      servers: dto.servers,
    );
    expect(req.toJson(), {
      'websiteID': 7,
      'name': 'api',
      'algorithm': 'least_conn',
      'servers': [
        {
          'server': '127.0.0.1:8080',
          'weight': 2,
          'failTimeout': 15,
          'failTimeoutUnit': 's',
          'maxFails': 4,
          'maxConns': 100,
          'flag': 'backup',
        },
      ],
    });
  });

  test('load balance DTO tolerates a null data list', () {
    final empty = WebsiteLoadBalanceDto.fromJson({});
    expect(empty.name, isEmpty);
    expect(empty.servers, isEmpty);
  });
}
