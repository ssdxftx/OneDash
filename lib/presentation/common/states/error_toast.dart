import 'package:flutter/widgets.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../components/app_toast.dart';
import 'error_mapper.dart';

/// Turns any exception into one user-facing line that never leaks transport or
/// stack details.
String describeError(Object error, AppLocalizations l10n) {
  final data = mapError(error, l10n);
  final message = data.message.trim();
  if (message.isEmpty) return data.title;
  return '${data.title}：$message';
}

void showErrorToast(BuildContext context, Object error, {String? prefix}) {
  final l10n = AppLocalizations.of(context);
  final text = describeError(error, l10n);
  AppToast.error(context, prefix == null ? text : '$prefix：$text');
}
