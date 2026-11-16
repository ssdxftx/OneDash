import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/toolbox_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/toolbox_api.dart';

class ToolboxRepositoryImpl implements ToolboxRepository {
  ToolboxRepositoryImpl(this._api);

  final ToolboxApi _api;

  @override
  Future<Map<String, dynamic>> getDeviceBase() => _api.getDeviceBase();

  @override
  Future<String> loadDeviceConf(String name) => _api.loadDeviceConf(name);

  @override
  Future<void> updateDeviceByFile({
    required String name,
    required String file,
  }) => _api.updateDeviceByFile(name: name, file: file);

  @override
  Future<void> updateDeviceHosts(List<Map<String, String>> hosts) =>
      _api.updateDeviceHosts(hosts);

  @override
  Future<void> updateDevicePassword({
    required String user,
    required String password,
  }) => _api.updateDevicePassword(user: user, password: password);

  @override
  Future<bool> checkDns({String key = 'form', required String value}) =>
      _api.checkDns(key: key, value: value);

  @override
  Future<void> cleanSystem(List<Map<String, dynamic>> items) =>
      _api.cleanSystem(items);

  @override
  Future<void> deleteClam({
    required List<int> ids,
    bool removeInfected = false,
  }) => _api.deleteClam(ids: ids, removeInfected: removeInfected);

  @override
  Future<void> cleanClamRecords(int id) => _api.cleanClamRecords(id);

  @override
  Future<Map<String, dynamic>> getFail2banBase() => _api.getFail2banBase();

  @override
  Future<Map<String, dynamic>> getFtpBase() => _api.getFtpBase();

  @override
  Future<Map<String, dynamic>> getClamBase() => _api.getClamBase();

  @override
  Future<Map<String, dynamic>> scanClean() => _api.scanClean();

  @override
  Future<List<String>> loadUsers() => _api.loadUsers();

  @override
  Future<List<String>> getZoneOptions() => _api.getZoneOptions();

  @override
  Future<void> updateDeviceConf(String key, String value) =>
      _api.updateDeviceConf(key, value);

  @override
  Future<void> updateSwap({
    required String path,
    required int size,
    bool isNew = true,
  }) => _api.updateSwap(path: path, size: size, isNew: isNew);

  @override
  Future<List<String>> searchFail2ban(String status) =>
      _api.searchFail2ban(status);

  @override
  Future<void> operateFail2ban(String operation) =>
      _api.operateFail2ban(operation);

  @override
  Future<void> operateFail2banSshd(List<String> ips, String operate) =>
      _api.operateFail2banSshd(ips, operate);

  @override
  Future<void> updateFail2banConf(String key, String value) =>
      _api.updateFail2banConf(key, value);

  @override
  Future<String> loadFail2banConf() => _api.loadFail2banConf();

  @override
  Future<void> updateFail2banByFile(String file) =>
      _api.updateFail2banByFile(file);

  @override
  Future<List<Map<String, dynamic>>> searchFtp({
    int page = 1,
    int pageSize = 100,
  }) => _api.searchFtp(page: page, pageSize: pageSize);

  @override
  Future<void> createFtp({
    required String user,
    required String password,
    required String path,
    String description = '',
  }) => _api.createFtp(
    user: user,
    password: password,
    path: path,
    description: description,
  );

  @override
  Future<void> deleteFtp(List<int> ids) => _api.deleteFtp(ids);

  @override
  Future<void> operateFtp(String operation) => _api.operateFtp(operation);

  @override
  Future<void> syncFtp() => _api.syncFtp();

  @override
  Future<void> updateFtp(Map<String, dynamic> data) => _api.updateFtp(data);

  @override
  Future<Map<String, dynamic>> searchFtpLogs({
    int page = 1,
    int pageSize = 50,
    String user = '',
    String operation = '',
  }) => _api.searchFtpLogs(
    page: page,
    pageSize: pageSize,
    user: user,
    operation: operation,
  );

  @override
  Future<List<Map<String, dynamic>>> searchClam({
    int page = 1,
    int pageSize = 100,
  }) => _api.searchClam(page: page, pageSize: pageSize);

  @override
  Future<void> createClam({
    required String name,
    required String path,
    String infectedStrategy = 'none',
    String infectedDir = '',
  }) => _api.createClam(
    name: name,
    path: path,
    infectedStrategy: infectedStrategy,
    infectedDir: infectedDir,
  );

  @override
  Future<void> operateClam(String operation) => _api.operateClam(operation);

  @override
  Future<void> handleClam(int id) => _api.handleClam(id);

  @override
  Future<void> updateClam(Map<String, dynamic> data) => _api.updateClam(data);

  @override
  Future<void> updateClamStatus(int id, String status) =>
      _api.updateClamStatus(id, status);

  @override
  Future<String> loadClamFile(String name, {String tail = ''}) =>
      _api.loadClamFile(name, tail: tail);

  @override
  Future<void> updateClamFile({required String name, required String file}) =>
      _api.updateClamFile(name: name, file: file);

  @override
  Future<List<Map<String, dynamic>>> searchClamRecords({
    required int clamId,
    int page = 1,
    int pageSize = 50,
  }) => _api.searchClamRecords(clamId: clamId, page: page, pageSize: pageSize);
}

final toolboxRepositoryProvider = FutureProvider<ToolboxRepository>((
  ref,
) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return ToolboxRepositoryImpl(ToolboxApi(client));
}, dependencies: [activeServerIdProvider]);
