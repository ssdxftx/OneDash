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

  test('SSL providers are localized and unknown values pass through', () {
    expect(sslProviderLabel('dnsAccount', l10n), 'DNS account');
    expect(sslProviderLabel('selfSigned', l10n), 'Self-signed');
    expect(sslProviderLabel('manual', l10n), 'Uploaded');
    expect(sslProviderLabel('upload', l10n), 'Uploaded');
    expect(sslProviderLabel('custom', l10n), 'custom');
  });

  test('backup account types are localized', () {
    expect(backupAccountTypeLabel('LOCAL', l10n), 'Local');
    expect(backupAccountTypeLabel('oss', l10n), 'Alibaba Cloud OSS');
    expect(backupAccountTypeLabel('s3', l10n), 'S3');
    expect(backupAccountTypeLabel('KODO', l10n), 'Qiniu Kodo');
    expect(backupAccountTypeLabel('upyun', l10n), 'UPYUN');
    expect(backupAccountTypeLabel('aliyun', l10n), 'Aliyun Drive');
    expect(backupAccountTypeLabel('GoogleDrive', l10n), 'Google Drive');
    expect(backupAccountTypeLabel('custom', l10n), 'custom');
  });

  test('backup account types match the panel contract', () {
    expect(backupAccountTypes, hasLength(11));
    expect(backupAccountLocal, 'LOCAL');
    for (final type in backupAccountTypes) {
      expect(backupAccountTypes.where((item) => item == type), hasLength(1));
      expect(type, isNot(equals(backupAccountLocal)));
    }
    expect(backupAccountTypes, contains('OneDrive'));
    expect(backupAccountTypes, contains('GoogleDrive'));
  });

  test('backup account types normalize to canonical casing', () {
    expect(canonicalBackupAccountType('local'), 'LOCAL');
    expect(canonicalBackupAccountType('ONEDRIVE'), 'OneDrive');
    expect(canonicalBackupAccountType('googledrive'), 'GoogleDrive');
    expect(canonicalBackupAccountType('minio'), 'MINIO');
    expect(canonicalBackupAccountType('unknown'), 'S3');
  });

  test('cronjob types are localized with raw fallback', () {
    expect(cronjobTypeLabel('shell', l10n), 'Shell script');
    expect(cronjobTypeLabel('Website', l10n), 'Back up website');
    expect(cronjobTypeLabel('snapshot', l10n), 'Snapshot');
    expect(cronjobTypeLabel('custom', l10n), 'custom');
  });

  test('task status labels cover snapshot and backup states', () {
    expect(taskStatusLabel('Success', l10n), 'Success');
    expect(taskStatusLabel('failed', l10n), 'Failed');
    expect(taskStatusLabel('running', l10n), 'Running');
    expect(taskStatusLabel('Mystery', l10n), 'Mystery');
  });
}
