import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../../core/theme/tokens.dart';

enum AppToastType { success, error, warning, info }

abstract final class AppToast {
  static ToastificationItem? _active;

  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    Duration duration = AppTokens.toastDuration,
  }) {
    final toastType = switch (type) {
      AppToastType.success => ToastificationType.success,
      AppToastType.error => ToastificationType.error,
      AppToastType.warning => ToastificationType.warning,
      AppToastType.info => ToastificationType.info,
    };
    final active = _active;
    if (active != null) {
      toastification.dismiss(active, showRemoveAnimation: false);
    }
    _active = toastification.show(
      context: context,
      type: toastType,
      style: ToastificationStyle.flat,
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      showProgressBar: false,
      margin: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 84 + AppTokens.s8,
        left: AppTokens.s16,
        right: AppTokens.s16,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s16,
        vertical: AppTokens.s12,
      ),
      borderRadius: BorderRadius.circular(AppTokens.rMd),
      title: Text(message),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: AppToastType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: AppToastType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message, type: AppToastType.warning);
}
