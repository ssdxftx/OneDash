import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/common/page_result.dart';
import 'package:onedash/data/dto/container/container_daemon_config_dto.dart';
import 'package:onedash/data/dto/container/container_resource_stats_dto.dart';
import 'package:onedash/data/dto/container/container_search_dto.dart';
import 'package:onedash/data/dto/container/docker_status_dto.dart';
import 'package:onedash/data/dto/website/website_dto.dart';
import 'package:onedash/data/dto/website/website_search_req.dart';
import 'package:onedash/data/repositories_impl/container_repository_impl.dart';
import 'package:onedash/data/repositories_impl/server_repository_impl.dart';
import 'package:onedash/data/repositories_impl/website_repository_impl.dart';
import 'package:onedash/domain/entities/server.dart';
import 'package:onedash/domain/repositories/container_repository.dart';
import 'package:onedash/domain/repositories/server_repository.dart';
import 'package:onedash/domain/repositories/website_repository.dart';
import 'package:onedash/presentation/features/containers/screens/containers_page.dart';
import 'package:onedash/presentation/features/websites/screens/websites_page.dart';
import 'package:onedash/presentation/shell/nav_visibility.dart';

class _FakeWebsiteRepository implements WebsiteRepository {
  @override
  Future<PageResult<WebsiteDto>> searchWebsites(WebsiteSearchReq req) async {
    return const PageResult<WebsiteDto>(
      total: 1,
      items: [
        WebsiteDto(
          id: 1,
          primaryDomain: 'demo.example.com',
          status: 'Running',
          type: 'proxy',
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
        ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeContainerRepository implements ContainerRepository {
  @override
  Future<ContainerSearchDto> searchContainers({
    String state = 'all',
    int page = 1,
    int pageSize = 20,
    String filters = '',
    String orderBy = 'createdAt',
    String order = 'null',
    bool excludeAppStore = false,
    String name = '',
  }) async {
    return const ContainerSearchDto(
      total: 1,
      items: [
        ContainerItemDto(
          containerID: 'abc',
          name: 'demo-app',
          imageID: 'sha256:1',
          imageName: 'nginx:alpine',
          createTime: '2026-11-08 10:00:00',
          state: 'running',
          runTime: '2 hours',
          isFromApp: false,
          isFromCompose: false,
          isPinned: false,
          description: 'demo',
        ),
      ],
    );
  }

  @override
  Future<List<ContainerResourceStatsDto>> getContainerResourceStats() async => [];

  @override
  Future<DockerStatusDto> getDockerStatus() async =>
      const DockerStatusDto(isActive: true, isExist: true);

  @override
  Future<ContainerDaemonConfigDto> getDaemonConfig() async =>
      const ContainerDaemonConfigDto(
        isSwarm: false,
        version: '29.1.5',
        registryMirrors: [],
        insecureRegistries: [],
        liveRestore: false,
        iptables: true,
        cgroupDriver: 'systemd',
        ipv6: false,
        fixedCidrV6: '',
        ip6Tables: false,
        experimental: false,
        logMaxSize: '10m',
        logMaxFile: '3',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeServerRepository implements ServerRepository {
  @override
  Future<Server?> find(int id) async => Server()
    ..id = id
    ..name = 'demo'
    ..host = '127.0.0.1'
    ..port = 9999;

  @override
  Future<List<Server>> list() async => [
    Server()
      ..id = 1
      ..name = 'demo'
      ..host = '127.0.0.1'
      ..port = 9999,
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('long press enters selection and X exits it', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          websiteRepositoryProvider.overrideWith(
            (ref) async => _FakeWebsiteRepository(),
          ),
          serverRepositoryProvider.overrideWithValue(_FakeServerRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WebsitesPage(serverId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(WebsitesPage)),
    );

    await tester.longPress(find.text('demo.example.com'));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsWidgets);
    expect(find.byIcon(TablerIcons.x), findsOneWidget);
    expect(container.read(bottomNavSuppressedProvider), isTrue);

    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsNothing);
    expect(container.read(bottomNavSuppressedProvider), isFalse);
  });

  testWidgets('container list exits selection with X and back', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          containerRepositoryProvider.overrideWith(
            (ref) async => _FakeContainerRepository(),
          ),
          serverRepositoryProvider.overrideWithValue(_FakeServerRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ContainersPage(serverId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ContainersPage)),
    );

    await tester.longPress(find.text('demo-app'));
    await tester.pumpAndSettle();
    expect(find.byIcon(TablerIcons.x), findsOneWidget);
    expect(container.read(bottomNavSuppressedProvider), isTrue);

    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pumpAndSettle();
    expect(find.byIcon(TablerIcons.x), findsNothing);
    expect(container.read(bottomNavSuppressedProvider), isFalse);

    await tester.longPress(find.text('demo-app'));
    await tester.pumpAndSettle();
    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(find.byType(ContainersPage), findsOneWidget);
    expect(container.read(bottomNavSuppressedProvider), isFalse);
  });

  testWidgets('deselecting the last item exits selection automatically', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          websiteRepositoryProvider.overrideWith(
            (ref) async => _FakeWebsiteRepository(),
          ),
          serverRepositoryProvider.overrideWithValue(_FakeServerRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WebsitesPage(serverId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(WebsitesPage)),
    );

    await tester.longPress(find.text('demo.example.com'));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsWidgets);

    await tester.longPress(find.text('demo.example.com'));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsNothing);
    expect(container.read(bottomNavSuppressedProvider), isFalse);
  });

  testWidgets('back button exits selection before leaving the page', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          websiteRepositoryProvider.overrideWith(
            (ref) async => _FakeWebsiteRepository(),
          ),
          serverRepositoryProvider.overrideWithValue(_FakeServerRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WebsitesPage(serverId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(WebsitesPage)),
    );

    await tester.longPress(find.text('demo.example.com'));
    await tester.pumpAndSettle();
    expect(find.byIcon(TablerIcons.x), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(find.byType(WebsitesPage), findsOneWidget);
    expect(find.byIcon(TablerIcons.x), findsNothing);
    expect(container.read(bottomNavSuppressedProvider), isFalse);
  });
}
