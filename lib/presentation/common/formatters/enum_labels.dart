import 'package:flutter/foundation.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../data/dto/website/website_ssl_dto.dart';

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
      'runtime' => l10n.websites_runtime,
      'deployment' => l10n.websites_deployment,
      'subsite' => l10n.websites_subsite,
      'stream' => l10n.websites_tunnel,
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

String sslDisplayName(WebsiteSslDto ssl, AppLocalizations l10n) {
  final domain = ssl.primaryDomain.isEmpty
      ? l10n.websites_sslFallbackName(ssl.id)
      : ssl.primaryDomain;
  final suffix = ssl.provider.isEmpty ? ssl.type : ssl.provider;
  return suffix.isEmpty ? domain : '$domain · $suffix';
}

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

/// 面板菜单标题映射。1Panel 的 HideMenu 存的是 i18n key，App 无法直接翻译，
/// 已知项使用本地文案，未知项回退到可读的 label。
String panelMenuLabel(String title, String label, AppLocalizations l10n) {
  final value = switch (title) {
    'menu.home' => l10n.nav_overview,
    'menu.apps' => l10n.more_group_apps,
    'menu.aiTools' => l10n.ai_title,
    'aiTools.gpu.gpu' => l10n.ai_gpu,
    'aiTools.model.services' => l10n.ai_models,
    'aiTools.agents.agent' => l10n.ai_agents,
    'menu.mcp' => l10n.ai_mcp,
    'menu.website' => l10n.websites_title,
    'menu.ssl' => l10n.websites_sslCertificate,
    'menu.template' => l10n.websites_templates,
    'menu.runtime' => l10n.websites_runtime,
    'menu.database' => l10n.databases_title,
    'menu.container' => l10n.nav_containers,
    'xpack.vm.vm' => l10n.vm_title,
    'menu.system' => l10n.host_title,
    'menu.files' => l10n.nav_files,
    'menu.monitor' => l10n.host_monitor,
    'menu.firewall' => l10n.more_firewall,
    'menu.processManage' => l10n.more_process,
    'menu.ssh' => l10n.host_ssh,
    'menu.disk' => l10n.host_disks,
    'menu.terminal' => l10n.more_terminal,
    'menu.cronjob' => l10n.more_cronjobs,
    'menu.toolbox' => l10n.toolbox_title,
    'menu.logs' => l10n.logs_title,
    'menu.settings' => l10n.more_panel_settings,
    _ => null,
  };
  if (value != null) return value;
  return _humanizeMenuLabel(label.isNotEmpty ? label : title);
}

String _humanizeMenuLabel(String value) {
  var text = value.trim();
  if (text.isEmpty) return '';
  if (text.contains('.')) text = text.split('.').last;
  text = text.replaceAll(RegExp(r'[-_]+'), ' ');
  text = text.replaceAll(RegExp(r'\s*Menu$'), '');
  text = text.replaceAllMapped(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), (_) => ' ');
  text = text.replaceAllMapped(RegExp(r'(?<=[A-Z])(?=[A-Z][a-z])'), (_) => ' ');
  return text.trim();
}

/// 未覆盖的枚举值：上屏「未知」，debug 下打印原值方便补映射。
String _unknown(String raw, AppLocalizations l10n) {
  assert(() {
    debugPrint('[enum_labels] unmapped value: $raw');
    return true;
  }());
  return l10n.common_unknown;
}
