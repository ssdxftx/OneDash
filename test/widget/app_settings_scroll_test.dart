import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
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

Future<void> _pumpSettings(
  WidgetTester tester, {
  required Size size,
  required double textScale,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  PackageInfo.setMockInitialValues(
    appName: 'OneDash',
    packageName: 'dev.onedash.app',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  final container = ProviderContainer(
    overrides: [
      storageServiceProvider.overrideWithValue(_FakeStorageService()),
    ],
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const AppSettingsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _verticalOffset(WidgetTester tester) {
  final scrollable = find.descendant(
    of: find.byType(ListView),
    matching: find.byType(Scrollable),
  );
  return tester.state<ScrollableState>(scrollable.first).position.pixels;
}

void main() {
  testWidgets('narrow screen opens settings at the top', (tester) async {
    await _pumpSettings(tester, size: const Size(640, 1688), textScale: 1);

    expect(_verticalOffset(tester), 0);
    expect(find.text('外观'), findsOneWidget);
  });

  testWidgets('large text opens settings at the top', (tester) async {
    await _pumpSettings(tester, size: const Size(780, 1688), textScale: 1.5);

    expect(_verticalOffset(tester), 0);
    expect(find.text('外观'), findsOneWidget);
  });
}
