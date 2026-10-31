import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'generated/app_localizations.dart';
import '../storage/storage_service.dart';

part 'locale_controller.g.dart';

enum AppLocaleOption { system, zh, en }

@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  static const _key = 'app_locale';

  @override
  AppLocaleOption build() {
    final storage = ref.watch(storageServiceProvider);
    return _decode(storage.getString(_key));
  }

  Future<void> setOption(AppLocaleOption option) async {
    state = option;
    final storage = ref.read(storageServiceProvider);
    if (option == AppLocaleOption.system) {
      await storage.remove(_key);
    } else {
      await storage.setString(_key, option.name);
    }
  }

  static AppLocaleOption _decode(String? raw) {
    return switch (raw) {
      'zh' => AppLocaleOption.zh,
      'en' => AppLocaleOption.en,
      _ => AppLocaleOption.system,
    };
  }
}

@Riverpod(keepAlive: true)
AppLocalizations appLocalizations(Ref ref) {
  final option = ref.watch(localeControllerProvider);
  final locale =
      option.toLocale() ?? WidgetsBinding.instance.platformDispatcher.locale;
  final effectiveLocale =
      AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      )
      ? Locale(locale.languageCode)
      : const Locale('zh');

  return lookupAppLocalizations(effectiveLocale);
}

extension AppLocaleOptionX on AppLocaleOption {
  Locale? toLocale() => switch (this) {
    AppLocaleOption.system => null,
    AppLocaleOption.zh => const Locale('zh'),
    AppLocaleOption.en => const Locale('en'),
  };

  String labelOf(AppLocalizations l10n) => switch (this) {
    AppLocaleOption.system => l10n.common_systemDefault,
    AppLocaleOption.zh => '简体中文',
    AppLocaleOption.en => 'English',
  };

  String widgetLocaleCode(Locale platformLocale) {
    final locale = toLocale() ?? platformLocale;
    return locale.languageCode == 'en' ? 'en' : 'zh';
  }
}
