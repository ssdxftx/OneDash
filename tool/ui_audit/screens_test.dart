import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:onedash/app.dart';
import 'package:onedash/core/router/app_router.dart';
import 'package:onedash/core/storage/storage_service.dart';
import 'package:onedash/core/theme/theme_controller.dart';
import 'package:onedash/data/dto/common/page_result.dart';
import 'package:onedash/data/dto/container/container_resource_stats_dto.dart';
import 'package:onedash/data/dto/container/container_search_dto.dart';
import 'package:onedash/data/dto/container/container_daemon_config_dto.dart';
import 'package:onedash/data/dto/container/container_item_stats_dto.dart';
import 'package:onedash/data/dto/container/container_status_dto.dart';
import 'package:onedash/data/dto/container/docker_status_dto.dart';
import 'package:onedash/data/dto/file/file_item_dto.dart';
import 'package:onedash/data/dto/website/website_dto.dart';
import 'package:onedash/data/dto/website/website_search_req.dart';
import 'package:onedash/data/repositories_impl/container_repository_impl.dart';
import 'package:onedash/data/repositories_impl/file_repository_impl.dart';
import 'package:onedash/data/repositories_impl/repository_providers.dart';
import 'package:onedash/data/repositories_impl/server_repository_impl.dart';
import 'package:onedash/data/repositories_impl/website_repository_impl.dart';
import 'package:onedash/domain/entities/dashboard.dart';
import 'package:onedash/domain/entities/server.dart';
import 'package:onedash/domain/repositories/container_repository.dart';
import 'package:onedash/domain/repositories/dashboard_repository.dart';
import 'package:onedash/domain/repositories/file_repository.dart';
import 'package:onedash/domain/repositories/server_repository.dart';
import 'package:onedash/domain/repositories/website_repository.dart';

const _tablerFont =
    '/root/.pub-cache/hosted/pub.dev/flutter_tabler_icons-1.43.0/assets/fonts/tabler-icons.ttf';
const _materialIcons =
    '/opt/flutter-sdk/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';

Future<void> _loadFont(String family, String path) async {
  final bytes = await File(path).readAsBytes();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
  await loader.load();
}

Future<void> _loadFonts() async {
  final regular = await File('assets/fonts/MiSans-Regular.ttf').readAsBytes();
  final medium = await File('assets/fonts/MiSans-Medium.ttf').readAsBytes();
  final semibold = await File('assets/fonts/MiSans-Semibold.ttf').readAsBytes();
  final loader = FontLoader('MiSans')
    ..addFont(Future.value(ByteData.view(regular.buffer)))
    ..addFont(Future.value(ByteData.view(medium.buffer)))
    ..addFont(Future.value(ByteData.view(semibold.buffer)));
  await loader.load();
  await _loadFont('tabler-icons', _tablerFont);
  await _loadFont('packages/flutter_tabler_icons/tabler-icons', _tablerFont);
  await _loadFont('MaterialIcons', _materialIcons);
}

Server _server(
  int id,
  String name,
  String host,
  int port, {
  DateTime? lastUsedAt,
}) {
  return Server()
    ..id = id
    ..name = name
    ..host = host
    ..port = port
    ..sortIndex = id
    ..createdAt = DateTime(2026, 1, 1)
    ..lastUsedAt = lastUsedAt;
}

DashboardCurrent _current(int tick) {
  final sent = 12 * 1024 * 1024 * 1024 + tick * 640 * 1024;
  final recv = 48 * 1024 * 1024 * 1024 + tick * 2 * 1024 * 1024;
  return DashboardCurrent(
    uptimeSeconds: 987654,
    timeSinceUptime: '11 days',
    shotTime: DateTime.now().toIso8601String(),
    procs: 187,
    load1: 1.24,
    load5: 1.08,
    load15: 0.92,
    loadUsagePercent: 31,
    cpuTotal: 8,
    cpuUsed: 7.31,
    cpuUsedPercent: 91.4,
    cpuPercent: const [82, 88, 91, 86, 93, 90, 91, 84],
    cpuDetailedPercent: const [82, 88, 91, 86, 93, 90, 91, 84],
    memoryTotal: 16 * 1024 * 1024 * 1024,
    memoryUsed: 14 * 1024 * 1024 * 1024,
    memoryFree: 2 * 1024 * 1024 * 1024,
    memoryAvailable: 2 * 1024 * 1024 * 1024,
    memoryCache: 1536 * 1024 * 1024,
    memoryUsedPercent: 87.5,
    swapMemoryTotal: 2 * 1024 * 1024 * 1024,
    swapMemoryUsed: 1340 * 1024 * 1024,
    swapMemoryAvailable: 708 * 1024 * 1024,
    swapMemoryUsedPercent: 65.4,
    netBytesSent: sent,
    netBytesRecv: recv,
    ioCount: 4812,
    ioReadBytes: 18 * 1024 * 1024 * 1024,
    ioReadTime: 1234,
    ioWriteBytes: 9 * 1024 * 1024 * 1024,
    ioWriteTime: 640,
    disks: const [
      DiskUsage(
        path: '/',
        device: '/dev/nvme0n1p2',
        fsType: 'ext4',
        total: 120 * 1024 * 1024 * 1024,
        used: 110 * 1024 * 1024 * 1024,
        free: 10 * 1024 * 1024 * 1024,
        usedPercent: 92,
        inodesTotal: 1000000,
        inodesUsed: 240000,
        inodesFree: 760000,
        inodesUsedPercent: 24,
      ),
      DiskUsage(
        path: '/data',
        device: '/dev/nvme0n1p3',
        fsType: 'ext4',
        total: 500 * 1024 * 1024 * 1024,
        used: 210 * 1024 * 1024 * 1024,
        free: 290 * 1024 * 1024 * 1024,
        usedPercent: 42,
        inodesTotal: 2000000,
        inodesUsed: 120000,
        inodesFree: 1880000,
        inodesUsedPercent: 6,
      ),
    ],
    topCpuItems: const [
      ProcessUsage(
        pid: 1240,
        name: 'nginx',
        user: 'www',
        cmd: 'nginx: worker process',
        percent: 28.4,
        memory: 220 * 1024 * 1024,
      ),
      ProcessUsage(
        pid: 987,
        name: 'node',
        user: 'root',
        cmd: 'node /opt/app/server.js',
        percent: 16.2,
        memory: 890 * 1024 * 1024,
      ),
    ],
    topMemItems: const [
      ProcessUsage(
        pid: 987,
        name: 'node',
        user: 'root',
        cmd: 'node /opt/app/server.js',
        percent: 4.2,
        memory: 890 * 1024 * 1024,
      ),
    ],
    gpus: const [],
    xpus: const [],
  );
}

class _FakeDashboardRepository implements DashboardRepository {
  int _tick = 0;

  Dashboard _dashboard() => Dashboard(
    base: const DashboardBase(
      hostname: 'sg-prod-01',
      ipV4Addr: '203.0.113.24',
      os: 'linux',
      platform: 'ubuntu',
      platformFamily: 'debian',
      platformVersion: '24.04 LTS',
      prettyDistro: 'Ubuntu 24.04 LTS',
      kernelArch: 'x86_64',
      kernelVersion: '6.8.0-45-generic',
      cpuCores: 8,
      cpuLogicalCores: 16,
      cpuMhz: 3200,
      cpuModelName: 'AMD Ryzen 7 5800X',
      virtualizationSystem: 'kvm',
      systemProxy: '',
      websiteNumber: 6,
      databaseNumber: 3,
      cronjobNumber: 2,
      appInstalledNumber: 5,
      agentNumber: 0,
    ),
    current: _current(_tick++),
  );

  @override
  Future<Dashboard> getDashboard({
    required String ioOption,
    required String netOption,
  }) async => _dashboard();

  @override
  Future<Dashboard> getDashboardSnapshot({
    required String ioOption,
    required String netOption,
  }) async => _dashboard();

  @override
  Future<DashboardBase> getDashboardBase({
    required String ioOption,
    required String netOption,
  }) async => _dashboard().base;

  @override
  Future<DashboardCurrent> getDashboardCurrent({
    required String ioOption,
    required String netOption,
  }) async => _current(_tick++);

  @override
  Future<List<String>> getMonitorIoOptions() async => const ['all'];

  @override
  Future<List<String>> getMonitorNetOptions() async => const ['all'];

  @override
  Future<List<Map<String, dynamic>>> getQuickOptions() async => [
    {'title': 'Docker', 'name': 'docker', 'isShow': true},
    {'title': 'Nginx', 'name': 'nginx', 'isShow': true},
    {'title': 'MySQL', 'name': 'mysql', 'isShow': true},
  ];

  @override
  Future<List<Map<String, dynamic>>> getAppLauncher() async => [
    {'name': 'phpMyAdmin', 'key': 'phpmyadmin', 'isInstall': true},
    {'name': 'Redis Insight', 'key': 'redis-insight', 'isInstall': false},
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _FakeServerRepository implements ServerRepository {
  _FakeServerRepository(this.servers);

  final List<Server> servers;

  @override
  Future<List<Server>> list() async => servers;

  @override
  Future<Server?> find(int id) async {
    for (final server in servers) {
      if (server.id == id) return server;
    }
    return null;
  }

  @override
  Future<String?> getApiKey(int id) async => 'audit-key';

  @override
  Future<void> update(Server server, {String? apiKey}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

WebsiteDto _website({
  required int id,
  required String domain,
  String status = 'Running',
  String type = 'static',
  String protocol = 'http',
  String sslExpireDate = '',
  String expireDate = '',
  String siteDir = '',
  String runtimeName = '',
}) {
  return WebsiteDto(
    id: id,
    primaryDomain: domain,
    status: status,
    type: type,
    protocol: protocol,
    expireDate: expireDate,
    sslExpireDate: sslExpireDate,
    remark: '',
    createdAt: '2026-01-01',
    updatedAt: '2026-02-01',
    siteDir: siteDir,
    sitePath: '/opt/1panel/www/sites/$domain',
    runtimeName: runtimeName,
    websiteRuntimeType: '',
    dbID: 0,
    dbType: '',
  );
}

class _FakeWebsiteRepository implements WebsiteRepository {
  final sites = [
    _website(
      id: 1,
      domain: 'www.acme-corporation-global.com',
      protocol: 'https',
      sslExpireDate: '2027-06-18',
    ),
    _website(
      id: 2,
      domain: 'api.acme.com',
      protocol: 'https',
      sslExpireDate: '2026-11-19',
      type: 'proxy',
    ),
    _website(
      id: 3,
      domain: 'blog.acme.com',
      status: 'Stopped',
      protocol: 'https',
      sslExpireDate: '2026-11-10',
      type: 'runtime',
      runtimeName: 'php82',
    ),
    _website(id: 4, domain: 'static.acme.com', protocol: 'http'),
    _website(
      id: 5,
      domain: 'shop.acme.com',
      protocol: 'https',
      sslExpireDate: '2026-12-24',
      type: 'deployment',
    ),
    _website(
      id: 6,
      domain: 'old.acme.com',
      status: 'Stopped',
      protocol: 'http',
    ),
  ];

  @override
  Future<PageResult<WebsiteDto>> searchWebsites(WebsiteSearchReq req) async {
    final filtered = sites.where((site) {
      if (req.type.isNotEmpty && site.type != req.type) return false;
      if (req.name.isNotEmpty && !site.primaryDomain.contains(req.name)) {
        return false;
      }
      return true;
    }).toList();
    return PageResult(total: filtered.length, items: filtered);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

FileItemDto _file(
  String path,
  String name, {
  bool isDir = false,
  int size = 0,
  String modTime = '2026-11-15 22:14',
  String user = 'root',
}) {
  return FileItemDto(
    path: path,
    name: name,
    user: user,
    group: 'root',
    uid: '0',
    gid: '0',
    extension: isDir ? '' : name.split('.').last,
    content: '',
    size: size,
    isDir: isDir,
    isSymlink: false,
    isHidden: false,
    linkPath: '',
    type: isDir ? 'dir' : 'file',
    mode: isDir ? '0755' : '0644',
    mimeType: '',
    modTime: modTime,
    items: null,
    itemTotal: 0,
    favoriteID: 0,
    isDetail: false,
  );
}

class _FakeFileRepository implements FileRepository {
  @override
  Future<FileItemDto> searchFiles({
    required String path,
    bool expand = true,
    bool showHidden = true,
    int page = 1,
    int pageSize = 100,
    String search = '',
    bool containSub = false,
    String sortBy = 'name',
    String? sortOrder,
  }) async {
    final root = _file('/', '/', isDir: true, modTime: '2026-11-16 09:20');
    final items = path != '/'
        ? <FileItemDto>[
            _file('$path/index.html', 'index.html', size: 2048),
            _file('$path/style.css', 'style.css', size: 8192),
          ]
        : <FileItemDto>[
            _file('/opt', 'opt', isDir: true),
            _file('/var', 'var', isDir: true),
            _file('/etc', 'etc', isDir: true),
            _file('/home', 'home', isDir: true),
            _file('/srv', 'srv', isDir: true),
            _file('/backup', 'backup', isDir: true),
            _file(
              '/deploy-2026-11-15.tar.gz',
              'deploy-2026-11-15.tar.gz',
              size: 48234496,
            ),
            _file(
              '/access.log',
              'access.log',
              size: 12884901888,
              modTime: '2026-11-16 08:59',
            ),
            _file(
              '/readme.md',
              'readme.md',
              size: 4387,
              modTime: '2026-10-30 18:02',
            ),
            _file(
              '/dump.sql.gz',
              'dump.sql.gz',
              size: 734003200,
              modTime: '2026-11-13 03:00',
            ),
          ];
    return root.copyWith(
      items: items,
      itemTotal: items.length,
      size: 12884901888,
    );
  }

  @override
  Future<Map<String, String>> getFileRemarks(List<String> paths) async =>
      const {};

  @override
  Future<int> getDepthSize(String path) async => 48234496;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _FakeContainerRepository implements ContainerRepository {
  final items = const <ContainerItemDto>[
    ContainerItemDto(
      containerID: 'c1',
      name: 'nginx-proxy',
      imageID: 'sha256:1',
      imageName: 'nginx:1.27-alpine',
      createTime: '2026-09-01',
      state: 'running',
      runTime: '76 days',
      ports: ['80:80', '443:443'],
      isFromApp: false,
      isFromCompose: false,
      isPinned: false,
      description: '',
    ),
    ContainerItemDto(
      containerID: 'c2',
      name: 'mysql-8-prod',
      imageID: 'sha256:2',
      imageName: 'mysql:8.0.39',
      createTime: '2026-08-12',
      state: 'running',
      runTime: '96 days',
      ports: ['3306:3306'],
      isFromApp: true,
      isFromCompose: false,
      isPinned: false,
      description: '',
    ),
    ContainerItemDto(
      containerID: 'c3',
      name: 'acme-stack-web-1',
      imageID: 'sha256:3',
      imageName: 'ghcr.io/acme/web:2.14.0',
      createTime: '2026-11-02',
      state: 'running',
      runTime: '14 days',
      ports: ['8080:8080'],
      isFromApp: false,
      isFromCompose: true,
      isPinned: false,
      description: '',
    ),
    ContainerItemDto(
      containerID: 'c4',
      name: 'redis-cache',
      imageID: 'sha256:4',
      imageName: 'redis:7-alpine',
      createTime: '2026-07-20',
      state: 'exited',
      runTime: '12 days',
      ports: ['6379:6379'],
      isFromApp: false,
      isFromCompose: false,
      isPinned: false,
      description: '',
    ),
    ContainerItemDto(
      containerID: 'c5',
      name: 'old-worker-debug',
      imageID: 'sha256:5',
      imageName: 'acme/worker:1.9.3',
      createTime: '2026-05-02',
      state: 'dead',
      runTime: '2 days',
      isFromApp: false,
      isFromCompose: false,
      isPinned: false,
      description: '',
    ),
    ContainerItemDto(
      containerID: 'c6',
      name: 'uptime-kuma',
      imageID: 'sha256:6',
      imageName: 'louislam/uptime-kuma:1',
      createTime: '2026-10-19',
      state: 'running',
      runTime: '28 days',
      ports: ['3001:3001'],
      isFromApp: true,
      isFromCompose: false,
      isPinned: false,
      description: '',
    ),
  ];

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
    var list = items;
    if (name.isNotEmpty) {
      list = list.where((item) => item.name.contains(name)).toList();
    }
    if (state != 'all') {
      list = list.where((item) => item.state == state).toList();
    }
    return ContainerSearchDto(total: list.length, items: list);
  }

  @override
  Future<DockerStatusDto> getDockerStatus() async =>
      const DockerStatusDto(isActive: true, isExist: true, version: '27.3.1');

  @override
  Future<List<ContainerResourceStatsDto>> getContainerResourceStats({
    List<String>? ids,
  }) async => [
    ContainerResourceStatsDto.fromJson({
      'containerID': 'c1',
      'cpuPercent': 3.4,
      'memoryUsage': 220 * 1024 * 1024,
      'memoryLimit': 2 * 1024 * 1024 * 1024,
      'memoryPercent': 10.7,
    }),
    ContainerResourceStatsDto.fromJson({
      'containerID': 'c2',
      'cpuPercent': 18.2,
      'memoryUsage': 1.8 * 1024 * 1024 * 1024,
      'memoryLimit': 4 * 1024 * 1024 * 1024,
      'memoryPercent': 45.0,
    }),
    ContainerResourceStatsDto.fromJson({
      'containerID': 'c3',
      'cpuPercent': 41.7,
      'memoryUsage': 640 * 1024 * 1024,
      'memoryLimit': 2 * 1024 * 1024 * 1024,
      'memoryPercent': 31.2,
    }),
    ContainerResourceStatsDto.fromJson({
      'containerID': 'c6',
      'cpuPercent': 0.8,
      'memoryUsage': 96 * 1024 * 1024,
      'memoryLimit': 512 * 1024 * 1024,
      'memoryPercent': 18.8,
    }),
  ];

  @override
  Future<ContainerStatusDto> getStatus() async => const ContainerStatusDto(
    created: 12,
    running: 4,
    paused: 0,
    restarting: 0,
    removing: 0,
    exited: 42,
    dead: 1,
    containerCount: 12,
    composeCount: 3,
    composeTemplateCount: 8,
    imageCount: 47,
    networkCount: 5,
    volumeCount: 9,
    repoCount: 2,
  );

  @override
  Future<ContainerItemStatsDto> getItemStats() async =>
      const ContainerItemStatsDto(
        sizeRw: 2 * 1024 * 1024 * 1024,
        sizeRootFs: 9 * 1024 * 1024 * 1024,
        containerUsage: 2147483648,
        containerReclaimable: 536870912,
        imageUsage: 12884901888,
        imageReclaimable: 4294967296,
        volumeUsage: 6442450944,
        volumeReclaimable: 1073741824,
        buildCacheUsage: 3221225472,
        buildCacheReclaimable: 3221225472,
      );

  @override
  Future<ContainerDaemonConfigDto> getDaemonConfig() async =>
      const ContainerDaemonConfigDto(
        isSwarm: false,
        version: '27.3.1',
        registryMirrors: [],
        insecureRegistries: [],
        liveRestore: true,
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
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _FakeThemeController extends ThemeController {
  _FakeThemeController(this.initial);

  final ThemeSettings initial;

  @override
  ThemeSettings build() => initial;
}

Future<void> _pumpApp(WidgetTester tester, {required String themeMode}) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final documents = Directory.systemTemp.createTempSync('onedash-ui-audit-');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => documents.path,
      );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/package_info'),
        (call) async => <String, dynamic>{
          'appName': 'OneDash',
          'packageName': 'dev.onedash.app',
          'version': '1.0.0',
          'buildNumber': '1',
          'buildSignature': '',
          'installerStore': null,
        },
      );
  addTearDown(() => documents.deleteSync(recursive: true));

  final storage = StorageService();
  await tester.runAsync(() async {
    await storage.init();
    await storage.setString('app_locale', 'zh');
    await storage.setString('theme_mode', themeMode);
    await storage.setString('last_server_id', '1');
    await storage.saveServer(
      _server(
        1,
        '新加坡生产环境',
        'sg-prod-01.example.com',
        20405,
        lastUsedAt: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    );
    await storage.saveServer(
      _server(
        2,
        '家庭 NAS',
        '192.168.1.20',
        8090,
        lastUsedAt: DateTime.now().subtract(const Duration(hours: 19)),
      ),
    );
  });

  final dashboard = _FakeDashboardRepository();
  final initialTheme = themeMode == 'dark'
      ? const ThemeSettings(mode: AppThemeMode.dark)
      : const ThemeSettings(mode: AppThemeMode.light);

  appContainer = ProviderContainer(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      serverRepositoryProvider.overrideWithValue(
        _FakeServerRepository([
          _server(
            1,
            '新加坡生产环境',
            'sg-prod-01.example.com',
            20405,
            lastUsedAt: DateTime.now().subtract(const Duration(minutes: 4)),
          ),
          _server(
            2,
            '家庭 NAS',
            '192.168.1.20',
            8090,
            lastUsedAt: DateTime.now().subtract(const Duration(hours: 19)),
          ),
        ]),
      ),
      dashboardRepositoryForServerProvider.overrideWith(
        (ref, serverId) async => dashboard,
      ),
      websiteRepositoryProvider.overrideWith(
        (ref) async => _FakeWebsiteRepository(),
      ),
      fileRepositoryProvider.overrideWith((ref) async => _FakeFileRepository()),
      containerRepositoryProvider.overrideWith(
        (ref) async => _FakeContainerRepository(),
      ),
      themeControllerProvider.overrideWith(
        () => _FakeThemeController(initialTheme),
      ),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: appContainer,
      child: const OneDashApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> _shoot(
  WidgetTester tester,
  String name, {
  Duration settle = const Duration(milliseconds: 900),
}) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump(settle);
  await tester.pump(const Duration(milliseconds: 600));
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('shots/$name.png'),
  );
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('capture main screens light', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    tester.view.padding = const FakeViewPadding(top: 48);
    addTearDown(tester.view.reset);

    await _pumpApp(tester, themeMode: 'light');

    appRouter.go('/');
    await _shoot(tester, 'servers_light_390');

    appRouter.go('/s/1/overview');
    await _shoot(tester, 'overview_light_390');

    appRouter.go('/s/1/websites');
    await _shoot(tester, 'websites_light_390');

    appRouter.go('/s/1/files?path=%2F');
    await _shoot(tester, 'files_light_390');

    appRouter.go('/s/1/containers');
    await _shoot(tester, 'docker_overview_light_390');

    appRouter.go('/s/1/containers/list');
    await _shoot(tester, 'containers_light_390');

    appRouter.go('/s/1/more');
    await _shoot(tester, 'more_light_390');

    appRouter.go('/settings');
    await _shoot(tester, 'settings_light_390');

    // Dark theme.
    await appContainer
        .read(themeControllerProvider.notifier)
        .setMode(AppThemeMode.dark);
    await tester.pump(const Duration(milliseconds: 500));

    appRouter.go('/s/1/overview');
    await _shoot(tester, 'overview_dark_390');

    appRouter.go('/s/1/websites');
    await _shoot(tester, 'websites_dark_390');

    appRouter.go('/s/1/containers/list');
    await _shoot(tester, 'containers_dark_390');

    // Narrow phone with enlarged text.
    tester.view.physicalSize = const Size(640, 1600);
    await appContainer
        .read(themeControllerProvider.notifier)
        .setTextScale(1.25);
    await tester.pump(const Duration(milliseconds: 400));

    appRouter.go('/s/1/overview');
    await _shoot(tester, 'overview_dark_320_text125');

    appRouter.go('/s/1/containers/list');
    await _shoot(tester, 'containers_dark_320_text125');

    appRouter.go('/s/1/more');
    await _shoot(tester, 'more_dark_320_text125');

    appRouter.go('/settings');
    await _shoot(tester, 'settings_dark_320_text125');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    appContainer.dispose();
  });
}
