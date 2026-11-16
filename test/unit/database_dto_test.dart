import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/database/database_instance_dto.dart';

void main() {
  test('Redis persistence maps appendonly and save fields', () {
    final persistence = RedisPersistenceDto.fromJson({
      'database': 'redis',
      'appendonly': 'yes',
      'appendfsync': 'always',
      'save': '3600 1',
    });
    expect(persistence.aofEnabled, 'yes');
    expect(persistence.rdbEnabled, 'yes');
    expect(persistence.appendfsync, 'always');
    expect(persistence.save, '3600 1');
  });

  test('Redis persistence disables rdb when save is empty', () {
    final persistence = RedisPersistenceDto.fromJson({
      'appendonly': 'no',
      'save': '',
    });
    expect(persistence.aofEnabled, 'no');
    expect(persistence.rdbEnabled, 'no');
  });
}
