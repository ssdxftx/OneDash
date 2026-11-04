import 'package:flutter/services.dart';

const _channel = MethodChannel('dev.onedash.app/secure_screen');

/// Toggles the Android FLAG_SECURE screenshot block. No-op on platforms
/// without the host implementation (iOS, desktop, widget tests).
Future<void> setSecureScreen(bool enabled) async {
  try {
    await _channel.invokeMethod<void>('setSecure', enabled);
  } on MissingPluginException {
    return;
  } on PlatformException {
    return;
  }
}
