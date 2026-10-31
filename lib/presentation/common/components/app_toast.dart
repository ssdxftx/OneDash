import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum AppToastType { success, error, warning, info }

abstract final class AppToast {
  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    final toastType = switch (type) {
      AppToastType.success => ToastificationType.success,
      AppToastType.error => ToastificationType.error,
      AppToastType.warning => ToastificationType.warning,
      AppToastType.info => ToastificationType.info,
    };
    toastification.show(
      context: context,
      type: toastType,
      style: ToastificationStyle.flat,
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      showProgressBar: false,
      margin: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 12,
        left: 16,
        right: 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(14),
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
