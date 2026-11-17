import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/repositories_impl/setting_repository_impl.dart';
import 'package:onedash/domain/repositories/setting_repository.dart';
import 'package:onedash/presentation/features/panel_settings/screens/panel_menu_page.dart';

class _FakeSettingRepository implements SettingRepository {
  String? savedMenu;
  bool resetCalled = false;

  @override
  Future<Map<String, dynamic>> searchCoreSettings() async => {
    'HideMenu': jsonEncode([
      {
        'id': '1',
        'label': 'Home-Menu',
        'disabled': true,
        'isShow': true,
        'title': 'menu.home',
        'sort': 100,
      },
      {
        'id': '4',
        'label': 'Website-Menu',
        'disabled': false,
        'isShow': true,
        'title': 'menu.website',
        'sort': 400,
        'children': [
          {
            'id': '32',
            'label': 'SSL',
            'disabled': false,
            'isShow': true,
            'title': 'menu.ssl',
            'sort': 200,
          },
        ],
      },
    ]),
  };

  @override
  Future<void> updateMenuSetting(String value) async {
    savedMenu = value;
  }

  @override
  Future<void> resetMenuSetting() async {
    resetCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('panel menu page renders localized groups and toggles children', (
    tester,
  ) async {
    final repository = _FakeSettingRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingRepositoryProvider.overrideWith((ref) async => repository),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PanelMenuPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('概览'), findsOneWidget);
    expect(find.text('网站'), findsOneWidget);
    expect(find.text('SSL 证书'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches, hasLength(3));
    expect(switches.last.value, isTrue);

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    final updated = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(updated.last.value, isFalse);
    expect(updated[1].value, isFalse);
  });
}
