import '../../data/dto/container/docker_status_dto.dart';
import '../../data/dto/container/container_limit_dto.dart';
import '../../data/dto/container/container_status_dto.dart';
import '../../data/dto/container/container_item_stats_dto.dart';
import '../../data/dto/container/container_daemon_config_dto.dart';
import '../../data/dto/container/container_search_dto.dart';
import '../../data/dto/container/container_resource_stats_dto.dart';
import '../../data/dto/container/container_stats_dto.dart';
import '../../data/dto/container/container_by_image_dto.dart';
import '../../data/dto/container/container_info_dto.dart';
import '../../data/dto/container/container_option_dto.dart';
import '../../data/dto/container/container_compose_dto.dart';
import '../../data/dto/container/compose_template_dto.dart';
import '../../data/dto/common/task_log_dto.dart';
import '../../data/dto/container/image_dtos.dart';
import '../../data/dto/container/network_dtos.dart';
import '../../data/dto/common/page_result.dart';

/// 容器管理数据仓库接口。
abstract interface class ContainerRepository {
  /// 查询 Docker 服务状态。
  Future<DockerStatusDto> getDockerStatus();

  /// 获取 Docker Compose 运行日志。
  Future<String> getComposeLog({
    required String composePath,
    required String since,
    required String tail,
    required bool follow,
    required bool timestamp,
  });

  /// 获取单个容器运行日志。
  Future<String> getContainerLog({
    required String containerName,
    required String since,
    required String tail,
    required bool follow,
    required bool timestamp,
  });

  /// 清空 Docker Compose 日志。
  Future<void> cleanComposeLog({
    required String name,
    required String composePath,
  });

  /// 清空单个容器日志。
  Future<void> cleanContainerLog({required String containerName});

  /// 获取容器资源限制信息。
  Future<ContainerLimitDto> getContainerLimit();

  /// 获取容器运行状态统计。
  Future<ContainerStatusDto> getStatus();

  /// 获取容器磁盘占用统计。
  Future<ContainerItemStatsDto> getItemStats();

  /// 获取 Docker daemon 配置。
  Future<ContainerDaemonConfigDto> getDaemonConfig();

  /// 搜索容器。
  Future<ContainerSearchDto> searchContainers({
    String state = 'all',
    int page = 1,
    int pageSize = 20,
    String filters = '',
    String orderBy = 'createdAt',
    String order = 'null',
    bool excludeAppStore = false,
    String name = '',
  });

  /// 获取容器资源统计列表。
  Future<List<ContainerResourceStatsDto>> getContainerResourceStats();

  /// 获取单个容器实时监控数据。
  Future<ContainerStatsDto> getContainerStats(String containerId);

  /// 根据镜像获取容器状态。
  Future<List<ContainerByImageDto>> getContainersByImage(String imageName);

  /// 升级容器。
  Future<void> upgradeContainer({
    required String taskID,
    required List<String> names,
    required String image,
    required bool forcePull,
  });

  /// 读取任务日志。
  Future<TaskLogDto> readTaskLog(String taskID);

  /// 制作容器镜像。
  Future<void> commitContainer({
    required String containerID,
    required String containerName,
    required String newImageName,
    required String comment,
    required String author,
    required bool pause,
    required String taskID,
  });

  /// 获取容器详细信息。
  Future<ContainerInfoDto> getContainerInfo(String name);

  /// 获取所有网络信息。
  Future<List<ContainerOptionDto>> getNetworks();

  /// 分页搜索网络。
  Future<NetworkSearchDto> searchNetworks({
    String info = '',
    int page = 1,
    int pageSize = 20,
  });

  /// 创建网络。
  Future<void> createNetwork(NetworkCreateReq req);

  /// 批量删除网络。
  Future<void> deleteNetworks(List<String> names);

  /// 获取所有挂载卷信息。
  Future<List<ContainerOptionDto>> getVolumes();

  /// 获取全部镜像信息。
  Future<List<ContainerOptionDto>> getImages();

  /// 更新容器。
  Future<void> updateContainer(Map<String, dynamic> data);

  /// 容器操作。
  Future<void> operateContainer({
    required List<String> names,
    required String operation,
    required String taskID,
  });

  /// 清理容器。
  Future<void> pruneContainers({
    required String taskID,
    String pruneType = 'container',
    bool withTagAll = false,
  });

  /// 保存描述与置顶状态。
  Future<void> saveDescription({
    required String id,
    required String type,
    String detailType = '',
    required bool isPinned,
    required String description,
  });

  /// 搜索编排 (Compose)。
  Future<ContainerComposeSearchDto> searchCompose({
    String info = '',
    int page = 1,
    int pageSize = 100,
  });

  /// 容器编排操作。
  Future<void> operateCompose({
    required String name,
    required String path,
    required String operation,
    bool withFile = false,
    bool force = false,
  });

  /// 检查容器/编排信息（获取 YAML 或配置）。
  Future<String> inspect({
    required String id,
    required String type,
    required String detail,
  });

  /// 更新编排。
  Future<String> updateCompose(Map<String, dynamic> data);

  /// 测试/校验编排。
  Future<bool> testCompose(Map<String, dynamic> data);

  /// 创建并启动编排。
  Future<String> createCompose(Map<String, dynamic> data);

  // ==========================================
  // Image API
  // ==========================================

  /// 获取所有镜像列表（不分页）。
  Future<List<DockerImageInfo>> getAllImages();

  /// 分页搜索镜像。
  Future<PageResult<DockerImageInfo>> searchImages(PageImageReq req);

  /// 构建镜像。
  Future<void> buildImage(ImageBuildReq req);

  /// 拉取镜像。
  Future<void> pullImage(ImagePullReq req);

  /// 推送镜像。
  Future<void> pushImage(ImagePushReq req);

  /// 删除镜像。
  Future<void> removeImage(BatchDeleteReq req);

  /// 导出镜像。
  Future<void> saveImage(ImageSaveReq req);

  /// 重设镜像标签。
  Future<void> tagImage(ImageTagReq req);

  /// 导入镜像。
  Future<void> loadImage(ImageLoadReq req);

  /// 获取镜像仓库列表。
  Future<List<ImageRepoDto>> listImageRepos();

  /// 分页搜索镜像仓库。
  Future<ImageRepoSearchDto> searchImageRepos({
    String info = '',
    int page = 1,
    int pageSize = 20,
  });

  /// 新增镜像仓库。
  Future<void> createImageRepo({
    required String name,
    required String downloadUrl,
    required String protocol,
    bool auth = false,
    String username = '',
    String password = '',
  });

  /// 编辑镜像仓库。
  Future<void> updateImageRepo({
    required int id,
    required String downloadUrl,
    required String protocol,
    bool auth = false,
    String username = '',
    String password = '',
  });

  /// 删除镜像仓库。
  Future<void> deleteImageRepo(int id);

  /// 同步/检测镜像仓库连接。
  Future<void> syncImageRepo(int id);

  // ==========================================
  // Compose Template API
  // ==========================================

  /// 搜索编排模板。
  Future<ComposeTemplateSearchDto> searchTemplates({
    String info = '',
    int page = 1,
    int pageSize = 20,
  });

  /// 创建编排模板。
  Future<void> createTemplate({
    required String name,
    String description = '',
    required String content,
  });

  /// 更新编排模板。
  Future<void> updateTemplate({
    required int id,
    String description = '',
    required String content,
  });

  /// 删除编排模板。
  Future<void> deleteTemplates(List<int> ids);

  /// 批量导入编排模板。
  Future<void> batchImportTemplates(List<Map<String, dynamic>> templates);

  /// Docker 服务操作（启动/停止/重启）。
  Future<void> dockerOperate(String operation);

  /// 按 key 更新 daemon.json 配置。
  Future<void> updateDaemonByKey(String key, String value);

  /// 更新 IPv6 选项。
  Future<void> updateIpv6Option({
    required String fixedCidrV6,
    required bool ip6Tables,
    required bool experimental,
  });

  /// 更新日志切割选项。
  Future<void> updateLogOption({
    required String logMaxSize,
    required String logMaxFile,
  });

  /// 读取 daemon.json 原始文本。
  Future<String> getDaemonJsonFile();

  /// 按文件更新 daemon.json。
  Future<void> updateDaemonJsonByFile(String file);
}
