import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// 轻量 1Panel 假服务，用于四态与重试测试。
///
/// 支持场景：normal / empty / error / slow / unauthorized。
class FakePanel {
  FakePanel._(this._server, this.port);

  final HttpServer _server;
  final int port;
  String scenario = 'normal';
  Duration latency = const Duration(milliseconds: 20);

  static Future<FakePanel> start({
    int port = 0,
    Duration latency = const Duration(milliseconds: 20),
    String scenario = 'normal',
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    final panel = FakePanel._(server, server.port)
      ..latency = latency
      ..scenario = scenario;
    server.listen(panel._handle);
    return panel;
  }

  Future<void> close() => _server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    await Future<void>.delayed(latency);
    if (scenario == 'slow') {
      await Future<void>.delayed(const Duration(seconds: 5));
    }
    if (scenario == 'unauthorized') {
      request.response.statusCode = HttpStatus.unauthorized;
      await request.response.close();
      return;
    }
    if (scenario == 'error') {
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
      return;
    }

    final path = request.uri.path;
    final body = switch (path) {
      '/api/v2/dashboard/base/all/all' ||
      '/api/v2/dashboard/base/os' => _dashboardBase(),
      '/api/v2/dashboard/current/all/all' => _dashboardCurrent(),
      '/api/v2/websites/search' => _page(
        scenario == 'empty' ? const [] : [_website()],
      ),
      '/api/v2/containers/search' => _page(
        scenario == 'empty' ? const [] : [_container()],
      ),
      '/api/v2/databases/search' => _page(
        scenario == 'empty' ? const [] : [_database()],
      ),
      '/api/v2/apps/installed/search' => _page(const []),
      '/api/v2/apps/search' => _page(const []),
      '/api/v2/cronjobs/search' => _page(
        scenario == 'empty' ? const [] : [_cronjob()],
      ),
      '/api/v2/hosts/firewall/base' => _envelope({
        'name': 'firewalld',
        'isExist': true,
        'isActive': true,
        'isInit': true,
        'isBind': true,
        'version': '1.0.0',
        'pingStatus': 'Enable',
      }),
      '/api/v2/hosts/firewall/search' => _page(const []),
      _ => null,
    };

    if (body == null) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    await request.response.close();
  }

  Map<String, dynamic> _envelope(Object? data) => {
    'code': 200,
    'message': '',
    'data': data,
  };

  Map<String, dynamic> _page(List<Map<String, dynamic>> items) =>
      _envelope({'total': items.length, 'items': items});

  Map<String, dynamic> _dashboardBase() => _envelope({
    'hostname': 'fake-panel',
    'ipV4Addr': '127.0.0.1',
    'os': 'linux',
    'platform': 'ubuntu',
    'platformFamily': 'debian',
    'platformVersion': '24.04',
    'prettyDistro': 'Ubuntu 24.04 LTS',
    'kernelArch': 'x86_64',
    'kernelVersion': '6.8.0',
    'cpuCores': 4,
    'cpuLogicalCores': 8,
    'cpuMhz': 3200,
    'cpuModelName': 'Fake CPU',
    'virtualizationSystem': '',
    'systemProxy': '',
    'websiteNumber': 1,
    'databaseNumber': 1,
    'cronjobNumber': 1,
    'appInstalledNumber': 0,
    'agentNumber': 0,
    'currentInfo': _currentInfo(),
  });

  Map<String, dynamic> _dashboardCurrent() => _envelope(_currentInfo());

  Map<String, dynamic> _currentInfo() => {
    'uptime': 86400,
    'timeSinceUptime': '1 day',
    'shotTime': DateTime.now().toIso8601String(),
    'procs': 120,
    'load1': 0.4,
    'load5': 0.3,
    'load15': 0.2,
    'loadUsagePercent': 5,
    'cpuTotal': 100,
    'cpuUsed': 12,
    'cpuUsedPercent': 12,
    'cpuPercent': [10, 12, 14],
    'cpuDetailedPercent': [10, 12, 14],
    'memoryTotal': 8589934592,
    'memoryUsed': 2147483648,
    'memoryFree': 6442450944,
    'memoryAvailable': 6442450944,
    'memoryCache': 0,
    'memoryUsedPercent': 25,
    'swapMemoryTotal': 0,
    'swapMemoryUsed': 0,
    'swapMemoryAvailable': 0,
    'swapMemoryUsedPercent': 0,
    'netBytesSent': 1024,
    'netBytesRecv': 2048,
    'ioCount': 1,
    'ioReadBytes': 1024,
    'ioReadTime': 1,
    'ioWriteBytes': 1024,
    'ioWriteTime': 1,
    'diskData': [
      {
        'path': '/',
        'device': '/dev/sda1',
        'type': 'ext4',
        'total': 107374182400,
        'used': 21474836480,
        'free': 85899345920,
        'usedPercent': 20,
        'inodesTotal': 1000,
        'inodesUsed': 100,
        'inodesFree': 900,
        'inodesUsedPercent': 10,
      },
    ],
    'topCpuItems': const [],
    'topMemItems': const [],
    'gpus': const [],
    'xpus': const [],
  };

  Map<String, dynamic> _website() => {
    'id': 1,
    'primaryDomain': 'example.com',
    'status': 'Running',
    'type': 'static',
    'protocol': 'http',
    'expireDate': '',
    'sslExpireDate': '',
    'remark': '',
    'createdAt': '2026-01-01',
    'updatedAt': '2026-01-01',
    'siteDir': 'example.com',
    'sitePath': '/opt/1panel/www/sites/example.com',
    'runtimeName': '',
    'runtimeType': '',
    'dbID': 0,
    'dbType': '',
  };

  Map<String, dynamic> _container() => {
    'containerID': 'abc',
    'name': 'nginx',
    'imageID': 'sha256:abc',
    'imageName': 'nginx:latest',
    'createTime': '2026-01-01',
    'state': 'running',
    'runTime': '1 day',
    'isFromApp': false,
    'isFromCompose': false,
    'isPinned': false,
    'description': '',
  };

  Map<String, dynamic> _database() => {
    'id': 1,
    'createdAt': '2026-01-01',
    'name': 'app_db',
    'from': 'mysql',
    'mysqlName': 'mysql',
    'format': 'utf8mb4',
    'collation': 'utf8mb4_general_ci',
    'username': 'app',
    'password': 'secret',
    'permission': '%',
    'isDelete': false,
    'description': '',
  };

  Map<String, dynamic> _cronjob() => {
    'id': 1,
    'name': 'backup',
    'type': 'shell',
    'status': 'Enable',
    'spec': '0 3 * * *',
    'specCustom': false,
    'specs': const [],
    'groupID': 1,
    'retainCopies': 7,
    'retryTimes': 3,
    'timeout': 3600,
    'ignoreErr': false,
    'secret': '',
    'hasAlert': false,
    'alertCount': 0,
    'alertTitle': '',
    'alertMethod': '',
    'lastRecordStatus': 'Success',
    'lastRecordTime': '2026-01-01 03:00:00',
    'createdAt': '2026-01-01',
    'updatedAt': '2026-01-01',
  };
}
