import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 网络与交互相关的全局设置。
///
/// 外观设置由 `themeControllerProvider` 独立管理，避免网络层依赖 UI 主题。
class AppSettings {
  const AppSettings({
    this.requestTimeoutSeconds = 60,
    this.customHeaders = const {},
    this.hapticsEnabled = true,
    this.listAnimationsEnabled = true,
    this.secureScreenEnabled = false,
  });

  final int requestTimeoutSeconds;
  final Map<String, String> customHeaders;
  final bool hapticsEnabled;
  final bool listAnimationsEnabled;
  final bool secureScreenEnabled;

  AppSettings copyWith({
    int? requestTimeoutSeconds,
    Map<String, String>? customHeaders,
    bool? hapticsEnabled,
    bool? listAnimationsEnabled,
    bool? secureScreenEnabled,
  }) {
    return AppSettings(
      requestTimeoutSeconds:
          requestTimeoutSeconds ?? this.requestTimeoutSeconds,
      customHeaders: customHeaders ?? this.customHeaders,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      listAnimationsEnabled:
          listAnimationsEnabled ?? this.listAnimationsEnabled,
      secureScreenEnabled: secureScreenEnabled ?? this.secureScreenEnabled,
    );
  }
}

final appSettingsControllerProvider =
    AsyncNotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
      name: 'appSettingsControllerProvider',
    );

class AppSettingsController extends AsyncNotifier<AppSettings> {
  static const defaultRequestTimeoutSeconds = 60;
  static const _timeoutKey = 'settings_request_timeout_seconds';
  static const _headersKey = 'settings_custom_headers';
  static const _hapticsKey = 'settings_haptics_enabled';
  static const _listAnimationsKey = 'settings_list_animations_enabled';
  static const _secureScreenKey = 'settings_secure_screen_enabled';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      requestTimeoutSeconds:
          prefs.getInt(_timeoutKey) ?? defaultRequestTimeoutSeconds,
      customHeaders: _decodeHeaders(prefs.getString(_headersKey)),
      hapticsEnabled: prefs.getBool(_hapticsKey) ?? true,
      listAnimationsEnabled: prefs.getBool(_listAnimationsKey) ?? true,
      secureScreenEnabled: prefs.getBool(_secureScreenKey) ?? false,
    );
  }

  Future<void> setHapticsEnabled(bool value) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(hapticsEnabled: value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, value);
  }

  Future<void> setListAnimationsEnabled(bool value) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(listAnimationsEnabled: value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_listAnimationsKey, value);
  }

  Future<void> setSecureScreenEnabled(bool value) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(secureScreenEnabled: value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_secureScreenKey, value);
  }

  Future<void> setRequestTimeoutSeconds(int seconds) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(requestTimeoutSeconds: seconds));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeoutKey, seconds);
  }

  static Map<String, String> _decodeHeaders(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    } on FormatException {
      return const {};
    }
    return const {};
  }
}
