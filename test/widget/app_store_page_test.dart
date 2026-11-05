import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/app/app_installed_dto.dart';
import 'package:onedash/data/dto/common/page_result.dart';
import 'package:onedash/presentation/common/components/action_sheet.dart';
import 'package:onedash/presentation/features/app_store/providers/app_store_provider.dart';
import 'package:onedash/presentation/features/app_store/screens/app_store_page.dart';

void main() {
  const pixel =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
      'YAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
  const app = AppInstalledDto(
    id: 1,
    name: 'nginx',
    appId: 1,
    appDetailId: 2,
    version: '1.0.0',
    status: 'running',
    message: '',
    httpPort: 80,
    httpsPort: 443,
    path: '',
    canUpdate: false,
    icon: 'data:image/png;base64,$pixel',
    appName: 'nginx',
    appKey: 'nginx',
    appType: 'runtime',
    createdAt: null,
    favorite: false,
    container: 'nginx',
    serviceName: 'nginx',
  );

  testWidgets(
    'installed card opens the action sheet when ignored lookup fails',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            installedAppsProvider.overrideWith(
              (ref) async => const PageResult(total: 1, items: [app]),
            ),
            installedIgnoredProvider(
              1,
            ).overrideWith((ref) async => throw Exception('offline')),
          ],
          child: MaterialApp(
            theme: AppTheme.build(Brightness.light),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppStorePage(serverId: 1, initialTab: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('nginx').first);
      await tester.pumpAndSettle();

      expect(find.byType(ActionSheetScaffold), findsOneWidget);
    },
  );
}
