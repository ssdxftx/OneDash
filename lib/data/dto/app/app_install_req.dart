class AppInstallReq {
  const AppInstallReq({
    required this.appDetailId,
    required this.params,
    required this.name,
    required this.version,
    required this.taskID,
    this.advanced = true,
    this.cpuQuota = 0,
    this.memoryLimit = 0,
    this.memoryUnit = 'M',
    this.containerName = '',
    this.allowPort = false,
    this.editCompose = false,
    this.dockerCompose = '',
    this.appID = '',
    this.pullImage = true,
    this.gpuConfig = false,
    this.specifyIP = '',
    this.restartPolicy = 'always',
    this.pushNode = false,
    this.nodes = const [],
  });

  final int appDetailId;
  final Map<String, dynamic> params;
  final String name;
  final String version;
  final String taskID;
  final bool advanced;
  final int cpuQuota;
  final int memoryLimit;
  final String memoryUnit;
  final String containerName;
  final bool allowPort;
  final bool editCompose;
  final String dockerCompose;
  final String appID;
  final bool pullImage;
  final bool gpuConfig;
  final String specifyIP;
  final String restartPolicy;
  final bool pushNode;
  final List<dynamic> nodes;

  Map<String, dynamic> toJson() {
    return {
      'appDetailId': appDetailId,
      'params': params,
      'name': name,
      'version': version,
      'taskID': taskID,
      'advanced': advanced,
      'cpuQuota': cpuQuota,
      'memoryLimit': memoryLimit,
      'memoryUnit': memoryUnit,
      'containerName': containerName,
      'allowPort': allowPort,
      'editCompose': editCompose,
      'dockerCompose': dockerCompose,
      'appID': appID,
      'pullImage': pullImage,
      'gpuConfig': gpuConfig,
      'specifyIP': specifyIP,
      'restartPolicy': restartPolicy,
      'pushNode': pushNode,
      'nodes': nodes,
    };
  }
}
