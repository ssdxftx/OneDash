import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/network/network_exceptions.dart';
import '../../../core/theme/tokens.dart';

@immutable
class ErrorViewData {
  const ErrorViewData({
    required this.icon,
    required this.title,
    required this.message,
    this.detail,
    this.actionLabel,
    this.secondaryActionLabel,
    this.kind = ErrorKind.unknown,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? detail;
  final String? actionLabel;
  final String? secondaryActionLabel;
  final ErrorKind kind;
}

enum ErrorKind {
  auth,
  network,
  certificate,
  server,
  notFound,
  format,
  business,
  unknown,
}

ErrorViewData mapError(Object error, AppLocalizations l10n) {
  final raw = error.toString();
  if (error is AuthException) {
    return ErrorViewData(
      icon: TablerIcons.lock,
      title: l10n.error_auth_title,
      message: l10n.error_auth_message,
      detail: raw,
      actionLabel: l10n.common_retry,
      secondaryActionLabel: l10n.server_edit_edit_title,
      kind: ErrorKind.auth,
    );
  }
  if (error is NetworkConnectionException) {
    if (error.code != null) {
      return ErrorViewData(
        icon: TablerIcons.cloud_off,
        title: l10n.error_network_title,
        message: switch (error.code!) {
          NetworkErrorCode.wsPreflightFailed => l10n.error_wsPreflightFailed,
          NetworkErrorCode.wsPreflightTimeout => l10n.error_wsPreflightTimeout,
        },
        detail: raw,
        actionLabel: l10n.common_retry,
        kind: ErrorKind.network,
      );
    }
    final isCertificate =
        raw.toLowerCase().contains('certificate') ||
        raw.toLowerCase().contains('handshake') ||
        raw.toLowerCase().contains('tls');
    if (isCertificate) {
      return ErrorViewData(
        icon: TablerIcons.shield_lock,
        title: l10n.error_cert_title,
        message: l10n.error_cert_message,
        detail: raw,
        actionLabel: l10n.common_retry,
        kind: ErrorKind.certificate,
      );
    }
    return ErrorViewData(
      icon: TablerIcons.cloud_off,
      title: l10n.error_network_title,
      message: l10n.error_network_message,
      detail: raw,
      actionLabel: l10n.common_retry,
      kind: ErrorKind.network,
    );
  }
  if (error is ServerException) {
    return ErrorViewData(
      icon: TablerIcons.server_off,
      title: l10n.error_server_title,
      message: l10n.error_server_message(error.statusCode ?? 500),
      detail: raw,
      actionLabel: l10n.common_retry,
      kind: ErrorKind.server,
    );
  }
  if (error is RecordNotFoundException) {
    return ErrorViewData(
      icon: TablerIcons.plug_off,
      title: l10n.error_not_found_title,
      message: l10n.error_not_found_message,
      kind: ErrorKind.notFound,
    );
  }
  if (error is ServerNotFoundException) {
    return ErrorViewData(
      icon: TablerIcons.server_off,
      title: l10n.error_server_title,
      message: l10n.error_server_missing_message,
      actionLabel: l10n.common_retry,
      kind: ErrorKind.server,
    );
  }
  if (error is HttpException) {
    if (error.statusCode == 404 || error.statusCode == 405) {
      return ErrorViewData(
        icon: TablerIcons.plug_off,
        title: l10n.error_not_found_title,
        message: l10n.error_not_found_message,
        detail: raw,
        kind: ErrorKind.notFound,
      );
    }
    return ErrorViewData(
      icon: TablerIcons.alert_triangle,
      title: l10n.error_request_title,
      message: l10n.error_request_message,
      detail: raw,
      actionLabel: l10n.common_retry,
      kind: ErrorKind.business,
    );
  }
  if (error is ApiBusinessException && error.statusCode == 401) {
    return ErrorViewData(
      icon: TablerIcons.lock,
      title: l10n.error_auth_title,
      message: l10n.error_auth_message,
      actionLabel: l10n.common_retry,
      secondaryActionLabel: l10n.server_edit_edit_title,
      kind: ErrorKind.auth,
    );
  }
  if (error is ApiBusinessException) {
    return ErrorViewData(
      icon: TablerIcons.alert_triangle,
      title: l10n.error_business_title,
      message: error.message.isEmpty
          ? l10n.error_unknown_message
          : error.message,
      detail: raw,
      actionLabel: l10n.common_retry,
      kind: ErrorKind.business,
    );
  }
  if (error is ApiFormatException) {
    return ErrorViewData(
      icon: TablerIcons.file_alert,
      title: l10n.error_format_title,
      message: l10n.error_format_message,
      detail: raw,
      actionLabel: l10n.common_retry,
      kind: ErrorKind.format,
    );
  }
  if (error is TaskFailedException) {
    final detail = error.detail.trim();
    final title = error.timedOut
        ? l10n.task_timeoutTitle
        : l10n.task_failedTitle;
    final message = switch ((error.timedOut, detail.isEmpty)) {
      (true, _) => l10n.task_timeoutMessage,
      (false, true) => l10n.task_failedNoDetail,
      (false, false) => detail,
    };
    return ErrorViewData(
      icon: TablerIcons.alert_triangle,
      title: title,
      message: message,
      detail: raw,
      actionLabel: l10n.common_retry,
      kind: ErrorKind.business,
    );
  }
  return ErrorViewData(
    icon: TablerIcons.alert_circle,
    title: l10n.error_unknown_title,
    message: l10n.error_unknown_message,
    detail: raw,
    actionLabel: l10n.common_retry,
    kind: ErrorKind.unknown,
  );
}

Color errorColor(BuildContext context, ErrorKind kind) {
  return switch (kind) {
    ErrorKind.auth || ErrorKind.certificate => context.appColors.warning,
    ErrorKind.network || ErrorKind.server => context.appColors.danger,
    _ => context.appColors.danger,
  };
}
