import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/localization/locale_controller.dart';
import 'package:onedash/core/storage/storage_service.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/presentation/features/settings/screens/app_settings_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  testWidgets(
    'app language selector switches between system, Chinese and English',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      PackageInfo.setMockInitialValues(
        appName: 'OneDash',
        packageName: 'dev.onedash.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
      final storage = _FakeStorageService();
      final container = ProviderContainer(
        overrides: [storageServiceProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.build(Brightness.light),
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final list = find.byType(ListView);
      await tester.dragUntilVisible(
        find.text('应用语言'),
        list,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(container.read(localeControllerProvider), AppLocaleOption.en);
      expect(storage.values['app_locale'], 'en');
      expect(tester.takeException(), isNull);
    },
  );
}
