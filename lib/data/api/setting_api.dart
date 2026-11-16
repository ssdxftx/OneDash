import 'dart:typed_data';

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/network/api_compatibility.dart';
import '../../core/network/api_response_parser.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/panel_password_encrypter.dart';
import '../../core/network/panel_session.dart';
import '../dto/common/page_result.dart';
import '../dto/setting/api_key_dto.dart';
import '../dto/setting/group_dto.dart';
import '../dto/setting/command_library_dto.dart';
import '../dto/setting/script_library_dto.dart';

/// 设置相关 API。
class SettingApi {
  SettingApi(this._client);

  final DioClient _client;
  String? _panelPublicKey;

  /// 获取登录页配置（是否启用 MFA、是否需要验证码等）。
  Future<Map<String, dynamic>> getLoginSetting() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/core/auth/setting',
      options: Options(extra: const {'skipAuth': true, 'skipSession': true}),
    );
    _capturePublicKey(resp);
    return ApiResponseParser.map(resp);
  }

  /// 获取登录验证码（data URI 图片）。
  Future<Map<String, dynamic>> loadLoginCaptcha() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/core/auth/captcha',
      options: Options(extra: const {'skipAuth': true, 'skipSession': true}),
    );
    return ApiResponseParser.map(resp);
  }

  /// 登录面板并保存会话。
  Future<PanelLoginResult> loginPanel({
    required String name,
    required String password,
    required String language,
    String captcha = '',
    String captchaId = '',
    String entrance = '',
  }) async {
    await _loadPanelPublicKey();
    final headers = <String, dynamic>{
      if (entrance.isNotEmpty)
        'EntranceCode': base64Encode(utf8.encode(entrance)),
    };
    final publicKey = _panelPublicKey;
    final passwordValue = publicKey == null
        ? password
        : PanelPasswordEncrypter.encrypt(password, publicKey);
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/auth/login',
      data: {
        'name': name,
        'password': passwordValue,
        'captcha': captcha,
        'captchaID': captchaId,
        'language': language,
      },
      options: Options(
        headers: headers,
        extra: const {'skipAuth': true, 'skipSession': true},
      ),
    );
    final data = ApiResponseParser.map(resp);
    final session = _sessionFromResponse(resp);
    final result = PanelLoginResult(
      session: session,
      mfaStatus: data['mfaStatus']?.toString() ?? '',
      mfaSession: data['mfaSession']?.toString() ?? '',
    );
    _client.updateSession(result.needsMfa ? null : session);
    return result;
  }

  /// 完成 MFA 二次登录并保存会话。
  Future<PanelLoginResult> loginPanelMfa({
    required String sessionId,
    required String code,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/auth/mfalogin',
      data: {'sessionId': sessionId, 'code': code},
      options: Options(extra: const {'skipAuth': true, 'skipSession': true}),
    );
    final data = ApiResponseParser.map(resp);
    final session = _sessionFromResponse(resp);
    final result = PanelLoginResult(
      session: session,
      mfaStatus: data['mfaStatus']?.toString() ?? '',
      mfaSession: data['mfaSession']?.toString() ?? '',
    );
    _client.updateSession(result.needsMfa ? null : session);
    return result;
  }

  /// 注销面板会话。
  Future<void> logoutPanel() async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/core/auth/logout',
      data: const {},
    );
    _client.updateSession(null);
  }

  Future<void> _loadPanelPublicKey() async {
    if (_panelPublicKey != null) return;
    await getLoginSetting();
  }

  void _capturePublicKey(Response<dynamic> response) {
    final raw = _cookieValue(response, 'panel_public_key');
    if (raw == null || raw.isEmpty) return;
    var value = Uri.decodeComponent(raw.replaceAll('+', ' '));
    value = value.replaceAll('"', '');
    try {
      _panelPublicKey = utf8.decode(base64Decode(value));
    } catch (_) {
      _panelPublicKey = value;
    }
  }

  String? _cookieValue(Response<dynamic> response, String name) {
    final cookies = response.headers.map['set-cookie'] ?? const <String>[];
    for (final header in cookies) {
      for (final part in header.split(';')) {
        final index = part.indexOf('=');
        if (index <= 0) continue;
        if (part.substring(0, index).trim() == name) {
          return part.substring(index + 1).trim();
        }
      }
    }
    return null;
  }

  PanelSession? _sessionFromResponse(Response<dynamic> response) {
    final cookies = response.headers.map['set-cookie'] ?? const <String>[];
    String sessionId = '';
    String csrfToken = '';
    for (final header in cookies) {
      for (final part in header.split(';')) {
        final index = part.indexOf('=');
        if (index <= 0) continue;
        final key = part.substring(0, index).trim();
        final value = part.substring(index + 1).trim();
        if (key == 'psession') sessionId = value;
        if (key == 'pcsrftoken') csrfToken = value;
      }
    }
    if (sessionId.isEmpty) return null;
    return PanelSession(sessionId: sessionId, csrfToken: csrfToken);
  }

  /// 获取当前用户文件下载偏好。
  /// GET /api/v2/core/settings/file/download
  Future<bool> getFileDownloadPreference() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/core/settings/file/download',
    );
    final data = resp.data?['data'];
    return data is Map && data['useServerFilename'] == true;
  }

  /// 更新当前用户文件下载偏好。
  /// POST /api/v2/core/settings/file/download
  Future<void> updateFileDownloadPreference({
    required bool useServerFilename,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/core/settings/file/download',
      data: {'useServerFilename': useServerFilename},
    );
  }

  /// 下载面板 SSL 证书。
  /// POST /api/v2/core/settings/ssl/download
  Future<Uint8List> downloadPanelSsl() async {
    final resp = await _client.post<List<int>>(
      '/api/v2/core/settings/ssl/download',
      data: const {},
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(resp.data ?? const []);
  }

  /// 获取面板安装根目录。
  /// GET /api/v2/settings/basedir
  Future<String> getBaseDir() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/settings/basedir',
    );
    return ApiResponseParser.primitive<String>(resp);
  }

  /// 更新系统设置。
  /// POST /api/v2/settings/update
  Future<void> updateSetting({
    required String key,
    required String value,
  }) async {
    await _client.post(
      '/api/v2/settings/update',
      data: {'key': key, 'value': value},
    );
  }

  /// POST /api/v2/core/settings/terminal/search
  Future<Map<String, dynamic>> getTerminalAppearanceSettings() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/settings/terminal/search',
      data: {},
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/core/settings/terminal/update
  Future<void> updateTerminalAppearanceSettings(
    Map<String, String> data,
  ) async {
    await _client.post('/api/v2/core/settings/terminal/update', data: data);
  }

  /// POST /api/v2/settings/terminal/ai/search
  Future<Map<String, dynamic>> getTerminalAiSetting() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/settings/terminal/ai/search',
      data: {},
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/settings/terminal/ai/update
  Future<void> updateTerminalAiSetting({
    required String aiStatus,
    required String aiPrefix,
    String aiAccountId = '',
    String aiRiskCommands = '',
  }) async {
    await _client.post(
      '/api/v2/settings/terminal/ai/update',
      data: {
        'aiStatus': aiStatus,
        'aiPrefix': aiPrefix,
        'aiAccountId': aiAccountId,
        'aiRiskCommands': aiRiskCommands,
      },
    );
  }

  /// POST /api/v2/settings/files/ai/search
  Future<Map<String, dynamic>> getFileAiSetting() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/settings/files/ai/search',
      data: {},
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/settings/files/ai/update
  Future<void> updateFileAiSetting({
    required String aiStatus,
    String aiAccountId = '',
  }) async {
    await _client.post(
      '/api/v2/settings/files/ai/update',
      data: {'aiStatus': aiStatus, 'aiAccountId': aiAccountId},
    );
  }

  /// POST /api/v2/settings/file-history/search
  Future<Map<String, dynamic>> getFileHistorySetting() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/settings/file-history/search',
      data: {},
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/settings/file-history/update
  Future<void> updateFileHistorySetting({
    required String enable,
    required int maxPerPath,
    required int diskQuotaMB,
  }) async {
    await _client.post(
      '/api/v2/settings/file-history/update',
      data: {
        'enable': enable,
        'maxPerPath': maxPerPath,
        'diskQuotaMB': diskQuotaMB,
      },
    );
  }

  /// GET /api/v2/core/settings/upgrade
  Future<Map<String, dynamic>> getUpgradeInfo() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/core/settings/upgrade',
    );
    return ApiResponseParser.map(resp);
  }

  /// GET /api/v2/core/settings/upgrade/releases
  Future<List<Map<String, dynamic>>> getUpgradeReleases() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/core/settings/upgrade/releases',
    );
    final data = resp.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false);
  }

  /// POST /api/v2/core/settings/upgrade/notes
  Future<String> getUpgradeNotes(String version) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/settings/upgrade/notes',
      data: {'version': version},
    );
    return ApiResponseParser.primitive<String>(resp);
  }

  /// POST /api/v2/core/settings/upgrade
  Future<void> upgradePanel(String version) async {
    await _client.post(
      '/api/v2/core/settings/upgrade',
      data: {'version': version},
    );
  }

  /// GET /api/v2/settings/ssh/conn
  Future<Map<String, dynamic>> getLocalSshConn() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/settings/ssh/conn',
    );
    return ApiResponseParser.map(resp);
  }

  /// POST /api/v2/settings/ssh
  Future<void> saveLocalSshConn(Map<String, dynamic> data) async {
    await _client.post('/api/v2/settings/ssh', data: data);
  }

  /// POST /api/v2/settings/ssh/check/info
  Future<bool> checkLocalSshConn(Map<String, dynamic> data) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/settings/ssh/check/info',
      data: data,
    );
    return ApiResponseParser.primitive<bool>(resp);
  }

  /// POST /api/v2/settings/ssh/default
  Future<void> setSshDefaultConn({
    required String defaultConn,
    bool withReset = false,
  }) async {
    await _client.post(
      '/api/v2/settings/ssh/default',
      data: {'defaultConn': defaultConn, 'withReset': withReset},
    );
  }

  /// POST /api/v2/core/settings/menu/default
  Future<void> resetMenuSetting() async {
    await _client.post('/api/v2/core/settings/menu/default', data: {});
  }

  /// 保存描述与置顶状态。
  /// POST /api/v2/settings/description/save
  Future<void> saveDescription({
    required String id,
    required String type,
    String detailType = '',
    required bool isPinned,
    required String description,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/settings/description/save',
      data: {
        'id': id,
        'type': type,
        'detailType': detailType,
        'isPinned': isPinned,
        'description': description,
      },
    );
    ApiResponseParser.ok(resp);
  }

  /// 搜索系统设置。
  /// POST /api/v2/settings/search
  Future<Map<String, dynamic>> searchSettings() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/settings/search',
      data: {},
    );
    return resp.data?['data'] as Map<String, dynamic>? ?? {};
  }

  /// 获取系统 IP 地址（宿主机地址）。
  ///
  /// 从系统设置中提取 `systemIP` 字段。
  Future<String> getSystemIP() async {
    final settings = await searchSettings();
    return (settings['systemIP'] as String?) ?? '';
  }

  /// 搜索 Core 侧面板配置（用户名、主题、语言、会话超时等）。
  /// POST /api/v2/core/settings/search
  Future<Map<String, dynamic>> searchCoreSettings() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/settings/search',
      data: {},
    );
    final raw = resp.data?['data'];
    final settings = raw is Map<String, dynamic>
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    try {
      final current = await loadCurrentUser();
      for (final key in const [
        'apiInterfaceStatus',
        'apiKey',
        'ipWhiteList',
        'apiKeyValidityTime',
      ]) {
        if (current.containsKey(key)) settings[key] = current[key];
      }
      final currentName = current['name']?.toString();
      if ((settings['userName']?.toString().isEmpty ?? true) &&
          currentName != null &&
          currentName.isNotEmpty) {
        settings['userName'] = currentName;
      }
    } catch (_) {
      // Older 1Panel versions do not expose /core/auth/current.
    }

    return settings;
  }

  /// 更新 Core 侧面板配置。
  /// POST /api/v2/core/settings/update
  Future<void> updateCoreSetting({
    required String key,
    required String value,
  }) async {
    await _client.post(
      '/api/v2/core/settings/update',
      data: {'key': key, 'value': value},
    );
  }

  /// 更新面板服务器代理。
  /// POST /api/v2/core/settings/proxy/update
  Future<void> updatePanelProxy({
    required String proxyUrl,
    required String proxyType,
    required String proxyPort,
    String proxyUser = '',
    String proxyPasswd = '',
    bool proxyPasswdKeep = false,
    bool proxyDocker = false,
    bool withDockerRestart = false,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v2/core/settings/proxy/update',
      data: {
        'proxyUrl': proxyUrl,
        'proxyType': proxyType,
        'proxyPort': proxyPort,
        'proxyUser': proxyUser,
        'proxyPasswd': proxyPasswd.isEmpty
            ? ''
            : base64Encode(utf8.encode(proxyPasswd)),
        'proxyPasswdKeep': proxyPasswdKeep ? 'true' : 'false',
        'proxyDocker': proxyDocker,
        'withDockerRestart': withDockerRestart,
      },
    );
  }

  /// 获取 Core 侧备忘录。
  /// GET /api/v2/core/settings/memo
  Future<String> getMemo() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/core/settings/memo',
    );
    return ApiResponseParser.primitive<String>(resp);
  }

  /// 保存 Core 侧备忘录。
  /// POST /api/v2/core/settings/memo
  Future<void> saveMemo(String content) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/settings/memo',
      data: {'content': content},
    );
    ApiResponseParser.ok(resp);
  }

  /// 更新面板登录密码。
  /// POST /api/v2/core/settings/password/update
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await ApiCompatibility.tryVariants<void>(
      [
        ApiEndpointVariant(
          name: 'core.auth.current.updatePassword',
          call: () async {
            final user = await loadCurrentUser();
            final name = user['name']?.toString() ?? '';
            await _client.post(
              '/api/v2/core/auth/current/update',
              data: {
                'name': name,
                'oldPassword': base64Encode(utf8.encode(oldPassword)),
                'password': base64Encode(utf8.encode(newPassword)),
              },
            );
          },
        ),
        ApiEndpointVariant(
          name: 'core.settings.password.update',
          call: () async {
            await _client.post(
              '/api/v2/core/settings/password/update',
              data: {'oldPassword': oldPassword, 'newPassword': newPassword},
            );
          },
        ),
      ],
      cacheScope: _client,
      cacheKey: 'core.password.update',
    );
  }

  Future<Map<String, dynamic>> loadCurrentUser() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/core/auth/current',
    );
    return ApiResponseParser.map(resp);
  }

  // ── 安全设置 ──

  /// 更新面板端口。
  /// POST /api/v2/core/settings/port/update
  Future<void> updatePort(int serverPort) async {
    await _client.post(
      '/api/v2/core/settings/port/update',
      data: {'serverPort': serverPort},
    );
  }

  /// 获取网络接口地址列表。
  /// GET /api/v2/core/settings/interface
  Future<List<String>> loadInterfaceAddr() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/core/settings/interface',
    );
    final data = resp.data?['data'];
    if (data is List) return data.whereType<String>().toList();
    return [];
  }

  /// 更新绑定地址。
  /// POST /api/v2/core/settings/bind/update
  Future<void> updateBindInfo({
    required String ipv6,
    required String bindAddress,
  }) async {
    await _client.post(
      '/api/v2/core/settings/bind/update',
      data: {'ipv6': ipv6, 'bindAddress': bindAddress},
    );
  }

  /// 更新 SSL 配置。
  /// POST /api/v2/core/settings/ssl/update
  Future<void> updateSSL(Map<String, dynamic> data) async {
    await _client.post('/api/v2/core/settings/ssl/update', data: data);
  }

  /// 获取 SSL 信息。
  /// GET /api/v2/core/settings/ssl/info
  Future<Map<String, dynamic>> loadSSLInfo() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/core/settings/ssl/info',
    );
    return ApiResponseParser.map(resp);
  }

  /// 加载 MFA 信息。
  /// POST /api/v2/core/settings/mfa
  Future<Map<String, dynamic>> loadMFA({
    required String title,
    required int interval,
  }) async {
    final data = {'title': title, 'interval': interval};
    final resp = await ApiCompatibility.tryVariants(
      [
        ApiEndpointVariant(
          name: 'core.auth.mfa',
          call: () => _client.post<Map<String, dynamic>>(
            '/api/v2/core/auth/mfa',
            data: data,
          ),
        ),
        ApiEndpointVariant(
          name: 'core.settings.mfa',
          call: () => _client.post<Map<String, dynamic>>(
            '/api/v2/core/settings/mfa',
            data: data,
          ),
        ),
      ],
      cacheScope: _client,
      cacheKey: 'core.mfa.load',
    );
    return ApiResponseParser.map(resp);
  }

  /// 绑定 MFA。
  /// POST /api/v2/core/settings/mfa/bind
  Future<void> bindMFA({
    required String secret,
    required String code,
    required int interval,
  }) async {
    final data = {'secret': secret, 'code': code, 'interval': interval};
    await ApiCompatibility.tryVariants<void>(
      [
        ApiEndpointVariant(
          name: 'core.auth.mfa.bind',
          call: () async {
            await _client.post('/api/v2/core/auth/mfa/bind', data: data);
          },
        ),
        ApiEndpointVariant(
          name: 'core.settings.mfa.bind',
          call: () async {
            await _client.post('/api/v2/core/settings/mfa/bind', data: data);
          },
        ),
      ],
      cacheScope: _client,
      cacheKey: 'core.mfa.bind',
    );
  }

  /// 获取 Passkey 列表。
  /// POST /api/v2/core/auth/mfa/close
  Future<void> closeMFA() async {
    await _client.post('/api/v2/core/auth/mfa/close', data: const {});
  }

  /// POST /api/v2/core/auth/expired/reset
  Future<void> resetExpiredPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _client.post(
      '/api/v2/core/auth/expired/reset',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }

  /// POST /api/v2/core/groups/search
  Future<List<CoreGroupDto>> searchGroups({required String type}) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/groups/search',
      data: {'type': type},
    );
    return ApiResponseParser.list(resp, CoreGroupDto.fromJson);
  }

  /// POST /api/v2/core/groups
  Future<void> createGroup({required String name, required String type}) async {
    await _client.post(
      '/api/v2/core/groups',
      data: {'name': name, 'type': type},
    );
  }

  /// POST /api/v2/core/groups/update
  Future<void> updateGroup({
    required int id,
    required String name,
    required String type,
    bool isDefault = false,
  }) async {
    await _client.post(
      '/api/v2/core/groups/update',
      data: {'id': id, 'name': name, 'type': type, 'isDefault': isDefault},
    );
  }

  /// POST /api/v2/core/groups/del
  Future<void> deleteGroup(int id) async {
    await _client.post('/api/v2/core/groups/del', data: {'id': id});
  }

  /// POST /api/v2/core/commands/search
  Future<PageResult<CommandLibraryDto>> searchCommands({
    String type = 'command',
    String info = '',
    int page = 1,
    int pageSize = 50,
    int groupID = 0,
    String orderBy = 'createdAt',
    String order = 'descending',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/commands/search',
      data: {
        'type': type,
        'info': info,
        'page': page,
        'pageSize': pageSize,
        'groupID': groupID,
        'orderBy': orderBy,
        'order': order,
      },
    );
    return PageResult<CommandLibraryDto>.fromJson(
      ApiResponseParser.map(resp),
      CommandLibraryDto.fromJson,
    );
  }

  /// POST /api/v2/core/commands
  Future<void> createCommand(Map<String, dynamic> data) async {
    await _client.post('/api/v2/core/commands', data: data);
  }

  /// POST /api/v2/core/commands/update
  Future<void> updateCommand(Map<String, dynamic> data) async {
    await _client.post('/api/v2/core/commands/update', data: data);
  }

  /// POST /api/v2/core/commands/del
  Future<void> deleteCommands({
    required List<int> ids,
    String type = 'command',
  }) async {
    await _client.post(
      '/api/v2/core/commands/del',
      data: {'type': type, 'ids': ids},
    );
  }

  /// POST /api/v2/core/commands/tree
  Future<List<CommandTreeDto>> searchCommandTree({
    String type = 'command',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/commands/tree',
      data: {'type': type},
    );
    return ApiResponseParser.list(resp, CommandTreeDto.fromJson);
  }

  /// POST /api/v2/core/commands/import
  Future<void> importCommands(List<Map<String, dynamic>> items) async {
    await _client.post('/api/v2/core/commands/import', data: {'items': items});
  }

  /// POST /api/v2/core/commands/export
  Future<String> exportCommands() async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/commands/export',
      data: const {},
    );
    return ApiResponseParser.primitive<String>(resp);
  }

  /// POST /api/v2/core/script/search
  Future<PageResult<ScriptLibraryDto>> searchScripts({
    String info = '',
    int page = 1,
    int pageSize = 50,
    int groupID = 0,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/script/search',
      data: {
        'info': info,
        'page': page,
        'pageSize': pageSize,
        'groupID': groupID,
      },
    );
    return PageResult<ScriptLibraryDto>.fromJson(
      ApiResponseParser.map(resp),
      ScriptLibraryDto.fromJson,
    );
  }

  /// POST /api/v2/core/script
  Future<void> createScript(Map<String, dynamic> data) async {
    await _client.post('/api/v2/core/script', data: data);
  }

  /// POST /api/v2/core/script/update
  Future<void> updateScript(Map<String, dynamic> data) async {
    await _client.post('/api/v2/core/script/update', data: data);
  }

  /// POST /api/v2/core/script/del
  Future<void> deleteScripts(List<int> ids) async {
    await _client.post('/api/v2/core/script/del', data: {'ids': ids});
  }

  /// POST /api/v2/core/script/sync
  Future<void> syncScripts(String taskID) async {
    await _client.post('/api/v2/core/script/sync', data: {'taskID': taskID});
  }

  /// GET /api/v2/core/settings/passkey/list
  Future<List<Map<String, dynamic>>> listPasskeys() async {
    final resp = await ApiCompatibility.tryVariants(
      [
        ApiEndpointVariant(
          name: 'core.auth.passkey.list',
          call: () => _client.get<Map<String, dynamic>>(
            '/api/v2/core/auth/passkey/list',
          ),
        ),
        ApiEndpointVariant(
          name: 'core.settings.passkey.list',
          call: () => _client.get<Map<String, dynamic>>(
            '/api/v2/core/settings/passkey/list',
          ),
        ),
      ],
      cacheScope: _client,
      cacheKey: 'core.passkey.list',
    );
    final data = resp.data?['data'];
    if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    return [];
  }

  /// 删除 Passkey。
  /// DELETE /api/v2/core/settings/passkey/:id
  Future<void> deletePasskey(String id) async {
    await ApiCompatibility.tryVariants<void>(
      [
        ApiEndpointVariant(
          name: 'core.auth.passkey.del',
          call: () async {
            await _client.post(
              '/api/v2/core/auth/passkey/del',
              data: {'id': id},
            );
          },
        ),
        ApiEndpointVariant(
          name: 'core.settings.passkey.delete',
          call: () async {
            await _client.delete('/api/v2/core/settings/passkey/$id');
          },
        ),
      ],
      cacheScope: _client,
      cacheKey: 'core.passkey.delete',
    );
  }

  // ── API 接口配置 ──

  /// 生成 API 密钥。
  /// POST /api/v2/core/settings/api/config/generate/key
  Future<String> generateApiKey() async {
    final resp = await ApiCompatibility.tryVariants(
      [
        ApiEndpointVariant(
          name: 'core.auth.api.generate',
          call: () => _client.post<Map<String, dynamic>>(
            '/api/v2/core/auth/api/generate',
            data: {},
          ),
        ),
        ApiEndpointVariant(
          name: 'core.settings.api.config.generate.key',
          call: () => _client.post<Map<String, dynamic>>(
            '/api/v2/core/settings/api/config/generate/key',
            data: {},
          ),
        ),
      ],
      cacheScope: _client,
      cacheKey: 'core.api.generate',
    );
    return ApiResponseParser.primitive<String>(resp);
  }

  /// 更新 API 接口配置。
  /// POST /api/v2/core/settings/api/config/update
  Future<void> updateApiConfig(Map<String, dynamic> config) async {
    await ApiCompatibility.tryVariants<void>(
      [
        ApiEndpointVariant(
          name: 'core.auth.api.update',
          call: () async {
            await _client.post('/api/v2/core/auth/api/update', data: config);
          },
        ),
        ApiEndpointVariant(
          name: 'core.settings.api.config.update',
          call: () async {
            await _client.post(
              '/api/v2/core/settings/api/config/update',
              data: config,
            );
          },
        ),
      ],
      cacheScope: _client,
      cacheKey: 'core.api.update',
    );
  }

  // ── 独立 API Key ──

  /// POST /api/v2/core/auth/api/keys/search
  Future<PageResult<ApiKeyItemDto>> searchApiKeys({
    int page = 1,
    int pageSize = 20,
    bool excludeRevoked = false,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/auth/api/keys/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        'excludeRevoked': excludeRevoked,
      },
    );
    return PageResult<ApiKeyItemDto>.fromJson(
      ApiResponseParser.map(resp),
      ApiKeyItemDto.fromJson,
    );
  }

  /// POST /api/v2/core/auth/api/keys/create
  Future<ApiKeyCreatedDto> createApiKey({
    required String requestId,
    required String name,
    String description = '',
    String ipWhiteList = '',
    String apiTrustedProxies = '',
    int apiKeyValidityTime = 120,
    DateTime? expiresAt,
    bool allowAppBinding = false,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/auth/api/keys/create',
      data: {
        'requestID': requestId,
        'name': name,
        'description': description,
        'ipWhiteList': ipWhiteList,
        'apiTrustedProxies': apiTrustedProxies,
        'apiKeyValidityTime': apiKeyValidityTime,
        if (expiresAt != null) 'expiresAt': expiresAt.toUtc().toIso8601String(),
        'allowAppBinding': allowAppBinding,
      },
    );
    return ApiResponseParser.object(resp, ApiKeyCreatedDto.fromJson);
  }

  /// POST /api/v2/core/auth/api/keys/update
  Future<void> updateApiKey({
    required String id,
    required int revision,
    required String name,
    String description = '',
    String ipWhiteList = '',
    String apiTrustedProxies = '',
    int apiKeyValidityTime = 120,
    DateTime? expiresAt,
    bool allowAppBinding = false,
  }) async {
    await _client.post(
      '/api/v2/core/auth/api/keys/update',
      data: {
        'id': id,
        'revision': revision,
        'name': name,
        'description': description,
        'ipWhiteList': ipWhiteList,
        'apiTrustedProxies': apiTrustedProxies,
        'apiKeyValidityTime': apiKeyValidityTime,
        'expiresAt': expiresAt?.toUtc().toIso8601String(),
        'allowAppBinding': allowAppBinding,
      },
    );
  }

  /// POST /api/v2/core/auth/api/keys/status
  Future<void> setApiKeyStatus({
    required String id,
    required int revision,
    required String status,
  }) async {
    await _client.post(
      '/api/v2/core/auth/api/keys/status',
      data: {'id': id, 'revision': revision, 'status': status},
    );
  }

  /// POST /api/v2/core/auth/api/keys/revoke
  Future<void> revokeApiKey({required String id, required int revision}) async {
    await _client.post(
      '/api/v2/core/auth/api/keys/revoke',
      data: {'id': id, 'revision': revision},
    );
  }

  /// POST /api/v2/core/auth/api/keys/delete
  Future<void> deleteApiKey({required String id, required int revision}) async {
    await _client.post(
      '/api/v2/core/auth/api/keys/delete',
      data: {'id': id, 'revision': revision},
    );
  }

  /// POST /api/v2/core/auth/api/keys/reveal
  Future<String> revealApiKey({
    required String id,
    required int revision,
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/core/auth/api/keys/reveal',
      data: {'id': id, 'revision': revision},
    );
    return (ApiResponseParser.map(resp)['apiKey'] ?? '').toString();
  }

  // ── 快照 ──

  /// 创建快照。
  /// POST /api/v2/settings/snapshot
  Future<void> createSnapshot(Map<String, dynamic> data) async {
    await _client.post('/api/v2/settings/snapshot', data: data);
  }

  /// 导入/同步快照。
  /// POST /api/v2/settings/snapshot/import
  Future<void> importSnapshot(Map<String, dynamic> data) async {
    await _client.post('/api/v2/settings/snapshot/import', data: data);
  }

  /// 搜索快照列表。
  /// POST /api/v2/settings/snapshot/search
  Future<Map<String, dynamic>> searchSnapshots({
    required int page,
    required int pageSize,
    String info = '',
    String orderBy = 'createdAt',
    String order = 'null',
  }) async {
    final resp = await _client.post<Map<String, dynamic>>(
      '/api/v2/settings/snapshot/search',
      data: {
        'page': page,
        'pageSize': pageSize,
        'info': info,
        'orderBy': orderBy,
        'order': order,
      },
    );
    return ApiResponseParser.map(resp);
  }

  /// 加载快照树数据。
  /// GET /api/v2/settings/snapshot/load
  Future<Map<String, dynamic>> loadSnapshotData() async {
    final resp = await _client.get<Map<String, dynamic>>(
      '/api/v2/settings/snapshot/load',
    );
    return ApiResponseParser.map(resp);
  }

  /// 删除快照。
  /// POST /api/v2/settings/snapshot/del
  Future<void> deleteSnapshots({
    required List<int> ids,
    bool deleteWithFile = false,
  }) async {
    await _client.post(
      '/api/v2/settings/snapshot/del',
      data: {'ids': ids, 'deleteWithFile': deleteWithFile},
    );
  }

  /// 恢复快照。
  /// POST /api/v2/settings/snapshot/recover
  Future<void> recoverSnapshot({
    required int id,
    bool isNew = false,
    bool reDownload = false,
    String taskID = '',
    String secret = '',
  }) async {
    await _client.post(
      '/api/v2/settings/snapshot/recover',
      data: {
        'id': id,
        'isNew': isNew,
        'reDownload': reDownload,
        'taskID': taskID,
        'secret': secret,
      },
    );
  }

  /// 回滚快照。
  /// POST /api/v2/settings/snapshot/rollback
  Future<void> rollbackSnapshot({
    required int id,
    String taskID = '',
    String secret = '',
  }) async {
    await _client.post(
      '/api/v2/settings/snapshot/rollback',
      data: {'id': id, 'taskID': taskID, 'secret': secret},
    );
  }

  /// 重新创建快照。
  /// POST /api/v2/settings/snapshot/recreate
  Future<void> recreateSnapshot(int id) async {
    await _client.post('/api/v2/settings/snapshot/recreate', data: {'id': id});
  }

  /// 更新快照描述。
  /// POST /api/v2/settings/snapshot/description/update
  Future<void> updateSnapshotDescription(int id, String description) async {
    await _client.post(
      '/api/v2/settings/snapshot/description/update',
      data: {'id': id, 'description': description},
    );
  }
}
