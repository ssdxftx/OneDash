import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/data/dto/dashboard/dashboard_dto.dart';

void main() {
  group('DashboardDto.parseCurrent', () {
    test('parses diskData entries', () {
      final current = DashboardDto.parseCurrent({
        'cpuUsedPercent': 12.5,
        'memoryUsedPercent': 30,
        'diskData': [
          {
            'path': '/',
            'device': '/dev/vda1',
            'type': 'ext4',
            'total': 1000,
            'used': 250,
            'usedPercent': 25,
          },
        ],
      });

      expect(current.cpuUsedPercent, 12.5);
      expect(current.disks, hasLength(1));
      expect(current.disks.first.path, '/');
      expect(current.disks.first.used, 250);
      expect(current.disks.first.usedPercent, 25);
    });

    test('accepts legacy disks key as fallback', () {
      final current = DashboardDto.parseCurrent({
        'disks': [
          {'path': '/data', 'total': 200, 'used': 50, 'usedPercent': 25},
        ],
      });

      expect(current.disks, hasLength(1));
      expect(current.disks.first.path, '/data');
    });

    test('missing fields fall back to zero or empty values', () {
      final current = DashboardDto.parseCurrent(const {});

      expect(current.cpuUsedPercent, 0);
      expect(current.disks, isEmpty);
      expect(current.topCpuItems, isEmpty);
    });
  });
}
