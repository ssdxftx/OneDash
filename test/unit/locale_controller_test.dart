import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/locale_controller.dart';
import 'package:onedash/core/storage/storage_service.dart';

class _FakeStorageService extends StorageService {
  final Map<String, String> values = {};

  @override
  String? getString(String key) => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}

void main() {
  test('defaults to system locale when nothing is stored', () {
    final storage = _FakeStorageService();
    final container = ProviderContainer(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    expect(container.read(localeControllerProvider), AppLocaleOption.system);
  });

  test('persists explicit language and clears it for system', () async {
    final storage = _FakeStorageService();
    final container = ProviderContainer(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    await container
        .read(localeControllerProvider.notifier)
        .setOption(AppLocaleOption.en);

    expect(storage.values['app_locale'], 'en');
    expect(container.read(localeControllerProvider), AppLocaleOption.en);

    await container
        .read(localeControllerProvider.notifier)
        .setOption(AppLocaleOption.system);

    expect(storage.values, isEmpty);
    expect(container.read(localeControllerProvider), AppLocaleOption.system);
  });

  test('resolves the API language code from the selected option', () {
    expect(AppLocaleOption.en.widgetLocaleCode(const Locale('zh')), 'en');
    expect(AppLocaleOption.zh.widgetLocaleCode(const Locale('en')), 'zh');
    expect(
      AppLocaleOption.system.widgetLocaleCode(const Locale('en', 'US')),
      'en',
    );
    expect(
      AppLocaleOption.system.widgetLocaleCode(const Locale('zh', 'CN')),
      'zh',
    );
  });
}
