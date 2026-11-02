import '../../../core/localization/generated/app_localizations.dart';

String alertTypeLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'cpu' => l10n.alert_type_cpu,
      'memory' || 'ram' => l10n.alert_type_memory,
      'disk' => l10n.alert_type_disk,
      'load' => l10n.alert_type_load,
      'net' || 'network' => l10n.alert_type_network,
      'smart' => l10n.alert_type_smart,
      'log' => l10n.alert_type_log,
      _ => raw,
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
      _ => raw,
    };

String alertLogStatusLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'success' || 'pushsuccess' => l10n.alert_status_success,
      'failed' || 'pushfailed' => l10n.alert_status_failed,
      'pending' => l10n.alert_status_pending,
      _ => raw,
    };

String sslProviderLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'dnsaccount' => l10n.websites_sslProviderDnsAccount,
      'dnsmanual' => l10n.websites_sslProviderDnsManual,
      'http' => l10n.websites_sslProviderHttp,
      'selfsigned' => l10n.websites_sslProviderSelfSigned,
      'manual' || 'upload' => l10n.websites_sslProviderManual,
      'frommaster' => l10n.websites_sslProviderFromMaster,
      _ => raw,
    };

String taskStatusLabel(String raw, AppLocalizations l10n) =>
    switch (raw.toLowerCase()) {
      'success' || 'succeeded' || 'finished' => l10n.alert_status_success,
      'failed' || 'error' => l10n.alert_status_failed,
      'pending' || 'waiting' || 'queued' => l10n.alert_status_pending,
      'running' || 'doing' => l10n.containers_running,
      'stopped' || 'exited' => l10n.containers_stopped,
      _ => raw,
    };
