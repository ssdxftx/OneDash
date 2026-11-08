import 'package:flutter/foundation.dart';

import '../../../core/localization/generated/app_localizations.dart';

/// 应用/容器状态是后端开放字符串，已知值本地化，未知值保留原值避免丢信息。
String appStatusLabel(String status, AppLocalizations l10n) {
  return switch (status.toLowerCase()) {
    'running' => l10n.common_running,
    'stopped' || 'exited' || 'created' => l10n.common_stopped,
    'installing' || 'upgrading' => l10n.common_installing,
    'restarting' => l10n.common_restarting,
    'paused' => l10n.common_paused,
    'unhealthy' || 'error' || 'failed' || 'dead' => l10n.common_abnormal,
    '' => l10n.common_unknown,
    _ => _passthrough(status, 'appStatusLabel'),
  };
}

/// 容器状态是 Docker 开放字符串，已知值本地化，未知值保留原值。
String containerStateLabel(String state, AppLocalizations l10n) {
  return switch (state.toLowerCase()) {
    'running' => l10n.common_running,
    'exited' || 'stopped' || 'created' => l10n.common_stopped,
    'paused' => l10n.common_paused,
    'restarting' => l10n.common_restarting,
    'removing' => l10n.common_removing,
    'dead' => l10n.common_abnormal,
    '' => l10n.common_unknown,
    _ => _passthrough(state, 'containerStateLabel'),
  };
}

/// SSH 认证方式是开放字符串，已知值本地化，未知值保留原值。
String sshAuthModeLabel(String mode, AppLocalizations l10n) {
  return switch (mode.toLowerCase()) {
    'password' => l10n.databases_password,
    'publickey' || 'public_key' || 'key' => l10n.host_publicKey,
    '' => mode,
    _ => _passthrough(mode, 'sshAuthModeLabel'),
  };
}

String _passthrough(String raw, String source) {
  assert(() {
    debugPrint('[$source] unmapped value: $raw');
    return true;
  }());
  return raw;
}
