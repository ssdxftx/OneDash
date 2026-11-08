import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/localization/generated/app_localizations.dart';
import 'package:onedash/core/theme/app_theme.dart';
import 'package:onedash/data/dto/dashboard/dashboard_dto.dart';
import 'package:onedash/domain/entities/dashboard.dart';
import 'package:onedash/presentation/features/dashboard/providers/overview_provider.dart';
import 'package:onedash/presentation/features/dashboard/widgets/dashboard_cards.dart';

Dashboard _dashboard() {
  return DashboardDto.parse(
    baseJson: const {
      'hostname': 'demo-host',
      'ipV4Addr': '10.0.0.2',
      'os': 'Ubuntu 24.04',
      'prettyDistro': 'Ubuntu 24.04 LTS',
      'platformVersion': '24.04',
      'kernelVersion': '6.8.0',
      'kernelArch': 'x86_64',
      'cpuCores': 4,
      'cpuLogicalCores': 8,
      'cpuModelName': 'Example CPU',
    },
    currentJson: const {
      'uptime': 7200,
      'procs': 120,
      'load1': 0.42,
      'load5': 0.38,
      'load15': 0.31,
      'cpuTotal': 8,
      'cpuUsed': 2.5,
      'cpuUsedPercent': 31,
      'memoryTotal': 8589934592,
      'memoryUsed': 4294967296,
      'memoryUsedPercent': 50,
      'swapMemoryTotal': 1073741824,
      'swapMemoryUsed': 107374182,
      'swapMemoryUsedPercent': 10,
      'netBytesSent': 1048576,
      'netBytesRecv': 2097152,
      'ioCount': 100,
      'ioReadBytes': 4096,
      'ioReadTime': 20,
      'ioWriteBytes': 2048,
      'ioWriteTime': 10,
      'diskData': [
        {
          'path': '/',
          'device': '/dev/vda1',
          'total': 107374182400,
          'used': 53687091200,
          'usedPercent': 50,
        },
      ],
      'topCPUItems': [
        {'pid': 1, 'name': 'nginx', 'percent': 12.5, 'memory': 1048576},
        {'pid': 2, 'name': 'mysql', 'percent': 8, 'memory': 2097152},
        {'pid': 3, 'name': 'redis', 'percent': 4, 'memory': 524288},
      ],
      'topMemItems': [
        {'pid': 2, 'name': 'mysql', 'user': 'root', 'memory': 2097152},
        {'pid': 1, 'name': 'nginx', 'user': 'www', 'memory': 1048576},
      ],
    },
  );
}

Widget _app({required double width, required double height, double scale = 1}) {
  final now = DateTime.now();
  final state = OverviewState(
    dashboard: _dashboard(),
    cpuHistory: const [30],
    memoryHistory: const [50],
    netUpHistory: const [1024],
    netDownHistory: const [2048],
    speedHistory: [
      for (var second = 10; second >= 1; second--)
        SpeedSample(
          time: now.subtract(Duration(seconds: second)),
          up: 1024,
          down: 2048,
        ),
    ],
    lastUpdated: now,
    readBytesPerSecond: 4096,
    writeBytesPerSecond: 2048,
    latencyMs: 0.3,
  );
  return MaterialApp(
    theme: AppTheme.build(Brightness.light),
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, height)),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: buildDashboardCards(
                context: context,
                l10n: l10n,
                dashboard: state.dashboard,
                state: state,
              ),
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  testWidgets('dashboard renders all cards at 390dp', (tester) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(width: 390, height: 1800));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('资源占用'), findsOneWidget);
    expect(find.text('实时速率'), findsOneWidget);
    expect(find.text('磁盘 I/O'), findsOneWidget);
    expect(find.text('磁盘分区'), findsOneWidget);
    expect(find.text('主机详情'), findsOneWidget);
    expect(find.text('进程数'), findsWidgets);
    expect(find.text('x86_64'), findsOneWidget);
  });

  testWidgets('dashboard fits 320dp at 1.5x text', (tester) async {
    tester.view.physicalSize = const Size(320, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(width: 320, height: 2400, scale: 1.5));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('资源占用'), findsOneWidget);
  });
}
