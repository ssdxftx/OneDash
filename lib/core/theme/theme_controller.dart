import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_service.dart';

enum AppThemeMode {
  system('system'),
  light('light'),
  dark('dark');

  const AppThemeMode(this.storageName);

  final String storageName;

  ThemeMode get themeMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  static AppThemeMode fromName(String? name) => values.firstWhere(
    (mode) => mode.storageName == name,
    orElse: () => AppThemeMode.system,
  );
}

enum AccentPreset {
  forest('forest', Color(0xFF3F7F5F)),
  ocean('ocean', Color(0xFF2F6F8F)),
  indigo('indigo', Color(0xFF4A5DA7)),
  violet('violet', Color(0xFF7A5FA8)),
  rose('rose', Color(0xFFA8586F)),
  amber('amber', Color(0xFFB07A3C)),
  teal('teal', Color(0xFF3F8F86)),
  graphite('graphite', Color(0xFF5F6368));

  const AccentPreset(this.storageName, this.color);

  final String storageName;
  final Color color;

  static AccentPreset fromName(String? name) => values.firstWhere(
    (preset) => preset.storageName == name,
    orElse: () => AccentPreset.forest,
  );
}

@immutable
class ThemeSettings {
  const ThemeSettings({
    this.mode = AppThemeMode.system,
    this.accent = AccentPreset.forest,
    this.dynamicColor = false,
    this.oled = false,
    this.textScale = 1.0,
  });

  final AppThemeMode mode;
  final AccentPreset accent;
  final bool dynamicColor;
  final bool oled;
  final double textScale;

  ThemeSettings copyWith({
    AppThemeMode? mode,
    AccentPreset? accent,
    bool? dynamicColor,
    bool? oled,
    double? textScale,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      accent: accent ?? this.accent,
      dynamicColor: dynamicColor ?? this.dynamicColor,
      oled: oled ?? this.oled,
      textScale: textScale ?? this.textScale,
    );
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeSettings>(
      ThemeController.new,
      name: 'themeControllerProvider',
    );

class ThemeController extends Notifier<ThemeSettings> {
  static const _modeKey = 'theme_mode';
  static const _accentKey = 'theme_accent';
  static const _dynamicKey = 'theme_dynamic_color';
  static const _oledKey = 'theme_oled';
  static const _textScaleKey = 'theme_text_scale';

  @override
  ThemeSettings build() {
    final storage = ref.watch(storageServiceProvider);
    return ThemeSettings(
      mode: AppThemeMode.fromName(storage.getString(_modeKey)),
      accent: AccentPreset.fromName(storage.getString(_accentKey)),
      dynamicColor: storage.getString(_dynamicKey) == 'true',
      oled: storage.getString(_oledKey) == 'true',
      textScale: double.tryParse(storage.getString(_textScaleKey) ?? '') ?? 1.0,
    );
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await ref
        .read(storageServiceProvider)
        .setString(_modeKey, mode.storageName);
  }

  Future<void> setAccent(AccentPreset accent) async {
    state = state.copyWith(accent: accent);
    await ref
        .read(storageServiceProvider)
        .setString(_accentKey, accent.storageName);
  }

  Future<void> setDynamicColor(bool enabled) async {
    state = state.copyWith(dynamicColor: enabled);
    await ref
        .read(storageServiceProvider)
        .setString(_dynamicKey, enabled.toString());
  }

  Future<void> setOled(bool enabled) async {
    state = state.copyWith(oled: enabled);
    await ref
        .read(storageServiceProvider)
        .setString(_oledKey, enabled.toString());
  }

  Future<void> setTextScale(double scale) async {
    final clamped = scale.clamp(0.9, 1.25);
    state = state.copyWith(textScale: clamped);
    await ref
        .read(storageServiceProvider)
        .setString(_textScaleKey, clamped.toString());
  }
}

extension AppThemeModeX on AppThemeMode {
  String label(BuildContext context) {
    final l10n = MaterialLocalizations.of(context);
    return switch (this) {
      AppThemeMode.system => l10n.okButtonLabel == 'OK' ? 'System' : '跟随系统',
      AppThemeMode.light => l10n.okButtonLabel == 'OK' ? 'Light' : '浅色',
      AppThemeMode.dark => l10n.okButtonLabel == 'OK' ? 'Dark' : '深色',
    };
  }
}

Color seedOf(ThemeSettings settings) => settings.accent.color;
