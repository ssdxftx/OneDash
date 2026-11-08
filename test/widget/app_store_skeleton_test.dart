import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/app/app_installed_dto.dart';
import 'package:onedash/data/dto/app/app_catalog_dto.dart';
import 'package:onedash/data/dto/app/app_installed_search_req.dart';
import 'package:onedash/data/dto/common/page_result.dart';
import 'package:onedash/data/repositories_impl/app_repository_impl.dart';
import 'package:onedash/domain/entities/server.dart';
import 'package:onedash/domain/repositories/app_repository.dart';
import 'package:onedash/presentation/common/components/tonal_card.dart';
import 'package:onedash/presentation/features/app_store/providers/app_store_provider.dart';
import 'package:onedash/presentation/features/app_store/screens/app_store_page.dart';
import 'package:onedash/presentation/features/servers/providers/servers_provider.dart';

class _FakeAppRepository implements AppRepository {
  _FakeAppRepository(this.result);

  final PageResult<AppInstalledDto> result;
  int installedCalls = 0;

  @override
  Future<PageResult<AppInstalledDto>> searchInstalledApps(
    AppInstalledSearchReq req,
  ) async {
    installedCalls++;
    return result;
  }

  @override
  Future<Uint8List> getAppIcon(String appName) async => Uint8List(0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _apps = PageResult<AppInstalledDto>(
  total: 1,
  items: [
    AppInstalledDto(
      id: 1,
      name: 'wordpress',
      appId: 1,
      appDetailId: 2,
      version: '6.5',
      status: 'running',
      message: '',
      httpPort: 8080,
      httpsPort: 8443,
      path: '/opt/1panel/apps/wordpress',
      canUpdate: false,
      icon: '',
      appName: 'WordPress',
      appKey: 'wordpress',
      appType: 'website',
      createdAt: null,
      favorite: false,
      container: '1panel-wordpress',
      serviceName: 'wordpress',
    ),
  ],
);

Future<void> _pumpPage(
  WidgetTester tester, {
  required ProviderContainer container,
  int initialTab = 1,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.build(Brightness.light),
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppStorePage(serverId: 1, initialTab: initialTab),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('骨架与真卡单项高度差不超过 1dp', (tester) async {
    final completer = Completer<PageResult<AppInstalledDto>>();
    final repo = _FakeAppRepository(_apps);
    final container = ProviderContainer(
      overrides: [
        appRepositoryProvider.overrideWith((ref) async => repo),
        serverByIdProvider.overrideWith(
          (ref, id) async => Server()
            ..id = 1
            ..host = '127.0.0.1'
            ..port = 1,
        ),
        installedAppsProvider.overrideWith((ref) => completer.future),
      ],
    );
    await _pumpPage(tester, container: container);
    final skeletonHeight = tester.getSize(find.byType(TonalCard).first).height;

    completer.complete(_apps);
    await tester.pumpAndSettle();

    expect(find.text('WordPress'), findsOneWidget);
    final realHeight = tester.getSize(find.byType(TonalCard).first).height;
    expect((skeletonHeight - realHeight).abs(), lessThanOrEqualTo(1.0));
    container.dispose();
  });

  testWidgets('全部应用骨架与真卡单项高度差不超过 1dp', (tester) async {
    final completer = Completer<PageResult<AppCatalogDto>>();
    final repo = _FakeAppRepository(_apps);
    final container = ProviderContainer(
      overrides: [
        appRepositoryProvider.overrideWith((ref) async => repo),
        serverByIdProvider.overrideWith(
          (ref, id) async => Server()
            ..id = 1
            ..host = '127.0.0.1'
            ..port = 1,
        ),
        appTagsProvider.overrideWith((ref) async => const []),
        appCatalogProvider.overrideWith((ref, query) => completer.future),
      ],
    );

    await _pumpPage(tester, container: container, initialTab: 0);
    final skeletonHeight = tester.getSize(find.byType(TonalCard).first).height;

    completer.complete(
      const PageResult<AppCatalogDto>(
        total: 1,
        items: [
          AppCatalogDto(
            id: 1,
            name: 'WordPress',
            key: 'wordpress',
            description: '开箱即用的建站应用，支持主题、插件与一键部署',
            icon: '',
            status: 'running',
            installed: false,
            limit: 0,
            tags: ['CMS', 'Website'],
            gpuSupport: false,
            recommend: 0,
            type: 'website',
            batchInstallSupport: false,
            versions: ['6.5'],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('WordPress'), findsOneWidget);
    final realHeight = tester.getSize(find.byType(TonalCard).first).height;
    expect((skeletonHeight - realHeight).abs(), lessThanOrEqualTo(1.0));
    container.dispose();
  });

  testWidgets('进入应用商店即预取已安装列表，不等待切换 tab', (tester) async {
    final repo = _FakeAppRepository(_apps);
    final container = ProviderContainer(
      overrides: [
        appRepositoryProvider.overrideWith((ref) async => repo),
        serverByIdProvider.overrideWith(
          (ref, id) async => Server()
            ..id = 1
            ..host = '127.0.0.1'
            ..port = 1,
        ),
      ],
    );
    await _pumpPage(tester, container: container, initialTab: 0);
    expect(repo.installedCalls, 1);
    container.dispose();
  });
}
