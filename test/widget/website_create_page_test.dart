import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/website/website_create_metadata.dart';
import 'package:onedash/data/dto/website/website_group_dto.dart';
import 'package:onedash/presentation/features/websites/providers/websites_provider.dart';
import 'package:onedash/presentation/features/websites/screens/website_create_wizard.dart';

Widget _app(String type) {
  return ProviderScope(
    overrides: [
      websiteCreateMetadataProvider.overrideWith(
        (ref) async => const WebsiteCreateMetadata(
          websiteRootDir: '/opt/1panel/www',
          groups: [
            WebsiteGroupDto(
              id: 2,
              name: '默认分组',
              type: 'website',
              isDefault: true,
            ),
          ],
        ),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.build(Brightness.light),
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: WebsiteCreateWizard(serverId: 1, type: type),
    ),
  );
}

void main() {
  testWidgets('proxy type shows proxy card and defaults to port 80', (
    tester,
  ) async {
    await tester.pumpWidget(_app('proxy'));
    await tester.pumpAndSettle();

    expect(find.text('新建反向代理'), findsOneWidget);
    expect(find.text('反向代理设置'), findsOneWidget);
    expect(find.text('运行环境'), findsNothing);
    expect(find.text('80'), findsOneWidget);
  });

  testWidgets('static type hides proxy and runtime cards', (tester) async {
    await tester.pumpWidget(_app('static'));
    await tester.pumpAndSettle();

    expect(find.text('新建静态网站'), findsOneWidget);
    expect(find.text('反向代理设置'), findsNothing);
    expect(find.text('运行环境'), findsNothing);
  });

  testWidgets('runtime type shows runtime card', (tester) async {
    await tester.pumpWidget(_app('runtime'));
    await tester.pumpAndSettle();

    expect(find.text('新建运行环境'), findsOneWidget);
    expect(find.text('运行环境'), findsWidgets);
    expect(find.text('反向代理设置'), findsNothing);
  });
}
