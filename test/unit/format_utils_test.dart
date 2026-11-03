import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:onedash/core/localization/generated/app_localizations_en.dart';
import 'package:onedash/core/utils/format_utils.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('en'));
  final l10n = AppLocalizationsEn();
  final now = DateTime.now();

  test('list time uses relative labels within one day', () {
    final time = now.subtract(const Duration(hours: 2));
    expect(formatListTime(time, l10n), l10n.format_relativeHoursAgo(2));
  });

  test('list time keeps hours between one and seven days', () {
    final time = now.subtract(const Duration(days: 2));
    expect(
      formatListTime(time, l10n),
      DateFormat('MM-dd HH:mm', 'en').format(time.toLocal()),
    );
  });

  test('list time switches to an absolute date after seven days', () {
    final time = now.subtract(const Duration(days: 8));
    expect(
      formatListTime(time, l10n),
      formatLocalDateTime(time.toIso8601String(), locale: l10n.localeName),
    );
  });

  test('list time hides null values unless a fallback is supplied', () {
    expect(formatListTime(null, l10n), '');
    expect(formatListTime(null, l10n, fallback: 'raw'), 'raw');
  });
}
