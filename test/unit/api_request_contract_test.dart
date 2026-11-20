import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/dio_client.dart';
import 'package:onedash/data/api/ai_api.dart';
import 'package:onedash/data/api/alert_api.dart';
import 'package:onedash/data/api/app_api.dart';
import 'package:onedash/data/api/backup_api.dart';
import 'package:onedash/data/api/container_api.dart';
import 'package:onedash/data/api/file_api.dart';
import 'package:onedash/data/api/firewall_api.dart';
import 'package:onedash/data/api/host_api.dart';
import 'package:onedash/data/api/log_api.dart';
import 'package:onedash/data/api/mcp_api.dart';
import 'package:onedash/data/api/cronjob_api.dart';
import 'package:onedash/data/api/database_api.dart';
import 'package:onedash/data/api/runtime_api.dart';
import 'package:onedash/data/api/dashboard_api.dart';
import 'package:onedash/data/api/setting_api.dart';
import 'package:onedash/data/api/toolbox_api.dart';
import 'package:onedash/data/api/vm_api.dart';
import 'package:onedash/data/api/website_api.dart';
import 'package:onedash/data/dto/alert/alert_dto.dart';
import 'package:onedash/data/dto/container/container_info_dto.dart';
import 'package:onedash/data/dto/cronjob/cronjob_dto.dart';
import 'package:onedash/data/dto/host/ssh_cert_dto.dart';
import 'package:onedash/data/dto/host/ssh_log_dto.dart';
import 'package:onedash/data/dto/website/website_create_req.dart';
import 'package:onedash/data/dto/website/website_log_dto.dart';

class _RecordingAdapter implements HttpClientAdapter {
  final List<String> paths = [];
  final List<String> methods = [];
  final List<Map<String, dynamic>> bodies = [];
  final List<RequestOptions> requests = [];
  Object? responseData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    methods.add(options.method);
    requests.add(options);
    final data = options.data;
    bodies.add(data is Map ? Map<String, dynamic>.from(data) : {});
    return ResponseBody.fromString(
      jsonEncode({'code': 200, 'data': responseData}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late DioClient client;
  late _RecordingAdapter adapter;

  setUp(() {
    client = DioClient(
      baseUrl: 'http://127.0.0.1:1',
      apiKey: 'test',
      userAgent: 'test',
    );
    adapter = _RecordingAdapter();
    client.raw.httpClientAdapter = adapter;
  });

  tearDown(() => client.dispose());

  test('app upgrade sends the install detail id', () async {
    await AppApi(client).upgradeApp(
      installId: 1,
      detailId: 9,
      version: '2.0',
      dockerCompose: 'services: {}',
      taskID: 'task-1',
    );
    expect(adapter.paths.single, '/api/v2/apps/installed/op');
    expect(adapter.bodies.single['operate'], 'upgrade');
    expect(adapter.bodies.single['installId'], 1);
    expect(adapter.bodies.single['detailId'], 9);
  });

  test('AI channel config uses fixed provider paths', () async {
    final api = AiApi(client);
    adapter.responseData = <String, dynamic>{'enabled': true};
    await api.getChannelConfig('telegram', 3);
    await api.updateChannelConfig('qqbot', {'agentId': 3, 'enabled': true});
    expect(adapter.paths, [
      '/api/v2/ai/agents/channel/telegram/get',
      '/api/v2/ai/agents/channel/qqbot/update',
    ]);
    expect(adapter.bodies[0], {'agentId': 3});
    expect(adapter.bodies[1]['enabled'], isTrue);
  });

  test('backup recover sends record id, file path and timeout', () async {
    await BackupApi(client).recoverApp(
      downloadAccountID: 3,
      name: 'app',
      detailName: 'app',
      file: 'app/backup.tar.gz',
      secret: '',
      taskID: 'task-2',
      backupRecordID: 77,
    );
    expect(adapter.paths.single, '/api/v2/backups/recover');
    expect(adapter.bodies.single['backupRecordID'], 77);
    expect(adapter.bodies.single['file'], 'app/backup.tar.gz');
    expect(adapter.bodies.single['timeout'], 1800);
  });

  test('cronjob status uses the 1Panel Enable value', () async {
    await CronjobApi(client).updateStatus(5, 'Enable');
    expect(adapter.paths.single, '/api/v2/cronjobs/status');
    expect(adapter.bodies.single, {'id': 5, 'status': 'Enable'});
  });

  test('panel port update uses serverPort', () async {
    await SettingApi(client).updatePort(12345);
    expect(adapter.paths.single, '/api/v2/core/settings/port/update');
    expect(adapter.bodies.single, {'serverPort': 12345});
  });

  test('panel bind update uses bindAddress', () async {
    await SettingApi(
      client,
    ).updateBindInfo(ipv6: 'Enable', bindAddress: '10.0.0.2');
    expect(adapter.paths.single, '/api/v2/core/settings/bind/update');
    expect(adapter.bodies.single, {
      'ipv6': 'Enable',
      'bindAddress': '10.0.0.2',
    });
  });

  test('panel ssl update keeps select and self fields', () async {
    await SettingApi(client).updateSSL({
      'ssl': 'Enable',
      'sslType': 'select',
      'sslID': 8,
      'domain': 'panel.example.com',
    });
    expect(adapter.paths.single, '/api/v2/core/settings/ssl/update');
    expect(adapter.bodies.single['sslID'], 8);
    expect(adapter.bodies.single['domain'], 'panel.example.com');
  });

  test('website proxy update keeps the 1Panel payload', () async {
    await WebsiteApi(client).updateWebsiteProxy({
      'id': 7,
      'operate': 'create',
      'name': 'proxy',
      'cacheTime': 10,
    });
    expect(adapter.paths.single, '/api/v2/websites/proxies/update');
    expect(adapter.bodies.single['id'], 7);
    expect(adapter.bodies.single['operate'], 'create');
    expect(adapter.bodies.single['cacheTime'], 10);
  });

  test('website batch operate sends ids, operate and task id', () async {
    await WebsiteApi(client).batchOperateWebsites([1, 2], 'stop');
    expect(adapter.paths.single, '/api/v2/websites/batch/operate');
    expect(adapter.bodies.single['ids'], [1, 2]);
    expect(adapter.bodies.single['operate'], 'stop');
    expect(adapter.bodies.single['taskID'], isNotEmpty);
  });

  test('website batch group and ssl use backend field names', () async {
    final api = WebsiteApi(client);
    await api.batchSetWebsiteGroup([1, 2], 3);
    await api.batchSetWebsiteHttps(ids: [1, 2], sslId: 9);
    expect(adapter.paths, [
      '/api/v2/websites/batch/group',
      '/api/v2/websites/batch/ssl',
    ]);
    expect(adapter.bodies[0]['groupID'], 3);
    expect(adapter.bodies[1]['websiteSSLId'], 9);
    expect(adapter.bodies[1]['type'], 'existed');
    expect(adapter.bodies[1]['httpsPorts'], [443]);
  });

  test('website proxy cache uses array-free request and clear id', () async {
    final api = WebsiteApi(client);
    await api.updateProxyCache({
      'websiteID': 4,
      'open': true,
      'cacheLimit': 10,
      'cacheLimitUnit': 'm',
      'shareCache': 5,
      'shareCacheUnit': 'm',
      'cacheExpire': 1,
      'cacheExpireUnit': 'h',
    });
    await api.clearProxyCache(4);
    expect(adapter.paths, [
      '/api/v2/websites/proxy/config',
      '/api/v2/websites/proxy/clear',
    ]);
    expect(adapter.bodies[0]['websiteID'], 4);
    expect(adapter.bodies[1]['websiteID'], 4);
  });

  test('container rename and volume search use backend fields', () async {
    final api = ContainerApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.renameContainer(name: 'old', newName: 'new');
    await api.searchVolumes(info: 'data', page: 2, pageSize: 10);
    expect(adapter.paths, [
      '/api/v2/containers/rename',
      '/api/v2/containers/volume/search',
    ]);
    expect(adapter.bodies[0]['name'], 'old');
    expect(adapter.bodies[0]['newName'], 'new');
    expect(adapter.bodies[1]['info'], 'data');
    expect(adapter.bodies[1]['page'], 2);
  });

  test('container image update schedule sends enabled flag', () async {
    final api = ContainerApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.checkImageUpdates();
    await api.setImageUpdateSchedule(true);
    expect(adapter.paths, [
      '/api/v2/containers/image-updates/check',
      '/api/v2/containers/image-updates/schedule',
    ]);
    expect(adapter.bodies[1]['enabled'], isTrue);
  });

  test('container log download keeps container and tail', () async {
    await ContainerApi(
      client,
    ).downloadLog(container: 'web', tail: 500, timestamp: true);
    expect(adapter.paths.single, '/api/v2/containers/download/log');
    expect(adapter.bodies.single['container'], 'web');
    expect(adapter.bodies.single['tail'], 500);
    expect(adapter.bodies.single['timestamp'], isTrue);
  });

  test('container file operations send container id and path', () async {
    final api = ContainerApi(client);
    adapter.responseData = <String>[];
    await api.listContainerFiles(containerId: 'web', path: '/app');
    adapter.responseData = null;
    await api.deleteContainerFiles(containerId: 'web', paths: ['/app/a.txt']);
    expect(adapter.paths, [
      '/api/v2/containers/files/search',
      '/api/v2/containers/files/del',
    ]);
    expect(adapter.bodies[0]['containerID'], 'web');
    expect(adapter.bodies[0]['path'], '/app');
    expect(adapter.bodies[1]['paths'], ['/app/a.txt']);
  });

  test('compose env and pin use backend fields', () async {
    final api = ContainerApi(client);
    adapter.responseData = 'FOO=bar';
    await api.loadComposeEnv('/opt/1panel/docker/compose/app');
    adapter.responseData = <String, dynamic>{};
    await api.setComposePin(name: 'app', isPinned: true);
    expect(adapter.paths, [
      '/api/v2/containers/compose/env',
      '/api/v2/containers/compose/pin',
    ]);
    expect(adapter.bodies[0]['path'], '/opt/1panel/docker/compose/app');
    expect(adapter.bodies[1]['isPinned'], isTrue);
  });

  test('file remarks batch fetch uses paths', () async {
    final api = FileApi(client);
    adapter.responseData = <String, dynamic>{
      'remarks': {'/root/a.txt': 'note'},
    };
    final remarks = await api.getFileRemarks(['/root/a.txt']);
    expect(remarks['/root/a.txt'], 'note');
    expect(adapter.paths, ['/api/v2/files/remarks']);
    expect(adapter.bodies.single['paths'], ['/root/a.txt']);
  });

  test('file remark, share qr and mounts use correct endpoints', () async {
    final api = FileApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.setFileRemark(path: '/root/a.txt', remark: 'note');
    await api.getHostMounts();
    expect(adapter.paths, ['/api/v2/files/remark', '/api/v2/files/mount']);
    expect(adapter.bodies[0]['remark'], 'note');
  });

  test('host cleanup endpoints send expected payloads', () async {
    final api = HostApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.cleanMonitor();
    await api.cleanSshLogs();
    expect(adapter.paths, [
      '/api/v2/hosts/monitor/clean',
      '/api/v2/hosts/ssh/log/clean',
    ]);
    expect(adapter.bodies[0]['type'], 'host');
  });

  test('panel firewall port sends old and new port', () async {
    adapter.responseData = <String, dynamic>{};
    await FirewallApi(client).updatePanelPort(oldPort: 10086, newPort: 20022);
    expect(adapter.paths.single, '/api/v2/hosts/firewall/port');
    expect(adapter.bodies.single['oldPort'], 10086);
    expect(adapter.bodies.single['newPort'], 20022);
  });

  test(
    'panel MFA close and expired password reset use core auth routes',
    () async {
      final api = SettingApi(client);
      adapter.responseData = <String, dynamic>{};
      await api.closeMFA();
      await api.resetExpiredPassword(oldPassword: 'old', newPassword: 'new');
      expect(adapter.paths, [
        '/api/v2/core/auth/mfa/close',
        '/api/v2/core/auth/expired/reset',
      ]);
      expect(adapter.bodies[1]['oldPassword'], 'old');
      expect(adapter.bodies[1]['newPassword'], 'new');
    },
  );

  test('script library uses core endpoints and payload fields', () async {
    final api = SettingApi(client);
    adapter.responseData = <String, dynamic>{'total': 0, 'items': <Object>[]};
    await api.searchScripts(info: 'deploy', page: 2, pageSize: 20);
    adapter.responseData = <String, dynamic>{};
    await api.createScript({'name': 's', 'script': 'echo 1', 'groups': ''});
    await api.deleteScripts([1, 2]);
    await api.syncScripts('task-1');
    expect(adapter.paths, [
      '/api/v2/core/script/search',
      '/api/v2/core/script',
      '/api/v2/core/script/del',
      '/api/v2/core/script/sync',
    ]);
    expect(adapter.bodies[0]['info'], 'deploy');
    expect(adapter.bodies[2]['ids'], [1, 2]);
    expect(adapter.bodies[3]['taskID'], 'task-1');
  });

  test('command library search and delete use backend fields', () async {
    final api = SettingApi(client);
    adapter.responseData = <String, dynamic>{'total': 0, 'items': <Object>[]};
    await api.searchCommands(info: 'deploy', page: 2);
    adapter.responseData = <String, dynamic>{};
    await api.deleteCommands(ids: [3, 4]);
    expect(adapter.paths, [
      '/api/v2/core/commands/search',
      '/api/v2/core/commands/del',
    ]);
    expect(adapter.bodies[0]['type'], 'command');
    expect(adapter.bodies[0]['orderBy'], 'createdAt');
    expect(adapter.bodies[1]['ids'], [3, 4]);
  });

  test('file preview and tree send path contracts', () async {
    final api = FileApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.previewFile('/root/a.txt', isDetail: true);
    adapter.responseData = <Object>[];
    await api.getFileTree(path: '/root', containSub: true);
    expect(adapter.paths, ['/api/v2/files/preview', '/api/v2/files/tree']);
    expect(adapter.bodies[0]['isDetail'], isTrue);
    expect(adapter.bodies[1]['containSub'], isTrue);
    expect(adapter.bodies[1]['dir'], isTrue);
  });

  test('core group endpoints send type and ids', () async {
    final api = SettingApi(client);
    adapter.responseData = <Object>[];
    await api.searchGroups(type: 'script');
    adapter.responseData = <String, dynamic>{};
    await api.createGroup(name: 'g', type: 'script');
    await api.updateGroup(id: 2, name: 'g2', type: 'script');
    await api.deleteGroup(2);
    expect(adapter.paths, [
      '/api/v2/core/groups/search',
      '/api/v2/core/groups',
      '/api/v2/core/groups/update',
      '/api/v2/core/groups/del',
    ]);
    expect(adapter.bodies[0]['type'], 'script');
    expect(adapter.bodies[2]['id'], 2);
    expect(adapter.bodies[3]['id'], 2);
  });

  test('AI account model operations use backend fields', () async {
    final api = AiApi(client);
    adapter.responseData = <Object>[];
    await api.getAccountModels(1);
    adapter.responseData = <String, dynamic>{};
    await api.createAccountModel(accountId: 1, id: 'gpt-4o', name: 'GPT');
    await api.setAccountVerifyModel(accountId: 1, recordId: 9);
    await api.deleteAccountModel(accountId: 1, recordId: 9);
    await api.verifyAccount(id: 1, model: 'gpt-4o');
    expect(adapter.paths, [
      '/api/v2/ai/accounts/models',
      '/api/v2/ai/accounts/models/create',
      '/api/v2/ai/accounts/models/verify-model',
      '/api/v2/ai/accounts/models/delete',
      '/api/v2/ai/accounts/verify',
    ]);
    expect(adapter.bodies[1]['model']['id'], 'gpt-4o');
    expect(adapter.bodies[2]['recordId'], 9);
    expect(adapter.bodies[3]['recordId'], 9);
  });

  test(
    'file upload records, convert and wget cleanup use backend fields',
    () async {
      final api = FileApi(client);
      adapter.responseData = <String, dynamic>{'total': 0, 'items': <Object>[]};
      await api.searchUploadFiles(path: '/root', page: 2, pageSize: 20);
      adapter.responseData = <String, dynamic>{};
      await api.removeWgetRecords(['file-wget-1']);
      await api.convertFiles(
        files: [
          {
            'type': 'video',
            'path': '/root',
            'inputFile': 'a.mov',
            'extension': '.mov',
            'outputFormat': 'mp4',
          },
        ],
        outputPath: '/root/out',
        deleteSource: true,
        taskID: 'task-1',
      );
      adapter.responseData = <String, dynamic>{'total': 0, 'items': <Object>[]};
      await api.convertLogs(page: 1, pageSize: 20);
      adapter.responseData = <String, dynamic>{};
      await api.chunkDownload(path: '/root/a.bin', name: 'a.bin');
      expect(adapter.paths, [
        '/api/v2/files/upload/search',
        '/api/v2/files/wget/process/remove',
        '/api/v2/files/convert',
        '/api/v2/files/convert/log',
        '/api/v2/files/chunkdownload',
      ]);
      expect(adapter.bodies[0]['page'], 2);
      expect(adapter.bodies[1]['keys'], ['file-wget-1']);
      expect(adapter.bodies[2]['deleteSource'], isTrue);
      expect(adapter.bodies[2]['taskID'], 'task-1');
      expect(adapter.bodies[3]['pageSize'], 20);
      expect(adapter.bodies[4]['name'], 'a.bin');
    },
  );

  test(
    'firewall family, filter chain and docker policies use backend fields',
    () async {
      final api = FirewallApi(client);
      adapter.responseData = <String, dynamic>{'taskID': '', 'queued': false};
      await api.operateFamily(
        subsystem: 'docker',
        backend: 'nftables',
        family: 'ipv6',
        operation: 'repair',
      );
      await api.operateFilterChain(operation: 'bind-base');
      await api.upsertDockerPolicies([
        {
          'family': 'ipv4',
          'hostIP': '0.0.0.0',
          'hostPort': 8080,
          'protocol': 'tcp',
          'mode': 'allow_sources',
          'sources': ['10.0.0.0/8'],
        },
      ]);
      await api.deleteDockerPolicies(['uuid-1']);
      expect(adapter.paths, [
        '/api/v2/hosts/firewall/family/operate',
        '/api/v2/hosts/firewall/filter/operate',
        '/api/v2/hosts/firewall/docker/policies/batch',
        '/api/v2/hosts/firewall/docker/policies/delete/batch',
      ]);
      expect(adapter.bodies[0]['subsystem'], 'docker');
      expect(adapter.bodies[0]['family'], 'ipv6');
      expect(adapter.bodies[1]['name'], '1PANEL_BASIC');
      expect(adapter.bodies[1]['operate'], 'bind-base');
      expect(adapter.bodies[2]['policies'][0]['mode'], 'allow_sources');
      expect(adapter.bodies[3]['uuids'], ['uuid-1']);
    },
  );

  test('remote host management uses host routes and fields', () async {
    final api = HostApi(client);
    adapter.responseData = <String, dynamic>{'total': 0, 'items': <Object>[]};
    await api.searchRemoteHosts(page: 2, groupId: 3, info: 'prod');
    adapter.responseData = <Object>[];
    await api.getRemoteHostTree(info: 'prod');
    adapter.responseData = <String, dynamic>{};
    await api.createRemoteHost({'addr': '1.1.1.1', 'port': 22});
    await api.updateRemoteHost({'id': 1, 'addr': '1.1.1.2'});
    await api.deleteRemoteHosts([1, 2]);
    adapter.responseData = true;
    await api.testRemoteHost({'addr': '1.1.1.1', 'port': 22});
    await api.testRemoteHostById(1);
    expect(adapter.paths, [
      '/api/v2/hosts/search',
      '/api/v2/hosts/tree',
      '/api/v2/hosts',
      '/api/v2/hosts/update',
      '/api/v2/hosts/del',
      '/api/v2/hosts/test/byinfo',
      '/api/v2/hosts/test/byid',
    ]);
    expect(adapter.bodies[0]['groupID'], 3);
    expect(adapter.bodies[0]['info'], 'prod');
    expect(adapter.bodies[4]['ids'], [1, 2]);
    expect(adapter.bodies[6]['id'], 1);
  });

  test('command tree, import and export use core command routes', () async {
    final api = SettingApi(client);
    adapter.responseData = <Object>[];
    await api.searchCommandTree();
    adapter.responseData = <String, dynamic>{};
    await api.importCommands([
      {'type': 'command', 'name': 'ls', 'command': 'ls -la'},
    ]);
    adapter.responseData = '/tmp/commands.csv';
    final path = await api.exportCommands();
    expect(path, '/tmp/commands.csv');
    expect(adapter.paths, [
      '/api/v2/core/commands/tree',
      '/api/v2/core/commands/import',
      '/api/v2/core/commands/export',
    ]);
    expect(adapter.bodies[0]['type'], 'command');
    expect(adapter.bodies[1]['items'][0]['name'], 'ls');
  });

  test('AI plugin, skill, GPU and Ollama routes use backend fields', () async {
    final api = AiApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.recreateOllamaModel('llama3');
    await api.syncOllamaAccount(
      id: 2,
      baseUrlType: 'custom',
      baseUrl: 'http://127.0.0.1:11434',
    );
    adapter.responseData = <String, dynamic>{};
    await api.getGpuOptions();
    adapter.responseData = <String, dynamic>{};
    await api.searchGpuMonitor(
      startTime: DateTime.utc(2026, 1, 1),
      endTime: DateTime.utc(2026, 1, 2),
      deviceID: '0',
      productName: 'GPU',
      legacy: true,
    );
    adapter.responseData = <Object>[];
    await api.getBenchmarkSources(kind: 'gpu', selected: 'a');
    await api.listAgentPlugins(3);
    await api.searchAgentPlugins(agentId: 3, keyword: 'web');
    adapter.responseData = <String, dynamic>{};
    await api.installAgentMarketPlugin(
      agentId: 3,
      package: 'pkg',
      version: '1.0.0',
      taskID: 'task-1',
    );
    await api.operateAgentPlugin(
      agentId: 3,
      pluginId: 'p1',
      operate: 'enable',
      taskID: 'task-2',
    );
    adapter.responseData = <Object>[];
    await api.listAgentSkills(3);
    await api.searchAgentSkills(agentId: 3, source: 'official', keyword: 'pdf');
    adapter.responseData = <String, dynamic>{};
    await api.installAgentSkill(
      agentId: 3,
      source: 'official',
      slug: 'pdf',
      taskID: 'task-3',
    );
    await api.updateAgentSkill(agentId: 3, name: 'pdf', enabled: false);
    await api.uninstallAgentSkill(agentId: 3, name: 'pdf');
    expect(adapter.paths, [
      '/api/v2/ai/ollama/model/recreate',
      '/api/v2/ai/ollama/account/sync',
      '/api/v2/ai/gpu/options',
      '/api/v2/ai/gpu/search',
      '/api/v2/ai/benchmark/sources',
      '/api/v2/ai/agents/plugins/list',
      '/api/v2/ai/agents/plugins/search',
      '/api/v2/ai/agents/plugins/install',
      '/api/v2/ai/agents/plugins/operate',
      '/api/v2/ai/agents/skills/list',
      '/api/v2/ai/agents/skills/search',
      '/api/v2/ai/agents/skills/install',
      '/api/v2/ai/agents/skills/update',
      '/api/v2/ai/agents/skills/uninstall',
    ]);
    expect(adapter.bodies[1]['modelAccountBaseURLType'], 'custom');
    expect(adapter.bodies[3]['legacy'], isTrue);
    expect(adapter.bodies[6]['keyword'], 'web');
    expect(adapter.bodies[8]['operate'], 'enable');
    expect(adapter.bodies[10]['source'], 'official');
    expect(adapter.bodies[13]['name'], 'pdf');
  });

  test('GPU devices, batch agents and Hermes routes use fields', () async {
    final api = AiApi(client);
    adapter.responseData = <String, dynamic>{'devices': <Object>[]};
    await api.getModelGpuDevices();
    adapter.responseData = <Object>[
      {'success': true, 'skipped': false},
    ];
    await api.batchOperateAgents({
      'agentType': 'openclaw',
      'operate': 'restart',
      'taskID': 'task-1',
    });
    adapter.responseData = <String, dynamic>{'snapshot': <String, dynamic>{}};
    await api.getAgentOverview(5);
    adapter.responseData = <Object>[
      {'id': 's1', 'title': 'Session'},
    ];
    await api.getHermesChatSessions(5);
    adapter.responseData = <String, dynamic>{};
    await api.renameHermesChatSession(agentId: 5, id: 's1', title: 'New');
    await api.deleteHermesChatSession(agentId: 5, id: 's1');
    expect(adapter.paths, [
      '/api/v2/ai/model/gpu/devices',
      '/api/v2/ai/agents/batch/operate',
      '/api/v2/ai/agents/overview',
      '/api/v2/ai/agents/hermes/chat/sessions',
      '/api/v2/ai/agents/hermes/chat/sessions/rename',
      '/api/v2/ai/agents/hermes/chat/sessions/delete',
    ]);
    expect(adapter.bodies[1]['operate'], 'restart');
    expect(adapter.bodies[4]['title'], 'New');
  });

  test('panel MCP routes and payloads match the core API', () async {
    final api = McpApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.getStatus();
    await api.getSettings();
    await api.updateSettings({'listenPort': 18081, 'revision': 2});
    await api.getCatalog();
    adapter.responseData = <Object>[];
    await api.getNodes();
    adapter.responseData = <String, dynamic>{};
    await api.operateService('restart');
    await api.installService({'dockerImage': 'image', 'listenPort': 18081});
    await api.getServiceLogs();
    await api.getWebsiteStatus();
    await api.bindWebsite({'requestId': 'r1', 'domain': 'mcp.test'});
    await api.updateWebsite({'requestId': 'r2', 'revision': 2});
    await api.unbindWebsite({'requestId': 'r3', 'revision': 2});
    adapter.responseData = <String, dynamic>{'items': <Object>[]};
    await api.searchCredentials();
    adapter.responseData = <String, dynamic>{'item': <String, dynamic>{}};
    await api.createCredential({'name': 'ci'});
    adapter.responseData = <String, dynamic>{};
    await api.updateCredential({'id': 'c1', 'revision': 1});
    await api.setCredentialStatus(id: 'c1', revision: 1, status: 'Disable');
    await api.revokeCredential(id: 'c1', revision: 1);
    await api.deleteCredential(id: 'c1', revision: 2);
    await api.revealCredential(id: 'c1', revision: 2);
    await api.rotateCredential(id: 'c1', revision: 3);
    await api.exportCredential(id: 'c1', revision: 4, client: 'claude');
    await api.searchInvocations();
    expect(adapter.paths, [
      '/api/v2/core/mcp/status',
      '/api/v2/core/mcp/settings',
      '/api/v2/core/mcp/settings',
      '/api/v2/core/mcp/catalog',
      '/api/v2/core/mcp/nodes',
      '/api/v2/core/mcp/service/operate',
      '/api/v2/core/mcp/service/install',
      '/api/v2/core/mcp/service/logs',
      '/api/v2/core/mcp/website/status',
      '/api/v2/core/mcp/website/bind',
      '/api/v2/core/mcp/website/update',
      '/api/v2/core/mcp/website/unbind',
      '/api/v2/core/mcp/credentials/search',
      '/api/v2/core/mcp/credentials/create',
      '/api/v2/core/mcp/credentials/update',
      '/api/v2/core/mcp/credentials/status',
      '/api/v2/core/mcp/credentials/revoke',
      '/api/v2/core/mcp/credentials/delete',
      '/api/v2/core/mcp/credentials/reveal',
      '/api/v2/core/mcp/credentials/rotate',
      '/api/v2/core/mcp/credentials/export',
      '/api/v2/core/mcp/invocations/search',
    ]);
    expect(adapter.bodies[2]['revision'], 2);
    expect(adapter.bodies[5], {'operation': 'restart'});
    expect(adapter.bodies[12]['pageSize'], 50);
    expect(adapter.bodies[14]['id'], 'c1');
    expect(adapter.bodies[20]['client'], 'claude');
    expect(adapter.bodies[13]['requestID'], isNotEmpty);
  });

  test('dashboard quick, launcher, top and node routes use fields', () async {
    final api = DashboardApi(client);
    adapter.responseData = <Object>[];
    await api.getQuickOptions();
    adapter.responseData = <String, dynamic>{};
    await api.changeQuick([
      {'id': 1, 'isShow': true},
    ]);
    adapter.responseData = <Object>[];
    await api.getQuickDirectories();
    adapter.responseData = <String, dynamic>{};
    await api.createQuickDirectory(path: '/root', alias: 'root');
    await api.updateQuickDirectory(id: 1, path: '/opt', alias: 'opt');
    await api.deleteQuickDirectory(id: 1);
    adapter.responseData = <Object>[];
    await api.getAppLauncher();
    await api.getAppLauncherOptions(filter: 'web');
    adapter.responseData = <String, dynamic>{};
    await api.updateAppLauncherShow(key: 'openresty', show: true);
    adapter.responseData = <Object>[];
    await api.getTopCpu();
    await api.getTopMem();
    adapter.responseData = <String, dynamic>{'load1': 0.1};
    await api.getNodeCurrent();
    expect(adapter.paths, [
      '/api/v2/dashboard/quick/option',
      '/api/v2/dashboard/quick/change',
      '/api/v2/dashboard/quick/directory',
      '/api/v2/dashboard/quick/directory',
      '/api/v2/dashboard/quick/directory/update',
      '/api/v2/dashboard/quick/directory/del',
      '/api/v2/dashboard/app/launcher',
      '/api/v2/dashboard/app/launcher/option',
      '/api/v2/dashboard/app/launcher/show',
      '/api/v2/dashboard/current/top/cpu',
      '/api/v2/dashboard/current/top/mem',
      '/api/v2/dashboard/current/node',
    ]);
    expect(adapter.bodies[1]['quicks'][0]['id'], 1);
    expect(adapter.bodies[3]['alias'], 'root');
    expect(adapter.bodies[7]['filter'], 'web');
    expect(adapter.bodies[8]['value'], 'Enable');
  });

  test('public file share info and check use code and password', () async {
    final api = FileApi(client);
    adapter.responseData = <String, dynamic>{
      'fileName': 'a.txt',
      'expiresAt': 0,
      'permanent': true,
      'hasPassword': false,
    };
    await api.getPublicShareInfo('abc123');
    adapter.responseData = <String, dynamic>{};
    await api.checkFileShare(code: 'abc123', password: 'pwd');
    expect(adapter.paths, [
      '/api/v2/files/share/info',
      '/api/v2/files/share/check',
    ]);
    expect(adapter.bodies[0], isEmpty);
  });

  test('backup account search sends info instead of name', () async {
    adapter.responseData = <String, dynamic>{'total': 0, 'items': <Object>[]};
    await BackupApi(
      client,
    ).searchBackupAccounts(page: 1, pageSize: 20, name: 's3-main');
    expect(adapter.paths.single, '/api/v2/backups/search');
    expect(adapter.bodies.single['info'], 's3-main');
    expect(adapter.bodies.single.containsKey('name'), isFalse);
  });

  test('backup record extras and cron job extras use fields', () async {
    final backup = BackupApi(client);
    adapter.responseData = <String, dynamic>{};
    await backup.checkBackupName('local');
    adapter.responseData = <Object>['a.tar.gz'];
    await backup.searchRecordFiles(1);
    adapter.responseData = <String, dynamic>{'total': 0, 'items': <Object>[]};
    await backup.searchRecordsByCronjob(cronjobId: 2);
    adapter.responseData = <String, dynamic>{};
    await backup.updateRecordDescription(id: 1, description: 'note');
    final cron = CronjobApi(client);
    adapter.responseData = <Object>['2026-01-01 00:00:00'];
    await cron.getNextRun('0 0 * * *');
    adapter.responseData = <String, dynamic>{};
    await cron.updateCronjobGroup(id: 2, groupId: 3);
    expect(adapter.paths, [
      '/api/v2/backups/check/local',
      '/api/v2/backups/search/files',
      '/api/v2/backups/record/search/bycronjob',
      '/api/v2/backups/record/description/update',
      '/api/v2/cronjobs/next',
      '/api/v2/cronjobs/group/update',
    ]);
    expect(adapter.bodies[1]['id'], 1);
    expect(adapter.bodies[2]['cronjobID'], 2);
    expect(adapter.bodies[4]['spec'], '0 0 * * *');
    expect(adapter.bodies[5]['groupID'], 3);
  });

  test('app update status, installed webUI and alert config status', () async {
    final app = AppApi(client);
    adapter.responseData = <String, dynamic>{'canUpdate': true};
    await app.checkAppUpdates();
    adapter.responseData = <String, dynamic>{};
    await app.updateInstalledConfig(
      installId: 1,
      webUI: 'http://127.0.0.1:8080',
    );
    final alert = AlertApi(client);
    await alert.updateAlertConfigStatus(2, 'Disable');
    expect(adapter.paths, [
      '/api/v2/apps/checkupdate',
      '/api/v2/apps/installed/config/update',
      '/api/v2/alert/config/status',
    ]);
    expect(adapter.bodies[1]['webUI'], 'http://127.0.0.1:8080');
    expect(adapter.bodies[2]['status'], 'Disable');
  });

  test('alert config search, clam targets and cronjob targets', () async {
    final alert = AlertApi(client);
    adapter.responseData = <String, dynamic>{'total': 0, 'items': <dynamic>[]};
    await alert.searchAlertConfigs(
      const AlertConfigSearchReq(page: 1, pageSize: 20, excludeTypes: ['x']),
    );
    adapter.responseData = <dynamic>[];
    await alert.listClams();
    await alert.listAlertCronJobs(name: 'backup', status: 'Enable');
    expect(adapter.paths, [
      '/api/v2/alert/config/search',
      '/api/v2/alert/clams/list',
      '/api/v2/alert/cronjob/list',
    ]);
    expect(adapter.bodies.first['excludeTypes'], ['x']);
    expect(adapter.bodies.last['type'], '');
    expect(adapter.methods[1], 'GET');
  });

  test('host ssh log search and export use filters', () async {
    final host = HostApi(client);
    final req = SshLogSearchReq(
      page: 2,
      pageSize: 50,
      info: 'root',
      status: 'Failed',
      startTime: DateTime.utc(2026, 1, 1),
      endTime: DateTime.utc(2026, 1, 2),
    );
    adapter.responseData = <String, dynamic>{'total': 0, 'items': <dynamic>[]};
    await host.searchSshLogs(req);
    adapter.responseData = '/tmp/ssh.log';
    final path = await host.exportSshLogs(req);
    expect(path, '/tmp/ssh.log');
    expect(adapter.paths, [
      '/api/v2/hosts/ssh/log',
      '/api/v2/hosts/ssh/log/export',
    ]);
    expect(adapter.bodies[0]['Status'], 'Failed');
    expect(adapter.bodies[1]['page'], 2);
    expect(adapter.bodies[1]['startTime'], '2026-01-01T00:00:00.000Z');
  });

  test('ai batch install, security, config file and domain', () async {
    final ai = AiApi(client);
    adapter.responseData = <dynamic>[];
    await ai.batchInstallAgents({
      'agentType': 'openclaw',
      'appVersion': '1.0.0',
      'webUIPort': 18789,
    });
    await ai.batchUpgradeAgents({
      'agentType': 'openclaw',
      'targetVersion': '1.1.0',
      'backup': true,
    });
    adapter.responseData = <String, dynamic>{
      'allowedOrigins': ['https://a.example'],
    };
    final origins = await ai.getAgentSecurity(7);
    await ai.updateAgentSecurity(7, origins);
    adapter.responseData = <String, dynamic>{'content': 'name: demo'};
    final content = await ai.getAgentConfigFile(7);
    await ai.updateAgentConfigFile(7, content);
    adapter.responseData = <String, dynamic>{'domain': 'ai.example'};
    await ai.getAiDomain(9);
    adapter.responseData = <String, dynamic>{};
    await ai.bindAiDomain({'domain': 'ai.example', 'appInstallID': 9});
    await ai.updateAiDomain({'domain': 'ai.example', 'appInstallID': 9});
    expect(adapter.paths, [
      '/api/v2/ai/agents/batch/install',
      '/api/v2/ai/agents/batch/upgrade',
      '/api/v2/ai/agents/security/get',
      '/api/v2/ai/agents/security/update',
      '/api/v2/ai/agents/config-file/get',
      '/api/v2/ai/agents/config-file/update',
      '/api/v2/ai/domain/get',
      '/api/v2/ai/domain/bind',
      '/api/v2/ai/domain/update',
    ]);
    expect(origins, ['https://a.example']);
    expect(content, 'name: demo');
    expect(adapter.bodies[3]['agentId'], 7);
    expect(adapter.bodies[6]['appInstallID'], 9);
  });

  test('file batch move keeps paths and task id', () async {
    final files = FileApi(client);
    adapter.responseData = <String, dynamic>{};
    await files.moveCopyFiles(
      oldPaths: const ['/opt/a', '/opt/b'],
      newPath: '/opt/target',
      type: 'cut',
      cover: true,
      taskID: 'task-1',
    );
    expect(adapter.paths, ['/api/v2/files/move']);
    expect(adapter.bodies.single['oldPaths'], ['/opt/a', '/opt/b']);
    expect(adapter.bodies.single['newPath'], '/opt/target');
    expect(adapter.bodies.single['type'], 'cut');
    expect(adapter.bodies.single['cover'], isTrue);
  });

  test('vm environment, search, operate and snapshots use contracts', () async {
    final vm = VmApi(client);
    adapter.responseData = <String, dynamic>{'ready': true, 'arch': 'x86_64'};
    final env = await vm.checkEnvironment();
    adapter.responseData = <String, dynamic>{
      'total': 0,
      'items': <dynamic>[],
      'limit': 5,
    };
    final page = await vm.searchVms();
    adapter.responseData = <String, dynamic>{};
    await vm.operateVm('demo', 'start');
    adapter.responseData = <String, dynamic>{
      'name': 'demo',
      'status': 'running',
    };
    final stats = await vm.getVmStats('demo');
    adapter.responseData = <dynamic>[];
    await vm.listSnapshots('demo');
    await vm.listNetworks();
    expect(adapter.paths, [
      '/api/v2/vms/environment',
      '/api/v2/vms/search',
      '/api/v2/vms/operate',
      '/api/v2/vms/stats',
      '/api/v2/vms/snapshots/list',
      '/api/v2/vms/networks/list',
    ]);
    expect(env['arch'], 'x86_64');
    expect(page['limit'], 5);
    expect(stats['status'], 'running');
    expect(adapter.bodies[2]['operate'], 'start');
  });

  test('ssh cert create base64 encodes key material', () async {
    adapter.responseData = <String, dynamic>{};
    await HostApi(client).createCert(
      SshCertOperateReq(
        name: 'deploy',
        encryptionMode: 'rsa',
        mode: 'import',
        passPhrase: 'secret',
        privateKey: 'PRIVATE',
        publicKey: 'PUBLIC',
      ),
    );
    expect(adapter.paths.single, '/api/v2/hosts/ssh/cert');
    expect(
      adapter.bodies.single['passPhrase'],
      base64Encode(utf8.encode('secret')),
    );
    expect(
      adapter.bodies.single['privateKey'],
      base64Encode(utf8.encode('PRIVATE')),
    );
    expect(
      adapter.bodies.single['publicKey'],
      base64Encode(utf8.encode('PUBLIC')),
    );
  });

  test('ai batch install accepts a single agent object', () async {
    adapter.responseData = <String, dynamic>{
      'id': 9,
      'name': 'openclaw-1',
      'agentType': 'openclaw',
      'status': 'installing',
    };
    final results = await AiApi(client).batchInstallAgents({
      'appVersion': '1.0.0',
      'webUIPort': 8080,
      'agentType': 'openclaw',
    });
    expect(results, hasLength(1));
    expect(results.single['id'], 9);
    expect(results.single['agentType'], 'openclaw');
  });

  test('ai model discovery and channel plugin contracts', () async {
    final ai = AiApi(client);
    adapter.responseData = <dynamic>[];
    await ai.discoverAgentAccountModels(
      provider: 'openai',
      baseURL: 'https://api.example/v1',
      apiKey: 'key',
      apiType: 'openai',
    );
    adapter.responseData = <String, dynamic>{};
    await ai.installAgentChannelPlugin(
      agentId: 3,
      type: 'feishu',
      taskID: 't1',
    );
    await ai.upgradeAgentChannelPlugin(
      agentId: 3,
      type: 'feishu',
      taskID: 't2',
    );
    await ai.uninstallAgentChannelPlugin(
      agentId: 3,
      type: 'feishu',
      taskID: 't3',
    );
    adapter.responseData = <String, dynamic>{
      'installed': true,
      'upgradable': true,
    };
    final status = await ai.checkAgentChannelPlugin(agentId: 3, type: 'feishu');
    expect(adapter.paths, [
      '/api/v2/ai/accounts/models/discover',
      '/api/v2/ai/agents/plugin/install',
      '/api/v2/ai/agents/plugin/upgrade',
      '/api/v2/ai/agents/plugin/uninstall',
      '/api/v2/ai/agents/plugin/check',
    ]);
    expect(adapter.bodies.first['baseURL'], 'https://api.example/v1');
    expect(adapter.bodies.last['checkLatest'], isTrue);
    expect(status['upgradable'], isTrue);
  });

  test('vm resource create update delete contracts', () async {
    final vm = VmApi(client);
    adapter.responseData = <dynamic>[];
    await vm.listIsos();
    adapter.responseData = <String, dynamic>{};
    await vm.createIso({'type': 'iso', 'name': 'a', 'path': '/a.iso'});
    await vm.updateIso({'id': 1, 'type': 'iso', 'name': 'b', 'path': '/b.iso'});
    await vm.deleteIso(1, deleteFile: true);
    await vm.createNetwork({'name': 'nat1', 'type': 'nat'});
    await vm.updateNetwork({'id': 2, 'autoStart': false});
    await vm.deleteNetwork(2);
    await vm.createStorage({'name': 'dir1', 'type': 'dir', 'path': '/vm'});
    await vm.updateStorage({'id': 3, 'autoStart': false});
    await vm.deleteStorage(3);
    expect(adapter.paths, [
      '/api/v2/vms/iso/list',
      '/api/v2/vms/iso',
      '/api/v2/vms/iso/update',
      '/api/v2/vms/iso/del',
      '/api/v2/vms/networks',
      '/api/v2/vms/networks/update',
      '/api/v2/vms/networks/del',
      '/api/v2/vms/storages',
      '/api/v2/vms/storages/update',
      '/api/v2/vms/storages/del',
    ]);
    expect(adapter.bodies[3]['deleteFile'], isTrue);
    expect(adapter.bodies[5]['autoStart'], isFalse);
  });

  test('ai channel pairing approval contract', () async {
    final ai = AiApi(client);
    adapter.responseData = <String, dynamic>{};
    await ai.approveAgentChannelPairing(
      agentId: 4,
      type: 'feishu',
      pairingCode: 'ABCD',
      accountId: 'acc-1',
    );
    expect(adapter.paths, ['/api/v2/ai/agents/channel/pairing/approve']);
    expect(adapter.bodies.single['pairingCode'], 'ABCD');
    expect(adapter.bodies.single['accountId'], 'acc-1');
  });

  test('website log clear uses operate contract', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{};
    await websites.operateWebsiteLog(
      8,
      type: WebsiteLogType.access,
      operate: 'delete',
    );
    expect(adapter.paths, ['/api/v2/websites/log/operate']);
    expect(adapter.bodies.single['id'], 8);
    expect(adapter.bodies.single['operate'], 'delete');
    expect(adapter.bodies.single['logType'], WebsiteLogType.access.fileName);
  });

  test('website load balance file update contract', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{};
    await websites.updateLoadBalanceFile(
      websiteId: 5,
      name: 'upstream1',
      content: 'upstream upstream1 {}',
    );
    expect(adapter.paths, ['/api/v2/websites/lbs/file']);
    expect(adapter.bodies.single['websiteID'], 5);
    expect(adapter.bodies.single['content'], 'upstream upstream1 {}');
  });

  test('website stream create sends stream config', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{};
    await websites.createWebsite(
      const WebsiteCreateReq(
        alias: 'stream1',
        type: 'stream',
        domains: [],
        streamPorts: '8080',
        name: 'backend',
        algorithm: 'roundrobin',
        udp: true,
        servers: [
          {'server': '127.0.0.1:80', 'weight': 1},
        ],
      ),
    );
    final body = adapter.bodies.single;
    expect(body['type'], 'stream');
    expect(body['streamPorts'], '8080');
    expect(body['name'], 'backend');
    expect(body['algorithm'], 'roundrobin');
    expect(body['udp'], isTrue);
    expect((body['servers'] as List).first['server'], '127.0.0.1:80');
  });

  test('website subsite create sends parent and site dir', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{};
    await websites.createWebsite(
      const WebsiteCreateReq(
        alias: 'sub1',
        type: 'subsite',
        domains: [],
        parentWebsiteID: 12,
        siteDir: '/sub',
      ),
    );
    final body = adapter.bodies.single;
    expect(body['type'], 'subsite');
    expect(body['parentWebsiteID'], 12);
    expect(body['siteDir'], '/sub');
  });

  test('website deployment create sends installed app id', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{};
    await websites.createWebsite(
      const WebsiteCreateReq(
        alias: 'app1',
        type: 'deployment',
        domains: [],
        appType: 'installed',
        appInstallID: 21,
      ),
    );
    final body = adapter.bodies.single;
    expect(body['type'], 'deployment');
    expect(body['appType'], 'installed');
    expect(body['appInstallID'], 21);
  });

  test('website pre-install check sends install ids', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <Map<String, dynamic>>[
      {
        'appName': 'WordPress',
        'name': 'wp',
        'status': 'Running',
        'version': '6.5',
      },
    ];
    final checks = await websites.checkWebsiteInstall([11, 12]);
    expect(adapter.bodies.single['InstallIds'], [11, 12]);
    expect(checks.single.isRunning, isTrue);
    expect(checks.single.appName, 'WordPress');
  });

  test('website template preview sends template and values', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{'html': '<h1>Hi</h1>'};
    final html = await websites.previewTemplate(
      templateID: 3,
      variableValues: {'name': 'OneDash'},
    );
    final body = adapter.bodies.single;
    expect(body['templateID'], 3);
    expect(body['variableValues'], {'name': 'OneDash'});
    expect(html, '<h1>Hi</h1>');
  });

  test('website template output detail uses id', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{
      'id': 7,
      'name': 'out',
      'outputPath': '/opt/1panel/www/sites/out',
    };
    final output = await websites.getTemplateOutput(7);
    expect(adapter.bodies.single['id'], 7);
    expect(output.outputPath, '/opt/1panel/www/sites/out');
  });

  test('website group change sends numeric ids', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{};
    await websites.changeWebsiteGroup(2, 5);
    final body = adapter.bodies.single;
    expect(body['group'], 2);
    expect(body['newGroup'], 5);
  });

  test(
    'terminal AI setting update sends status, prefix and risk text',
    () async {
      final settings = SettingApi(client);
      adapter.responseData = <String, dynamic>{};
      await settings.updateTerminalAiSetting(
        aiStatus: 'Enable',
        aiPrefix: '#ai',
        aiAccountId: 'acc-1',
        aiRiskCommands: 'rm -rf',
      );
      final body = adapter.bodies.single;
      expect(body['aiStatus'], 'Enable');
      expect(body['aiPrefix'], '#ai');
      expect(body['aiAccountId'], 'acc-1');
      expect(body['aiRiskCommands'], 'rm -rf');
    },
  );

  test('file history setting update sends quota fields', () async {
    final settings = SettingApi(client);
    adapter.responseData = <String, dynamic>{};
    await settings.updateFileHistorySetting(
      enable: 'Enable',
      maxPerPath: 20,
      diskQuotaMB: 512,
    );
    final body = adapter.bodies.single;
    expect(body['enable'], 'Enable');
    expect(body['maxPerPath'], 20);
    expect(body['diskQuotaMB'], 512);
  });

  test('SSH default connection update sends name', () async {
    final settings = SettingApi(client);
    adapter.responseData = <String, dynamic>{};
    await settings.setSshDefaultConn(defaultConn: 'local', withReset: true);
    expect(adapter.paths.single, '/api/v2/settings/ssh/default');
    expect(adapter.bodies.single['defaultConn'], 'local');
    expect(adapter.bodies.single['withReset'], isTrue);
  });

  test('menu reset calls core default endpoint', () async {
    final settings = SettingApi(client);
    adapter.responseData = <String, dynamic>{};
    await settings.resetMenuSetting();
    expect(adapter.paths.single, '/api/v2/core/settings/menu/default');
    expect(adapter.methods.single, 'POST');
  });

  test('OpenResty module update sends module payload', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{};
    await websites.updateOpenRestyModule({
      'name': 'headers-more',
      'operate': 'update',
      'enable': true,
    });
    expect(adapter.paths.single, '/api/v2/openresty/modules/update');
    expect(adapter.bodies.single['name'], 'headers-more');
    expect(adapter.bodies.single['enable'], isTrue);
  });

  test('OpenResty build sends mirror, task and modules', () async {
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{};
    await websites.buildOpenResty(
      mirror: 'https://example.com',
      taskID: 'task-1',
      modules: ['headers-more'],
      force: true,
    );
    final body = adapter.bodies.single;
    expect(body['mirror'], 'https://example.com');
    expect(body['taskID'], 'task-1');
    expect(body['modules'], ['headers-more']);
    expect(body['force'], isTrue);
  });

  test(
    'OpenResty default HTTPS update sends operate and reject flag',
    () async {
      final websites = WebsiteApi(client);
      adapter.responseData = <String, dynamic>{};
      await websites.updateOpenRestyHttps(
        operate: 'enable',
        sslRejectHandshake: true,
      );
      final body = adapter.bodies.single;
      expect(body['operate'], 'enable');
      expect(body['sslRejectHandshake'], isTrue);
    },
  );

  test('system log read sends filters and cursor', () async {
    final logs = LogApi(client);
    adapter.responseData = <String, dynamic>{
      'items': [
        {
          'time': '2026-01-01T00:00:00Z',
          'service': 'nginx',
          'priority': 'err',
          'message': 'boom',
        },
      ],
      'hasMore': true,
      'nextCursor': 'c2',
    };
    final page = await logs.readSystemLog(
      keyword: 'error',
      service: 'nginx',
      priority: 'err',
      cursor: 'c1',
      pageSize: 20,
    );
    final body = adapter.bodies.single;
    expect(body['keyword'], 'error');
    expect(body['service'], 'nginx');
    expect(body['priority'], 'err');
    expect(body['cursor'], 'c1');
    expect(body['pageSize'], 20);
    expect(page.items.single.message, 'boom');
    expect(page.hasMore, isTrue);
    expect(page.nextCursor, 'c2');
  });

  test('system log status parses source flags', () async {
    final logs = LogApi(client);
    adapter.responseData = <String, dynamic>{
      'source': 'journalctl',
      'version': '255',
      'message': 'ready',
      'keywordFilterSupported': true,
    };
    final status = await logs.getSystemLogStatus();
    expect(adapter.paths.single, '/api/v2/logs/system/status');
    expect(status.source, 'journalctl');
    expect(status.keywordFilterSupported, isTrue);
  });

  test('clam rule update sends id and strategy', () async {
    final toolbox = ToolboxApi(client);
    adapter.responseData = <String, dynamic>{};
    await toolbox.updateClam({
      'id': 4,
      'name': 'scan-home',
      'path': '/home',
      'infectedStrategy': 'remove',
    });
    expect(adapter.paths.single, '/api/v2/toolbox/clam/update');
    expect(adapter.bodies.single['id'], 4);
    expect(adapter.bodies.single['infectedStrategy'], 'remove');
  });

  test('clam status update sends status', () async {
    final toolbox = ToolboxApi(client);
    adapter.responseData = <String, dynamic>{};
    await toolbox.updateClamStatus(4, 'Disable');
    expect(adapter.bodies.single['id'], 4);
    expect(adapter.bodies.single['status'], 'Disable');
  });

  test('clam config file load and save use name and content', () async {
    final toolbox = ToolboxApi(client);
    adapter.responseData = 'scan /home';
    final content = await toolbox.loadClamFile('scan-home');
    expect(adapter.bodies.single['name'], 'scan-home');
    expect(content, 'scan /home');

    adapter.responseData = <String, dynamic>{};
    await toolbox.updateClamFile(name: 'scan-home', file: 'scan /srv');
    expect(adapter.paths.last, '/api/v2/toolbox/clam/file/update');
    expect(adapter.bodies.last['file'], 'scan /srv');
  });

  test('FTP operate and sync send expected payloads', () async {
    final toolbox = ToolboxApi(client);
    adapter.responseData = <String, dynamic>{};
    await toolbox.operateFtp('restart');
    expect(adapter.paths.last, '/api/v2/toolbox/ftp/operate');
    expect(adapter.bodies.last['operation'], 'restart');

    await toolbox.syncFtp();
    expect(adapter.paths.last, '/api/v2/toolbox/ftp/sync');
    expect(adapter.bodies.last['ids'], isEmpty);
  });

  test('FTP account update sends id, path and status', () async {
    final toolbox = ToolboxApi(client);
    adapter.responseData = <String, dynamic>{};
    await toolbox.updateFtp({
      'id': 9,
      'password': '',
      'path': '/srv/ftp',
      'status': 'Disable',
    });
    final body = adapter.bodies.single;
    expect(body['id'], 9);
    expect(body['path'], '/srv/ftp');
    expect(body['status'], 'Disable');
  });

  test('FTP log search sends paging and filters', () async {
    final toolbox = ToolboxApi(client);
    adapter.responseData = <String, dynamic>{
      'items': [
        {'user': 'ftp1', 'operation': 'upload', 'path': '/a.txt'},
      ],
      'total': 1,
    };
    final data = await toolbox.searchFtpLogs(
      page: 2,
      pageSize: 20,
      user: 'ftp1',
      operation: 'upload',
    );
    final body = adapter.bodies.single;
    expect(body['page'], 2);
    expect(body['pageSize'], 20);
    expect(body['user'], 'ftp1');
    expect(body['operation'], 'upload');
    expect((data['items'] as List).length, 1);
  });

  test('fail2ban config file load and update use file content', () async {
    final toolbox = ToolboxApi(client);
    adapter.responseData = '[sshd]\nenabled = true';
    final content = await toolbox.loadFail2banConf();
    expect(adapter.paths.single, '/api/v2/toolbox/fail2ban/load/conf');
    expect(content, contains('sshd'));

    adapter.responseData = <String, dynamic>{};
    await toolbox.updateFail2banByFile('[sshd]\nenabled = false');
    expect(adapter.paths.last, '/api/v2/toolbox/fail2ban/update/byconf');
    expect(adapter.bodies.last['file'], contains('enabled = false'));
  });

  test('panel upgrade info and releases parse lists', () async {
    final settings = SettingApi(client);
    adapter.responseData = <String, dynamic>{
      'latestVersion': '2.0.0',
      'newVersion': '2.1.0',
      'testVersion': '2.2.0-beta',
    };
    final info = await settings.getUpgradeInfo();
    expect(adapter.paths.last, '/api/v2/core/settings/upgrade');
    expect(info['newVersion'], '2.1.0');

    adapter.responseData = <Map<String, dynamic>>[
      {'version': '2.1.0', 'newCount': 3, 'fixCount': 2},
    ];
    final releases = await settings.getUpgradeReleases();
    expect(releases.single['version'], '2.1.0');
  });

  test('panel upgrade notes and upgrade send version', () async {
    final settings = SettingApi(client);
    adapter.responseData = 'notes';
    final notes = await settings.getUpgradeNotes('2.1.0');
    expect(adapter.bodies.last['version'], '2.1.0');
    expect(notes, 'notes');

    adapter.responseData = <String, dynamic>{};
    await settings.upgradePanel('2.1.0');
    expect(adapter.paths.last, '/api/v2/core/settings/upgrade');
    expect(adapter.bodies.last['version'], '2.1.0');
  });

  test('ssh connection checks post to the info endpoint', () async {
    adapter.responseData = true;
    final reachable = await SettingApi(
      client,
    ).checkLocalSshConn({'addr': '1.2.3.4'});
    expect(adapter.paths.last, '/api/v2/settings/ssh/check/info');
    expect(reachable, isTrue);
  });

  test('ssh log request serializes local times as UTC', () {
    final json = SshLogSearchReq(
      page: 1,
      pageSize: 10,
      startTime: DateTime(2026, 1, 1, 8),
      endTime: DateTime(2026, 1, 2, 8),
    ).toJson();
    expect(json['startTime'], endsWith('Z'));
    expect(json['endTime'], endsWith('Z'));
  });

  test('host monitor serializes local times as UTC', () async {
    await HostApi(client).searchMonitor(
      startTime: DateTime(2026, 1, 1, 8),
      endTime: DateTime(2026, 1, 2, 8),
    );
    expect(adapter.bodies.last['startTime'], endsWith('Z'));
    expect(adapter.bodies.last['endTime'], endsWith('Z'));
  });

  test('ftp update base64 encodes the password', () async {
    await ToolboxApi(client).updateFtp({
      'id': 1,
      'password': 'secret',
      'path': '/',
      'status': 'Enable',
    });
    expect(
      adapter.bodies.last['password'],
      base64Encode(utf8.encode('secret')),
    );
  });

  test('public backup accounts use core routes', () async {
    final backups = BackupApi(client);
    adapter.responseData = <String, dynamic>{};
    await backups.createBackupAccount({'name': 's3', 'isPublic': true});
    expect(adapter.paths.last, '/api/v2/core/backups');

    await backups.updateBackupAccount({'name': 's3', 'isPublic': true});
    expect(adapter.paths.last, '/api/v2/core/backups/update');

    await backups.deleteBackupAccount(id: 0, name: 's3', isPublic: true);
    expect(adapter.paths.last, '/api/v2/core/backups/del');
    expect(adapter.bodies.last['name'], 's3');

    await backups.refreshToken(id: 0, name: 's3', isPublic: true);
    expect(adapter.paths.last, '/api/v2/core/backups/refresh/token');
    expect(adapter.bodies.last['name'], 's3');
  });

  test('local backup accounts keep agent routes', () async {
    final backups = BackupApi(client);
    adapter.responseData = <String, dynamic>{};
    await backups.createBackupAccount({'name': 'local', 'isPublic': false});
    expect(adapter.paths.last, '/api/v2/backups');

    await backups.deleteBackupAccount(id: 7, name: 'local', isPublic: false);
    expect(adapter.paths.last, '/api/v2/backups/del');
    expect(adapter.bodies.last['id'], 7);

    await backups.refreshToken(id: 7, name: 'local', isPublic: false);
    expect(adapter.paths.last, '/api/v2/backups/refresh/token');
    expect(adapter.bodies.last['id'], 7);
  });

  test('new AI routes cover GPU groups and agent configuration', () async {
    final api = AiApi(client);
    adapter.responseData = <Object>[];
    await api.listGpuGroups();
    adapter.responseData = <String, dynamic>{};
    await api.saveGpuGroup({'name': 'gpu-a', 'imageType': 'nvidia'});
    await api.deleteGpuGroup(7);
    await api.loadModelGpuUsage({'dockerCompose': 'services: {}'});
    adapter.responseData = <Object>[
      {'name': 'AGENTS.md', 'content': '# Agent'},
    ];
    await api.listAgentRoleMarkdownFiles(agentId: 3, workspace: '/w');
    adapter.responseData = <String, dynamic>{};
    await api.updateAgentRoleMarkdownFile(
      agentId: 3,
      workspace: '/w',
      name: 'AGENTS.md',
      content: '# Agent',
      restart: true,
    );
    adapter.responseData = <Object>[];
    await api.batchInstallAgentSkill({'agentType': 'openclaw'});
    adapter.responseData = <String, dynamic>{};
    await api.switchAgentFeishuPlugin({'agentId': 3});
    await api.getAgentOtherConfig(3);
    await api.updateAgentOtherConfig({'agentId': 3});
    adapter.responseData = <Object>[];
    await api.checkAgentDelete(3);
    expect(adapter.paths, [
      '/api/v2/ai/gpu/groups',
      '/api/v2/ai/gpu/groups/save',
      '/api/v2/ai/gpu/groups/del',
      '/api/v2/ai/model/gpu/usage',
      '/api/v2/ai/agents/agent/md/list',
      '/api/v2/ai/agents/agent/md/update',
      '/api/v2/ai/agents/batch/skill/install',
      '/api/v2/ai/agents/channel/feishu/switch',
      '/api/v2/ai/agents/other/get',
      '/api/v2/ai/agents/other/update',
      '/api/v2/ai/agents/delete/check',
    ]);
    expect(adapter.bodies[2], {'id': 7});
    expect(adapter.bodies[5]['files'][0]['name'], 'AGENTS.md');
    expect(adapter.bodies[5]['restart'], isTrue);
  });

  test('new database routes use description, users and mongo fields', () async {
    final api = DatabaseApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.updateUser(
      database: 'db',
      username: 'u',
      host: '%',
      newHost: 'localhost',
      description: 'note',
    );
    await api.saveUserPassword(
      database: 'db',
      username: 'u',
      host: '%',
      password: 'secret',
    );
    adapter.responseData = <String, dynamic>{};
    await api.getGrantsSummary(database: 'db', dbs: ['app']);
    await api.updateDescription(id: 3, type: 'mysql', description: 'note');
    await api.updateDescription(id: 3, type: 'postgresql', description: 'note');
    await api.updateDescription(id: 3, type: 'mongodb', description: 'note');
    await api.getCommonInfo(name: 'db', type: 'mysql');
    await api.loadMongoFromRemote(database: 'mongo', from: 'remote');
    await api.changeMongoRootPassword(
      id: 3,
      database: 'mongo',
      password: 'secret',
    );
    expect(adapter.paths, [
      '/api/v2/databases/users/update',
      '/api/v2/databases/users/password/save',
      '/api/v2/databases/grants/summary',
      '/api/v2/databases/description/update',
      '/api/v2/databases/pg/description',
      '/api/v2/databases/mongodb/description',
      '/api/v2/databases/common/info',
      '/api/v2/databases/mongodb/load',
      '/api/v2/databases/mongodb/root/password',
    ]);
    expect(adapter.bodies[0]['newHost'], 'localhost');
    expect(adapter.bodies[1]['password'], base64Encode(utf8.encode('secret')));
    expect(adapter.bodies[2]['dbs'], ['app']);
    expect(adapter.bodies[8]['value'], base64Encode(utf8.encode('secret')));
  });

  test('runtime PHP configuration and container routes use fields', () async {
    final api = RuntimeApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.getPhpConfig(4);
    await api.updatePhpConfig(
      id: 4,
      scope: 'disable_functions',
      disableFunctions: ['exec'],
    );
    await api.getPhpContainer(4);
    await api.updatePhpContainer({
      'id': 4,
      'containerName': 'php',
      'exposedPorts': <Object>[],
      'environments': <Object>[],
      'volumes': <Object>[],
      'extraHosts': <Object>[],
    });
    expect(adapter.paths, [
      '/api/v2/runtimes/php/config/4',
      '/api/v2/runtimes/php/config',
      '/api/v2/runtimes/php/container/4',
      '/api/v2/runtimes/php/container/update',
    ]);
    expect(adapter.bodies[1]['scope'], 'disable_functions');
    expect(adapter.bodies[1]['disableFunctions'], ['exec']);
    expect(adapter.bodies[2], isEmpty);
    expect(adapter.bodies[3]['containerName'], 'php');
  });

  test('VM resize, health and orphan routes use fields', () async {
    final api = VmApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.resizeDisk(name: 'vm1', target: 'vda', sizeGiB: 40);
    await api.healthCheck('vm1');
    adapter.responseData = <Object>[];
    await api.scanOrphans();
    adapter.responseData = <Object>[
      {'type': 'partial_file', 'path': '/tmp/a'},
    ];
    await api.cleanOrphans([
      {'type': 'partial_file', 'path': '/tmp/a'},
    ]);
    expect(adapter.paths, [
      '/api/v2/vms/disks/resize',
      '/api/v2/vms/health/check',
      '/api/v2/vms/orphans/scan',
      '/api/v2/vms/orphans/clean',
    ]);
    expect(adapter.bodies[0], {
      'name': 'vm1',
      'target': 'vda',
      'sizeGiB': 40,
      'taskID': '',
    });
    expect(adapter.bodies[3]['items'][0]['path'], '/tmp/a');
  });

  test('file task stop routes use taskID', () async {
    final api = FileApi(client);
    await api.stopCompress('task-1');
    await api.stopDecompress('task-2');
    await api.stopMove('task-3');
    expect(adapter.paths, [
      '/api/v2/files/compress/stop',
      '/api/v2/files/decompress/stop',
      '/api/v2/files/move/stop',
    ]);
    expect(adapter.bodies.map((body) => body['taskID']), [
      'task-1',
      'task-2',
      'task-3',
    ]);
  });

  test('PHP extension presets, supervisor and remark routes', () async {
    final api = RuntimeApi(client);
    adapter.responseData = <String, dynamic>{'id': 1};
    await api.getPhpExtensionPreset(1);
    adapter.responseData = <String, dynamic>{};
    await api.createPhpExtensionPreset(name: 'preset', extensions: 'a,b');
    await api.updatePhpExtensionPreset(id: 1, extensions: 'a,b,c');
    await api.deletePhpExtensionPreset(1);
    adapter.responseData = 'created';
    final status = await api.importPhpExtensionPreset(
      name: 'preset',
      extensions: 'a,b',
    );
    adapter.responseData = <String, dynamic>{};
    await api.pushPhpExtensionPreset(
      id: 1,
      sourceNode: 'local',
      targetNodes: ['node-1'],
      taskID: 'task-1',
    );
    await api.updateRuntimeRemark(1, 'note');
    adapter.responseData = <Object>[];
    await api.getSupervisorProcesses(1);
    adapter.responseData = <String, dynamic>{};
    await api.operateSupervisorProcess(1, {
      'name': 'worker',
      'operate': 'start',
    });
    adapter.responseData = 'content';
    final content = await api.supervisorProcessFile(
      id: 1,
      name: 'worker',
      operate: 'get',
      file: 'config',
    );
    expect(status, 'created');
    expect(content, 'content');
    expect(adapter.paths, [
      '/api/v2/runtimes/php/extensions/detail',
      '/api/v2/runtimes/php/extensions',
      '/api/v2/runtimes/php/extensions/update',
      '/api/v2/runtimes/php/extensions/del',
      '/api/v2/runtimes/php/extensions/import',
      '/api/v2/runtimes/php/extensions/push',
      '/api/v2/runtimes/remark',
      '/api/v2/runtimes/supervisor/process/1',
      '/api/v2/runtimes/supervisor/process',
      '/api/v2/runtimes/supervisor/process/file',
    ]);
    expect(adapter.bodies[5]['targetNodes'], ['node-1']);
    expect(adapter.bodies[8]['name'], 'worker');
  });

  test('VM ISO search/import and network interface routes', () async {
    final api = VmApi(client);
    adapter.responseData = <String, dynamic>{'total': 0, 'items': <Object>[]};
    await api.searchIsos(info: 'ubuntu', type: 'iso');
    adapter.responseData = <String, dynamic>{'id': 7};
    final id = await api.startIsoImport({
      'type': 'iso',
      'name': 'ubuntu',
      'path': '/iso/ubuntu.iso',
      'status': 'uploading',
    });
    adapter.responseData = <String, dynamic>{};
    await api.updateIsoImport({'id': 7, 'status': 'ready'});
    adapter.responseData = <Object>[];
    await api.listNetworkInterfaces();
    expect(id, 7);
    expect(adapter.paths, [
      '/api/v2/vms/iso/search',
      '/api/v2/vms/iso/import/start',
      '/api/v2/vms/iso/import/update',
      '/api/v2/vms/networks/interfaces',
    ]);
    expect(adapter.bodies[0]['info'], 'ubuntu');
    expect(adapter.bodies[1]['status'], 'uploading');
    expect(adapter.bodies[2]['id'], 7);
  });

  test('app sort and default config routes', () async {
    final api = AppApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.updateInstalledSort([
      {'installID': 1, 'sortOrder': 2},
    ]);
    adapter.responseData = 'services: {}';
    final config = await api.getDefaultConfig(key: 'nginx', name: 'nginx');
    expect(config, 'services: {}');
    expect(adapter.paths, [
      '/api/v2/apps/installed/sort/update',
      '/api/v2/apps/installed/conf',
    ]);
    expect(adapter.bodies[0]['items'][0]['sortOrder'], 2);
    expect(adapter.bodies[1]['type'], 'nginx');
  });

  test('database redis check and website log search routes', () async {
    final db = DatabaseApi(client);
    adapter.responseData = true;
    final installed = await db.checkRedisCli();
    expect(installed, isTrue);
    expect(adapter.paths.single, '/api/v2/databases/redis/check');

    adapter.paths.clear();
    adapter.bodies.clear();
    final websites = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{
      'content': 'line1\nline2',
      'end': true,
      'path': '/var/log/access.log',
    };
    final log = await websites.searchWebsiteLog(3, type: WebsiteLogType.access);
    expect(log.lines, ['line1', 'line2']);
    expect(adapter.paths.single, '/api/v2/websites/log/search');
    expect(adapter.bodies.single['logType'], 'access.log');
  });

  test('cronjob script library options route', () async {
    final cronjobs = CronjobApi(client);
    adapter.responseData = <Object>[
      {'id': 1, 'name': 'backup.sh'},
    ];
    final options = await cronjobs.loadScriptOptions();
    expect(options.single.name, 'backup.sh');
    expect(adapter.paths, ['/api/v2/cronjobs/script/options']);
  });

  test('cronjob import/export and runtime delete check routes', () async {
    final cronjobs = CronjobApi(client);
    adapter.responseData = <int>[123, 125, 93, 10, 34, 125];
    final exported = await cronjobs.exportCronjobs([1, 2]);
    adapter.responseData = <String, dynamic>{};
    await cronjobs.importCronjobs([
      {'name': 'job', 'type': 'shell'},
    ]);
    expect(exported, contains('123'));
    expect(adapter.paths, [
      '/api/v2/cronjobs/export',
      '/api/v2/cronjobs/import',
    ]);
    expect(adapter.bodies[0]['ids'], [1, 2]);
    expect(adapter.bodies[1]['cronjobs'][0]['name'], 'job');

    adapter.paths.clear();
    adapter.bodies.clear();
    final runtime = RuntimeApi(client);
    adapter.responseData = <Object>[];
    await runtime.checkRuntimeDelete(5);
    expect(adapter.paths.single, '/api/v2/runtimes/installed/delete/check/5');
  });

  test('website stream update uses websiteID and servers', () async {
    final api = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.updateStreamConfig(
      websiteId: 3,
      streamPorts: '8080',
      name: 'tunnel',
      algorithm: 'roundrobin',
      udp: false,
      servers: [
        {'server': '127.0.0.1:80'},
      ],
    );
    expect(adapter.paths, ['/api/v2/websites/stream/update']);
    expect(adapter.bodies.single['websiteID'], 3);
    expect(adapter.bodies.single['streamPorts'], '8080');
  });

  test('website CA import and upload routes', () async {
    final api = WebsiteApi(client);
    adapter.responseData = <String, dynamic>{};
    await api.importCa(
      name: 'ca',
      type: 'paste',
      certificate: 'cert',
      privateKey: 'key',
    );
    await api.uploadCa(fileName: 'ca.zip', bytes: Uint8List.fromList([1, 2]));
    expect(adapter.paths, [
      '/api/v2/websites/ca/import',
      '/api/v2/websites/ca/upload',
    ]);
    expect(adapter.bodies[0]['name'], 'ca');
    expect(adapter.bodies[0]['type'], 'paste');
  });

  test('AI account counts and panel proxy update routes', () async {
    final ai = AiApi(client);
    adapter.responseData = <String, dynamic>{'openai': 2, 'ollama': 1};
    final counts = await ai.countAccountsByProviders(['openai', 'ollama']);
    expect(counts['openai'], 2);
    expect(adapter.paths.single, '/api/v2/ai/accounts/counts');
    expect(adapter.bodies.single['providers'], ['openai', 'ollama']);

    adapter.paths.clear();
    adapter.bodies.clear();
    final setting = SettingApi(client);
    adapter.responseData = <String, dynamic>{};
    await setting.updatePanelProxy(
      proxyUrl: 'proxy.example.com',
      proxyType: 'https',
      proxyPort: '8080',
      proxyUser: 'user',
      proxyPasswd: 'secret',
      proxyDocker: true,
    );
    expect(adapter.paths.single, '/api/v2/core/settings/proxy/update');
    expect(adapter.bodies.single['proxyUrl'], 'proxy.example.com');
    expect(adapter.bodies.single['proxyDocker'], isTrue);
    expect(
      adapter.bodies.single['proxyPasswd'],
      base64Encode(utf8.encode('secret')),
    );
  });

  test('panel file download preference and SSL certificate routes', () async {
    final setting = SettingApi(client);
    adapter.responseData = <String, dynamic>{'useServerFilename': true};
    final preference = await setting.getFileDownloadPreference();
    expect(preference, isTrue);
    adapter.responseData = <String, dynamic>{};
    await setting.updateFileDownloadPreference(useServerFilename: false);
    adapter.responseData = <int>[45, 45, 45];
    final bytes = await setting.downloadPanelSsl();
    expect(bytes, isNotEmpty);
    expect(adapter.paths, [
      '/api/v2/core/settings/file/download',
      '/api/v2/core/settings/file/download',
      '/api/v2/core/settings/ssl/download',
    ]);
    expect(adapter.bodies[1]['useServerFilename'], isFalse);
  });

  test('terminal appearance routes use fields', () async {
    final setting = SettingApi(client);
    adapter.responseData = <String, dynamic>{
      'fontSize': '14',
      'cursorStyle': 'bar',
    };
    final data = await setting.getTerminalAppearanceSettings();
    expect(data['fontSize'], '14');
    adapter.responseData = <String, dynamic>{};
    await setting.updateTerminalAppearanceSettings({
      'fontSize': '16',
      'cursorBlink': 'Disable',
    });
    expect(adapter.paths, [
      '/api/v2/core/settings/terminal/search',
      '/api/v2/core/settings/terminal/update',
    ]);
    expect(adapter.bodies.last['fontSize'], '16');
    expect(adapter.bodies.last['cursorBlink'], 'Disable');
  });

  test('toolbox device, clean and clam routes use fields', () async {
    final api = ToolboxApi(client);
    adapter.responseData = <String, dynamic>{'data': '127.0.0.1 localhost'};
    await api.loadDeviceConf('Hosts');
    adapter.responseData = <String, dynamic>{};
    await api.updateDeviceByFile(name: 'Hosts', file: 'file');
    await api.updateDeviceHosts([
      {'ip': '127.0.0.1', 'host': 'local'},
    ]);
    await api.updateDevicePassword(user: 'root', password: 'secret');
    adapter.responseData = true;
    final dns = await api.checkDns(value: '8.8.8.8');
    adapter.responseData = <String, dynamic>{};
    await api.cleanSystem([
      {'treeType': 'system', 'name': 'a', 'size': 1},
    ]);
    await api.deleteClam(ids: [1], removeInfected: true);
    await api.cleanClamRecords(2);
    expect(dns, isTrue);
    expect(adapter.paths, [
      '/api/v2/toolbox/device/conf',
      '/api/v2/toolbox/device/update/byconf',
      '/api/v2/toolbox/device/update/host',
      '/api/v2/toolbox/device/update/passwd',
      '/api/v2/toolbox/device/check/dns',
      '/api/v2/toolbox/clean',
      '/api/v2/toolbox/clam/del',
      '/api/v2/toolbox/clam/record/clean',
    ]);
    expect(adapter.bodies[3]['passwd'], base64Encode(utf8.encode('secret')));
    expect(adapter.bodies[6]['removeInfected'], isTrue);
  });

  test('container volume create sends driver options and labels', () async {
    final api = ContainerApi(client);
    adapter.responseData = null;
    await api.createVolume(
      name: 'app_data',
      driver: 'local',
      options: const ['type=tmpfs'],
      labels: const ['env=test'],
    );
    expect(adapter.paths.single, '/api/v2/containers/volume');
    expect(adapter.methods.single, 'POST');
    expect(adapter.bodies.single, {
      'name': 'app_data',
      'driver': 'local',
      'options': ['type=tmpfs'],
      'labels': ['env=test'],
    });
  });

  test('panel menu update sends HideMenu payload', () async {
    final api = SettingApi(client);
    adapter.responseData = null;
    await api.updateMenuSetting('[{"id":"Home-Menu","isShow":true}]');
    expect(adapter.paths.single, '/api/v2/core/settings/menu/update');
    expect(adapter.bodies.single['key'], 'HideMenu');
    expect(
      adapter.bodies.single['value'],
      '[{"id":"Home-Menu","isShow":true}]',
    );
  });

  test('command csv upload posts the file field', () async {
    final api = SettingApi(client);
    adapter.responseData = <Map<String, dynamic>>[
      {'name': 'uptime', 'command': 'uptime'},
    ];
    final items = await api.uploadCommandCsv(
      bytes: Uint8List.fromList([117, 112]),
      filename: 'commands.csv',
    );
    expect(items.single['name'], 'uptime');
    expect(adapter.paths.single, '/api/v2/core/commands/upload');
    expect(adapter.methods.single, 'POST');
  });

  test('master SSL import uses the websites SSL import route', () async {
    final api = WebsiteApi(client);
    adapter.responseData = null;
    await api.importMasterSsl({
      'primaryDomain': 'example.com',
      'pem': 'cert',
      'privateKey': 'key',
      'type': 'upload',
      'keyType': 'EC256',
    });
    expect(adapter.paths.single, '/api/v2/websites/ssl/import');
    expect(adapter.bodies.single['primaryDomain'], 'example.com');
    expect(adapter.bodies.single['pem'], 'cert');
  });

  test('backup client info uses the client type path', () async {
    final api = BackupApi(client);
    adapter.responseData = <String, dynamic>{
      'client_id': 'client',
      'client_secret': 'secret',
      'redirect_uri': 'https://example.com/callback',
    };
    final info = await api.getClientInfo('Onedrive');
    expect(adapter.paths.single, '/api/v2/core/backups/client/Onedrive');
    expect(info['client_id'], 'client');
  });

  test('passkey login begin and finish use session header', () async {
    final api = SettingApi(client);
    adapter.responseData = <String, dynamic>{
      'sessionId': 'passkey-session',
      'publicKey': {'challenge': 'abc', 'rpId': 'panel.example.com'},
    };
    final challenge = await api.passkeyBeginLogin();
    expect(adapter.paths.single, '/api/v2/core/auth/passkey/begin');
    expect(adapter.methods.single, 'POST');
    expect(challenge.sessionId, 'passkey-session');
    expect(challenge.publicKey['challenge'], 'abc');

    adapter.responseData = <String, dynamic>{};
    await api.passkeyFinishLogin(
      payload: {'id': 'credential', 'type': 'public-key'},
      sessionId: 'passkey-session',
    );
    expect(adapter.paths.last, '/api/v2/core/auth/passkey/finish');
    expect(adapter.requests.last.headers['Passkey-Session'], 'passkey-session');
    expect(adapter.bodies.last['id'], 'credential');

    await api.passkeyBeginLogin(entrance: 'secret');
    expect(
      adapter.requests.last.headers['EntranceCode'],
      base64Encode(utf8.encode('secret')),
    );
  });

  test('passkey register begin and finish use the session header', () async {
    final api = SettingApi(client);
    adapter.responseData = <String, dynamic>{
      'sessionId': 'register-session',
      'publicKey': {'challenge': 'def'},
    };
    final challenge = await api.passkeyBeginRegister('Pixel');
    expect(adapter.paths.single, '/api/v2/core/auth/passkey/register/begin');
    expect(adapter.bodies.single, {'name': 'Pixel'});
    expect(challenge.sessionId, 'register-session');

    adapter.responseData = null;
    await api.passkeyFinishRegister(
      payload: {'id': 'credential', 'type': 'public-key'},
      sessionId: 'register-session',
    );
    expect(adapter.paths.last, '/api/v2/core/auth/passkey/register/finish');
    expect(
      adapter.requests.last.headers['Passkey-Session'],
      'register-session',
    );
    expect(adapter.bodies.last['id'], 'credential');
  });

  test('VM bridge list uses the host bridge endpoint', () async {
    adapter.responseData = <Map<String, dynamic>>[
      {'name': 'br0', 'recommended': true},
    ];
    final bridges = await VmApi(client).listNetworkBridges();
    expect(adapter.paths.single, '/api/v2/vms/networks/bridges');
    expect(adapter.methods.single, 'GET');
    expect(bridges.single['name'], 'br0');
  });
  test('compose env accepts a plain text response', () async {
    adapter.responseData = 'FOO=bar\nBAZ=qux';
    final env = await ContainerApi(client).loadComposeEnv('/tmp/demo');
    expect(env, 'FOO=bar\nBAZ=qux');
    expect(adapter.paths.single, '/api/v2/containers/compose/env');
  });

  test('firewall restore uses the rule create endpoint', () async {
    adapter.responseData = <String, dynamic>{'taskID': '', 'queued': false};
    await FirewallApi(client).restoreRules('rules-20260101.json');
    expect(adapter.paths.single, '/api/v2/hosts/firewall/rules');
    expect(adapter.bodies.single['backupFile'], 'rules-20260101.json');
    expect(adapter.bodies.single['initialize'], false);
  });

  test('MFA login forwards the security entrance header', () async {
    adapter.responseData = <String, dynamic>{};
    await SettingApi(
      client,
    ).loginPanelMfa(sessionId: 'mfa', code: '123456', entrance: 'secret');
    expect(adapter.paths.single, '/api/v2/core/auth/mfalogin');
    expect(
      adapter.requests.single.headers['EntranceCode'],
      base64Encode(utf8.encode('secret')),
    );
  });

  test('proxy password keep uses the Enable/Disable enum', () async {
    await SettingApi(client).updatePanelProxy(
      proxyUrl: 'proxy.example.com',
      proxyType: 'http',
      proxyPort: '8080',
      proxyPasswdKeep: true,
    );
    expect(adapter.bodies.single['proxyPasswdKeep'], 'Enable');
  });

  test('VM console initialization uses the console endpoint', () async {
    adapter.responseData = <String, dynamic>{'type': 'vnc', 'port': '5900'};
    await VmApi(client).getVmConsole('demo');
    expect(adapter.paths.single, '/api/v2/vms/console');
    expect(adapter.bodies.single['name'], 'demo');
  });

  test('disabling default documents uses the delete operation', () async {
    await WebsiteApi(client).updateWebsiteIndexConfig(3, const []);
    expect(adapter.paths.single, '/api/v2/websites/config/update');
    expect(adapter.bodies.single['operate'], 'delete');
    expect(adapter.bodies.single['params'], isEmpty);
  });

  test('container limits keep CPU cores and memory MB', () {
    final info = ContainerInfoDto.fromJson({
      'taskID': 'task',
      'name': 'demo',
      'image': 'nginx',
      'nanoCPUs': 0.5,
      'memory': 512,
    });
    expect(info.nanoCPUs, 0.5);
    expect(info.memory, 512);
    expect(info.toJson()['nanoCPUs'], 0.5);
    expect(info.toJson()['memory'], 512);
  });

  test('alert config updates keep revision and display name', () {
    const request = AlertConfigUpdateReq(
      id: 7,
      type: 'custom',
      displayName: 'Hook',
      revision: '2026-01-01T00:00:00Z',
    );
    final json = request.toJson();
    expect(json['displayName'], 'Hook');
    expect(json['revision'], '2026-01-01T00:00:00Z');
    final parsed = AlertConfigInfo.fromJson({
      'id': 7,
      'type': 'custom',
      'displayName': 'Hook',
      'revision': '2026-01-01T00:00:00Z',
    });
    expect(parsed.displayName, 'Hook');
    expect(parsed.revision, '2026-01-01T00:00:00Z');
  });

  test('cronjob URL items preserve per-URL headers', () {
    const request = CronjobCreateReq(
      name: 'curl',
      type: 'curl',
      spec: '30 1 * * *',
      url: 'https://a.example,https://b.example',
      urlItems: [
        CronjobUrlItemDto(url: 'https://a.example', header: 'agent-a'),
        CronjobUrlItemDto(url: 'https://b.example', header: 'agent-b'),
      ],
    );
    final json = request.toJson();
    expect(json['urlItems'], [
      {'url': 'https://a.example', 'header': 'agent-a'},
      {'url': 'https://b.example', 'header': 'agent-b'},
    ]);
  });
  test('container update returns the task id for polling', () async {
    final taskID = await ContainerApi(
      client,
    ).updateContainer({'taskID': 'update-task', 'name': 'demo'});
    expect(taskID, 'update-task');
    expect(adapter.paths.single, '/api/v2/containers/update');
  });

  test('dashboard launcher status uses Enable/Disable', () async {
    await DashboardApi(client).updateAppLauncherShow(key: 'app', show: true);
    expect(adapter.bodies.single['value'], 'Enable');
  });

  test('docker guard bind accepts a null data payload', () async {
    adapter.responseData = null;
    await FirewallApi(client).operateDockerGuard('bind');
    expect(adapter.paths.single, '/api/v2/hosts/firewall/docker/operate');
  });

  test('custom alert test accepts a result object', () async {
    adapter.responseData = <String, dynamic>{'success': true};
    final ok = await AlertApi(client).testAlertConfig(
      const AlertConfigTestReq(
        id: 7,
        type: 'custom',
        config: '{"url":"https://example.com"}',
      ),
    );
    expect(ok, isTrue);
    expect(adapter.bodies.single['id'], 7);
    expect(adapter.bodies.single['type'], 'custom');
  });
}
