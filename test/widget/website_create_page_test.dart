import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/common/page_result.dart';
import 'package:onedash/data/dto/website/ssl_manage_dtos.dart';
import 'package:onedash/data/dto/website/website_create_metadata.dart';
import 'package:onedash/data/dto/website/website_group_dto.dart';
import 'package:onedash/data/repositories_impl/website_repository_impl.dart';
import 'package:onedash/domain/repositories/website_repository.dart';
import 'package:onedash/presentation/features/websites/providers/websites_provider.dart';
import 'package:onedash/presentation/features/websites/screens/website_create_wizard.dart';

class _FakeCertificateRepository implements WebsiteRepository {
  _FakeCertificateRepository(this.certificates);

  final List<SslManageDto> certificates;

  @override
  Future<PageResult<SslManageDto>> searchSsl(Map<String, dynamic> req) async {
    return PageResult<SslManageDto>(
      total: certificates.length,
      items: certificates,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SslManageDto _certificate(int id, String domain) {
  return SslManageDto.fromJson({
    'id': id,
    'primaryDomain': domain,
    'pem': '-----BEGIN CERTIFICATE-----',
    'expireDate': '2027-0$id-01',
    'acmeAccountId': 0,
  });
}

Widget _app(String type, {WebsiteRepository? repository}) {
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
      if (repository != null)
        websiteRepositoryProvider.overrideWith((ref) async => repository),
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

  testWidgets('SSL certificate selector loads and selects a certificate', (
    tester,
  ) async {
    final repository = _FakeCertificateRepository([
      _certificate(1, 'a.example.com'),
      _certificate(2, 'b.example.com'),
    ]);
    await tester.pumpWidget(_app('proxy', repository: repository));
    await tester.pumpAndSettle();

    final sslSwitch = find.byType(SwitchListTile);
    await tester.dragUntilVisible(
      sslSwitch,
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(sslSwitch.first);
    await tester.pumpAndSettle();

    expect(find.text('a.example.com · 2027-01-01'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<int>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('b.example.com · 2027-02-01').last);
    await tester.pumpAndSettle();

    expect(find.text('b.example.com · 2027-02-01'), findsOneWidget);
  });

  testWidgets('SSL section shows certificate management when list is empty', (
    tester,
  ) async {
    final repository = _FakeCertificateRepository(const []);
    await tester.pumpWidget(_app('proxy', repository: repository));
    await tester.pumpAndSettle();

    final sslSwitch = find.byType(SwitchListTile);
    await tester.dragUntilVisible(
      sslSwitch,
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(sslSwitch.first);
    await tester.pumpAndSettle();

    expect(find.text('未配置 SSL 证书'), findsOneWidget);
    expect(find.text('证书管理'), findsOneWidget);
    expect(find.text('SSL 证书'), findsNothing);
  });
}
