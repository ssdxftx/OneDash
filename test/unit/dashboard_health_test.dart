import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations_zh.dart';
import 'package:onedash/presentation/features/dashboard/utils/dashboard_health.dart';

void main() {
  group('healthScore', () {
    test('healthy machine scores 100', () {
      final score = healthScore(
        cpuPercent: 10,
        memoryPercent: 20,
        diskPercent: 30,
        load1: 0.5,
        cores: 8,
      );
      expect(score, 100);
    });

    test('cpu above 80 is penalized at 1.2 per point, capped at 30', () {
      final score = healthScore(
        cpuPercent: 100,
        memoryPercent: 0,
        diskPercent: 0,
        load1: 0,
        cores: 8,
      );
      expect(score, 76);
    });

    test('memory above 85 is penalized at 1.5 per point, capped at 25', () {
      final score = healthScore(
        cpuPercent: 0,
        memoryPercent: 100,
        diskPercent: 0,
        load1: 0,
        cores: 8,
      );
      expect(score, 77.5);
    });

    test('disk above 90 is penalized at 2 per point, capped at 25', () {
      final score = healthScore(
        cpuPercent: 0,
        memoryPercent: 0,
        diskPercent: 100,
        load1: 0,
        cores: 8,
      );
      expect(score, 80);
    });

    test('load ratio above 1.5 is penalized at 10 per ratio, capped at 20', () {
      final score = healthScore(
        cpuPercent: 0,
        memoryPercent: 0,
        diskPercent: 0,
        load1: 28,
        cores: 8,
      );
      expect(score, 80);
    });

    test('score is clamped to zero', () {
      final score = healthScore(
        cpuPercent: 110,
        memoryPercent: 110,
        diskPercent: 110,
        load1: 30,
        cores: 8,
      );
      expect(score, 0);
    });

    test('zero cores does not divide by zero', () {
      final score = healthScore(
        cpuPercent: 0,
        memoryPercent: 0,
        diskPercent: 0,
        load1: 10,
        cores: 0,
      );
      expect(score, 100);
    });
  });

  group('formatUptime', () {
    test('days and hours', () {
      expect(
        formatUptime(3 * 86400 + 4 * 3600 + 30, AppLocalizationsZh()),
        '3天 4小时',
      );
    });

    test('hours and minutes', () {
      expect(formatUptime(2 * 3600 + 5 * 60, AppLocalizationsZh()), '2小时 5分钟');
    });

    test('minutes only', () {
      expect(formatUptime(90, AppLocalizationsZh()), '1分钟');
    });
  });
}
