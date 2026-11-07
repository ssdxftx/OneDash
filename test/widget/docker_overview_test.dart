import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/container/container_item_stats_dto.dart';
import 'package:onedash/data/dto/container/container_status_dto.dart';
import 'package:onedash/data/dto/container/docker_status_dto.dart';
import 'package:onedash/presentation/features/containers/providers/container_resources_provider.dart';
import 'package:onedash/presentation/features/containers/providers/containers_provider.dart';
import 'package:onedash/presentation/features/containers/screens/docker_overview_page.dart';
import 'package:onedash/presentation/features/servers/providers/servers_provider.dart';

void main() {
  testWidgets('overview shows docker, resource entries and four disk rows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverByIdProvider(1).overrideWith((ref) async => null),
          dockerStatusProvider.overrideWith(
            (ref) async => const DockerStatusDto(
              isActive: true,
              isExist: true,
              version: '27.1.1',
            ),
          ),
          containerStatusProvider.overrideWith(
            (ref) async => const ContainerStatusDto(
              created: 0,
              running: 10,
              paused: 0,
              restarting: 0,
              removing: 0,
              exited: 0,
              dead: 0,
              containerCount: 12,
              composeCount: 3,
              composeTemplateCount: 2,
              imageCount: 8,
              networkCount: 4,
              volumeCount: 6,
              repoCount: 1,
            ),
          ),
          containerItemStatsProvider.overrideWith(
            (ref) async => const ContainerItemStatsDto(
              sizeRw: 0,
              sizeRootFs: 0,
              containerUsage: 1024,
              containerReclaimable: 512,
              imageUsage: 2048,
              imageReclaimable: 1024,
              volumeUsage: 4096,
              volumeReclaimable: 0,
              buildCacheUsage: 8192,
              buildCacheReclaimable: 4096,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DockerOverviewPage(serverId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('v27.1.1'), findsOneWidget);
    expect(find.text('运行 10'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('镜像仓库'), findsWidgets);
    expect(find.text('网络'), findsWidgets);
    expect(find.text('存储卷'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Docker 磁盘占用'), findsOneWidget);
    expect(find.text('可释放 512 B'), findsOneWidget);
  });
}
