import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client_provider.dart';
import '../../domain/repositories/container_repository.dart';
import '../../presentation/features/server_detail/providers/active_server_provider.dart';
import '../api/container_api.dart';
import '../api/file_api.dart';
import '../api/setting_api.dart';
import '../dto/container/docker_status_dto.dart';
import '../dto/container/container_limit_dto.dart';
import '../dto/container/container_status_dto.dart';
import '../dto/container/container_item_stats_dto.dart';
import '../dto/container/container_daemon_config_dto.dart';
import '../dto/container/container_search_dto.dart';
import '../dto/container/container_resource_stats_dto.dart';
import '../dto/container/container_stats_dto.dart';
import '../dto/container/container_by_image_dto.dart';
import '../dto/container/container_info_dto.dart';
import '../dto/container/container_option_dto.dart';
import '../dto/container/container_compose_dto.dart';
import '../dto/container/compose_template_dto.dart';
import '../dto/common/task_log_dto.dart';
import '../dto/container/image_dtos.dart';
import '../dto/container/network_dtos.dart';
import '../dto/common/page_result.dart';

part 'container_repository_impl.g.dart';

/// [ContainerRepository] 的默认实现。
class ContainerRepositoryImpl implements ContainerRepository {
  ContainerRepositoryImpl(this._containerApi, this._fileApi, this._settingApi);

  final ContainerApi _containerApi;
  final FileApi _fileApi;
  final SettingApi _settingApi;

  @override
  Future<DockerStatusDto> getDockerStatus() => _containerApi.getDockerStatus();

  @override
  Future<String> getComposeLog({
    required String composePath,
    required String since,
    required String tail,
    required bool follow,
    required bool timestamp,
  }) => _containerApi.getComposeLog(
    composePath: composePath,
    since: since,
    tail: tail,
    follow: follow,
    timestamp: timestamp,
  );

  @override
  Future<String> getContainerLog({
    required String containerName,
    required String since,
    required String tail,
    required bool follow,
    required bool timestamp,
  }) => _containerApi.getContainerLog(
    containerName: containerName,
    since: since,
    tail: tail,
    follow: follow,
    timestamp: timestamp,
  );

  @override
  Future<void> cleanComposeLog({
    required String name,
    required String composePath,
  }) => _containerApi.cleanComposeLog(name: name, composePath: composePath);

  @override
  Future<void> cleanContainerLog({required String containerName}) =>
      _containerApi.cleanContainerLog(containerName: containerName);

  @override
  Future<ContainerLimitDto> getContainerLimit() =>
      _containerApi.getContainerLimit();

  @override
  Future<ContainerStatusDto> getStatus() => _containerApi.getStatus();

  @override
  Future<ContainerItemStatsDto> getItemStats() => _containerApi.getItemStats();

  @override
  Future<List<String>> loadContainerUsers(String containerName) =>
      _containerApi.loadContainerUsers(containerName);

  @override
  Future<ContainerDaemonConfigDto> getDaemonConfig() =>
      _containerApi.getDaemonConfig();

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
  }) => _containerApi.searchContainers(
    state: state,
    page: page,
    pageSize: pageSize,
    filters: filters,
    orderBy: orderBy,
    order: order,
    excludeAppStore: excludeAppStore,
    name: name,
  );

  @override
  Future<List<ContainerResourceStatsDto>> getContainerResourceStats() =>
      _containerApi.getContainerResourceStats();

  @override
  Future<ContainerStatsDto> getContainerStats(String containerId) =>
      _containerApi.getContainerStats(containerId);

  @override
  Future<List<ContainerByImageDto>> getContainersByImage(String imageName) =>
      _containerApi.getContainersByImage(imageName);

  @override
  Future<void> upgradeContainer({
    required String taskID,
    required List<String> names,
    required String image,
    required bool forcePull,
  }) => _containerApi.upgradeContainer(
    taskID: taskID,
    names: names,
    image: image,
    forcePull: forcePull,
  );

  @override
  Future<TaskLogDto> readTaskLog(String taskID) => _fileApi.readFile(
    id: 0,
    type: 'task',
    name: '',
    taskID: taskID,
    fromJson: TaskLogDto.fromJson,
  );

  @override
  Future<void> commitContainer({
    required String containerID,
    required String containerName,
    required String newImageName,
    required String comment,
    required String author,
    required bool pause,
    required String taskID,
  }) => _containerApi.commitContainer(
    containerID: containerID,
    containerName: containerName,
    newImageName: newImageName,
    comment: comment,
    author: author,
    pause: pause,
    taskID: taskID,
  );

  @override
  Future<ContainerInfoDto> getContainerInfo(String name) =>
      _containerApi.getContainerInfo(name);

  @override
  Future<List<ContainerOptionDto>> getNetworks() => _containerApi.getNetworks();

  @override
  Future<NetworkSearchDto> searchNetworks({
    String info = '',
    int page = 1,
    int pageSize = 20,
  }) =>
      _containerApi.searchNetworks(info: info, page: page, pageSize: pageSize);

  @override
  Future<void> createNetwork(NetworkCreateReq req) =>
      _containerApi.createNetwork(req);

  @override
  Future<void> deleteNetworks(List<String> names) =>
      _containerApi.deleteNetworks(names);

  @override
  Future<List<ContainerOptionDto>> getVolumes() => _containerApi.getVolumes();

  @override
  Future<List<ContainerOptionDto>> getImages() => _containerApi.getImages();

  @override
  Future<String> createContainer(Map<String, dynamic> data) =>
      _containerApi.createContainer(data);

  @override
  Future<void> waitForTask(
    String taskID, {
    void Function(TaskLogDto log)? onUpdate,
  }) => _containerApi.waitForTask(taskID, onUpdate: onUpdate);

  @override
  Future<void> updateContainer(Map<String, dynamic> data) =>
      _containerApi.updateContainer(data);

  @override
  Future<void> operateContainer({
    required List<String> names,
    required String operation,
    required String taskID,
  }) => _containerApi.operateContainer(
    names: names,
    operation: operation,
    taskID: taskID,
  );

  @override
  Future<void> pruneContainers({
    required String taskID,
    String pruneType = 'container',
    bool withTagAll = false,
  }) => _containerApi.pruneContainers(
    taskID: taskID,
    pruneType: pruneType,
    withTagAll: withTagAll,
  );

  @override
  Future<void> saveDescription({
    required String id,
    required String type,
    String detailType = '',
    required bool isPinned,
    required String description,
  }) => _settingApi.saveDescription(
    id: id,
    type: type,
    detailType: detailType,
    isPinned: isPinned,
    description: description,
  );

  @override
  Future<ContainerComposeSearchDto> searchCompose({
    String info = '',
    int page = 1,
    int pageSize = 100,
  }) => _containerApi.searchCompose(info: info, page: page, pageSize: pageSize);

  @override
  Future<void> operateCompose({
    required String name,
    required String path,
    required String operation,
    bool withFile = false,
    bool force = false,
  }) => _containerApi.operateCompose(
    name: name,
    path: path,
    operation: operation,
    withFile: withFile,
    force: force,
  );

  @override
  Future<String> inspect({
    required String id,
    required String type,
    required String detail,
  }) => _containerApi.inspect(id: id, type: type, detail: detail);

  @override
  Future<String> updateCompose(Map<String, dynamic> data) =>
      _containerApi.updateCompose(data);

  @override
  Future<bool> testCompose(Map<String, dynamic> data) =>
      _containerApi.testCompose(data);

  @override
  Future<String> createCompose(Map<String, dynamic> data) =>
      _containerApi.createCompose(data);

  // ==========================================
  // Image API
  // ==========================================

  @override
  Future<List<DockerImageInfo>> getAllImages() => _containerApi.getAllImages();

  @override
  Future<PageResult<DockerImageInfo>> searchImages(PageImageReq req) =>
      _containerApi.searchImages(req);

  @override
  Future<void> buildImage(ImageBuildReq req) => _containerApi.buildImage(req);

  @override
  Future<void> pullImage(ImagePullReq req) => _containerApi.pullImage(req);

  @override
  Future<void> pushImage(ImagePushReq req) => _containerApi.pushImage(req);

  @override
  Future<void> removeImage(BatchDeleteReq req) =>
      _containerApi.removeImage(req);

  @override
  Future<void> saveImage(ImageSaveReq req) => _containerApi.saveImage(req);

  @override
  Future<void> tagImage(ImageTagReq req) => _containerApi.tagImage(req);

  @override
  Future<void> loadImage(ImageLoadReq req) => _containerApi.loadImage(req);

  @override
  Future<List<ImageRepoDto>> listImageRepos() => _containerApi.listImageRepos();

  @override
  Future<ImageRepoSearchDto> searchImageRepos({
    String info = '',
    int page = 1,
    int pageSize = 20,
  }) => _containerApi.searchImageRepos(
    info: info,
    page: page,
    pageSize: pageSize,
  );

  @override
  Future<void> createImageRepo({
    required String name,
    required String downloadUrl,
    required String protocol,
    bool auth = false,
    String username = '',
    String password = '',
  }) => _containerApi.createImageRepo(
    name: name,
    downloadUrl: downloadUrl,
    protocol: protocol,
    auth: auth,
    username: username,
    password: password,
  );

  @override
  Future<void> updateImageRepo({
    required int id,
    required String downloadUrl,
    required String protocol,
    bool auth = false,
    String username = '',
    String password = '',
  }) => _containerApi.updateImageRepo(
    id: id,
    downloadUrl: downloadUrl,
    protocol: protocol,
    auth: auth,
    username: username,
    password: password,
  );

  @override
  Future<void> deleteImageRepo(int id) => _containerApi.deleteImageRepo(id);

  @override
  Future<void> syncImageRepo(int id) => _containerApi.syncImageRepo(id);

  // ==========================================
  // Compose Template API
  // ==========================================

  @override
  Future<ComposeTemplateSearchDto> searchTemplates({
    String info = '',
    int page = 1,
    int pageSize = 20,
  }) =>
      _containerApi.searchTemplates(info: info, page: page, pageSize: pageSize);

  @override
  Future<void> createTemplate({
    required String name,
    String description = '',
    required String content,
  }) => _containerApi.createTemplate(
    name: name,
    description: description,
    content: content,
  );

  @override
  Future<void> updateTemplate({
    required int id,
    String description = '',
    required String content,
  }) => _containerApi.updateTemplate(
    id: id,
    description: description,
    content: content,
  );

  @override
  Future<void> deleteTemplates(List<int> ids) =>
      _containerApi.deleteTemplates(ids);

  @override
  Future<void> batchImportTemplates(List<Map<String, dynamic>> templates) =>
      _containerApi.batchImportTemplates(templates);

  @override
  Future<void> dockerOperate(String operation) =>
      _containerApi.dockerOperate(operation);

  @override
  Future<void> updateDaemonByKey(String key, String value) =>
      _containerApi.updateDaemonByKey(key, value);

  @override
  Future<void> updateIpv6Option({
    required String fixedCidrV6,
    required bool ip6Tables,
    required bool experimental,
  }) => _containerApi.updateIpv6Option(
    fixedCidrV6: fixedCidrV6,
    ip6Tables: ip6Tables,
    experimental: experimental,
  );

  @override
  Future<void> updateLogOption({
    required String logMaxSize,
    required String logMaxFile,
  }) => _containerApi.updateLogOption(
    logMaxSize: logMaxSize,
    logMaxFile: logMaxFile,
  );

  @override
  Future<String> getDaemonJsonFile() => _containerApi.getDaemonJsonFile();

  @override
  Future<void> updateDaemonJsonByFile(String file) =>
      _containerApi.updateDaemonJsonByFile(file);
}

/// 基于当前激活服务器的容器仓库 Provider。
@Riverpod()
Future<ContainerRepository> containerRepository(Ref ref) async {
  final serverId = ref.watch(activeServerIdProvider);
  final client = await ref.watch(dioClientProvider(serverId).future);
  return ContainerRepositoryImpl(
    ContainerApi(client),
    FileApi(client),
    SettingApi(client),
  );
}
