import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations_en.dart';
import 'package:onedash/presentation/common/formatters/enum_labels.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('alert type labels are localized and unknown values pass through', () {
    expect(alertTypeLabel('CPU', l10n), 'CPU');
    expect(alertTypeLabel('memory', l10n), 'Memory');
    expect(alertTypeLabel('custom', l10n), 'custom');
  });

  test('alert method labels cover aliases', () {
    expect(alertMethodLabel('wecom', l10n), 'WeCom');
    expect(alertMethodLabel('smtp', l10n), 'Email');
    expect(alertMethodLabel('unknown-channel', l10n), 'unknown-channel');
  });

  test('alert log status labels cover push results', () {
    expect(alertLogStatusLabel('Failed', l10n), 'Failed');
    expect(alertLogStatusLabel('PushSuccess', l10n), 'Success');
    expect(alertLogStatusLabel('Mystery', l10n), 'Mystery');
  });
}
