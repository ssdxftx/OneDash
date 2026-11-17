import '../../../core/localization/generated/app_localizations.dart';

String websiteStatusLabel(String status, AppLocalizations l10n) {
  return switch (status.toLowerCase()) {
    'running' => l10n.websites_running,
    'stopped' => l10n.websites_stopped,
    _ => l10n.common_unknown,
  };
}
