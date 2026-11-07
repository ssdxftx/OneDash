import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/website/website_detail_dto.dart';
import 'package:onedash/data/dto/website/website_dto.dart';
import 'package:onedash/presentation/features/websites/providers/websites_provider.dart';
import 'package:onedash/presentation/features/websites/screens/website_detail_page.dart';

const _site = WebsiteDto(
  id: 1,
  primaryDomain: 'example.com',
  status: 'Running',
  type: 'static',
  protocol: 'http',
  expireDate: '',
  sslExpireDate: '',
  remark: '',
  createdAt: '',
  updatedAt: '',
  siteDir: '',
  sitePath: '',
  runtimeName: '',
  websiteRuntimeType: '',
  dbID: 0,
  dbType: '',
);

const _detail = WebsiteDetailDto(
  website: _site,
  alias: '',
  errorLogPath: '',
  accessLogPath: '',
  webSiteGroupId: 0,
  webSiteSSLId: 0,
  ipv6: false,
  accessLog: false,
  errorLog: false,
  defaultServer: false,
  favorite: false,
  domains: [],
  ssl: null,
);

Widget _app() {
  final router = GoRouter(
    initialLocation: '/s/1/websites/1',
    routes: [
      GoRoute(
        path: '/s/:serverId/websites/:siteId',
        builder: (context, state) =>
            const WebsiteDetailPage(serverId: 1, siteId: '1'),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page Not Found'))),
  );
  return ProviderScope(
    overrides: [websiteDetailProvider(1).overrideWith((ref) async => _detail)],
    child: MaterialApp.router(
      theme: AppTheme.build(Brightness.light),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('advanced action opens a sheet instead of an error route', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advanced settings'));
    await tester.pumpAndSettle();

    expect(find.text('Page Not Found'), findsNothing);
    expect(find.text('Basic Configuration'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'certificate management opens a sheet instead of an error route',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('SSL Certificate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Certificate management'));
      await tester.pumpAndSettle();

      expect(find.text('Page Not Found'), findsNothing);
      expect(find.text('Certificate management'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
