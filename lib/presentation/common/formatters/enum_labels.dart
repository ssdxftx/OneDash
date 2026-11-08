import 'package:flutter/foundation.dart';

import '../../../core/localization/generated/app_localizations.dart';

/// 1Panel 备份账号类型常量，服务端按大写精确匹配。
const backupAccountTypes = <String>[
  'S3',
  'OSS',
  'SFTP',
  'MINIO',
  'COS',
  'KODO',
  'UPYUN',
  'ALIYUN',
  'OneDrive',
  'WebDAV',
  'GoogleDrive',
];
const backupAccountLocal = 'LOCAL';

String canonicalBackupAccountType(String raw) {
  final value = raw.trim();
  if (value.toLowerCase() == backupAccountLocal.toLowerCase()) {
    return backupAccountLocal;
  }
  for (final type in backupAccountTypes) {
    if (type.toLowerCase() == value.toLowerCase()) return type;
  }
  return backupAccountTypes.first;
}

String alertTypeLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'cpu' => l10n.alert_type_cpu,
      'memory' || 'ram' => l10n.alert_type_memory,
      'disk' => l10n.alert_type_disk,
      'load' => l10n.alert_type_load,
      'net' || 'network' => l10n.alert_type_network,
      'smart' => l10n.alert_type_smart,
      'log' => l10n.alert_type_log,
      _ => _unknown(raw, l10n),
    };

String alertMethodLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'email' || 'smtp' => l10n.alert_method_email,
      'telegram' => l10n.alert_method_telegram,
      'wecom' || 'wechat' => l10n.alert_method_wecom,
      'dingtalk' => l10n.alert_method_dingtalk,
      'feishu' || 'lark' => l10n.alert_method_feishu,
      'bark' => l10n.alert_method_bark,
      'webhook' => l10n.alert_method_webhook,
      'sms' => l10n.alert_method_sms,
      _ => _unknown(raw, l10n),
    };

String alertLogStatusLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'success' || 'pushsuccess' => l10n.alert_status_success,
      'failed' || 'pushfailed' => l10n.alert_status_failed,
      'pending' => l10n.alert_status_pending,
      _ => _unknown(raw, l10n),
    };

String websiteTypeLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'static' => l10n.websites_static,
      'proxy' || 'reverse_proxy' => l10n.websites_proxy,
      'php' => l10n.websites_php,
      _ => _unknown(raw, l10n),
    };

String sslStatusLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'ready' || 'issued' => l10n.websites_sslStatusReady,
      'applied' || 'deployed' => l10n.websites_sslStatusApplied,
      'init' || 'pending' || 'processing' => l10n.websites_sslStatusPending,
      'error' || 'failed' => l10n.websites_sslStatusError,
      _ => _unknown(raw, l10n),
    };

String sslProviderLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'dnsaccount' => l10n.websites_sslProviderDnsAccount,
      'dnsmanual' => l10n.websites_sslProviderDnsManual,
      'http' => l10n.websites_sslProviderHttp,
      'selfsigned' => l10n.websites_sslProviderSelfSigned,
      'manual' || 'upload' => l10n.websites_sslProviderManual,
      'frommaster' => l10n.websites_sslProviderFromMaster,
      _ => _unknown(raw, l10n),
    };

String taskStatusLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'success' || 'succeeded' || 'finished' => l10n.alert_status_success,
      'failed' || 'error' => l10n.alert_status_failed,
      'pending' || 'waiting' || 'queued' => l10n.alert_status_pending,
      'running' || 'doing' => l10n.containers_running,
      'stopped' || 'exited' => l10n.containers_stopped,
      _ => _unknown(raw, l10n),
    };

String cronjobTypeLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'shell' => l10n.cronjobs_typeShell,
      'log' => l10n.cronjobs_typeLog,
      'curl' => l10n.cronjobs_typeCurl,
      'website' => l10n.cronjobs_typeWebsite,
      'database' => l10n.cronjobs_typeDatabase,
      'directory' => l10n.cronjobs_typeDirectory,
      'app' => l10n.cronjobs_typeApp,
      'snapshot' => l10n.cronjobs_typeSnapshot,
      'cleanlog' => l10n.cronjobs_typeCleanLog,
      'clean' => l10n.cronjobs_typeClean,
      'ntp' => l10n.cronjobs_typeNtp,
      _ => _unknown(raw, l10n),
    };

String backupAccountTypeLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'local' => l10n.backups_typeLocal,
      'sftp' => l10n.backups_typeSftp,
      's3' => l10n.backups_typeS3,
      'oss' => l10n.backups_typeOss,
      'cos' => l10n.backups_typeCos,
      'minio' => l10n.backups_typeMinio,
      'onedrive' => l10n.backups_typeOneDrive,
      'webdav' => l10n.backups_typeWebdav,
      'kodo' => l10n.backups_typeKodo,
      'upyun' => l10n.backups_typeUpyun,
      'aliyun' => l10n.backups_typeAliyun,
      'googledrive' => l10n.backups_typeGoogleDrive,
      _ => _unknown(raw, l10n),
    };

/// 未覆盖的枚举值：上屏「未知」，debug 下打印原值方便补映射。
String _unknown(String raw, AppLocalizations l10n) {
  assert(() {
    debugPrint('[enum_labels] unmapped value: $raw');
    return true;
  }());
  return l10n.common_unknown;
}
