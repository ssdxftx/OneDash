import 'cronjob_form_data_dto.dart';

class CronjobDto {
  const CronjobDto({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.spec,
    required this.specCustom,
    required this.specs,
    required this.groupID,
    required this.retainCopies,
    required this.retryTimes,
    required this.timeout,
    required this.ignoreErr,
    required this.secret,
    required this.hasAlert,
    required this.alertCount,
    required this.alertTitle,
    required this.alertMethod,
    required this.lastRecordStatus,
    required this.lastRecordTime,
    required this.createdAt,
    required this.updatedAt,
    this.executor,
    this.scriptMode,
    this.script,
    this.command,
    this.containerName,
    this.user,
    this.scriptID,
    this.appID,
    this.website,
    this.exclusionRules,
    this.dbType,
    this.dbName,
    this.url,
    this.isDir,
    this.sourceDir,
    this.sourceAccountIDs,
    this.downloadAccountID,
    this.sourceAccounts,
    this.downloadAccount,
    this.args,
    this.scopes,
    this.snapshotRule,
  });

  final int id;
  final String name;
  final String type;
  final String status;
  final String spec;
  final bool specCustom;
  final List<String> specs;
  final int groupID;
  final int retainCopies;
  final int retryTimes;
  final int timeout;
  final bool ignoreErr;
  final String secret;
  final bool hasAlert;
  final int alertCount;
  final String alertTitle;
  final String alertMethod;
  final String lastRecordStatus;
  final String lastRecordTime;
  final String createdAt;
  final String updatedAt;
  final String? executor;
  final String? scriptMode;
  final String? script;
  final String? command;
  final String? containerName;
  final String? user;
  final int? scriptID;
  final String? appID;
  final String? website;
  final String? exclusionRules;
  final String? dbType;
  final String? dbName;
  final String? url;
  final bool? isDir;
  final String? sourceDir;
  final String? sourceAccountIDs;
  final int? downloadAccountID;
  final List<String>? sourceAccounts;
  final String? downloadAccount;
  final String? args;
  final List<String>? scopes;
  final SnapshotRuleDto? snapshotRule;

  factory CronjobDto.fromJson(Map<String, dynamic> json) {
    return CronjobDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      spec: json['spec'] as String? ?? '',
      specCustom: json['specCustom'] as bool? ?? false,
      specs: (json['specs'] as List?)?.whereType<String>().toList() ?? const [],
      groupID: json['groupID'] as int? ?? 0,
      retainCopies: json['retainCopies'] as int? ?? 3,
      retryTimes: json['retryTimes'] as int? ?? 3,
      timeout: json['timeout'] as int? ?? 60,
      ignoreErr: json['ignoreErr'] as bool? ?? false,
      secret: json['secret'] as String? ?? '',
      hasAlert: json['hasAlert'] as bool? ?? false,
      alertCount: json['alertCount'] as int? ?? 0,
      alertTitle: json['alertTitle'] as String? ?? '',
      alertMethod: json['alertMethod'] as String? ?? '',
      lastRecordStatus: json['lastRecordStatus'] as String? ?? '',
      lastRecordTime: json['lastRecordTime'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      executor: json['executor'] as String?,
      scriptMode: json['scriptMode'] as String?,
      script: json['script'] as String?,
      command: json['command'] as String?,
      containerName: json['containerName'] as String?,
      user: json['user'] as String?,
      scriptID: json['scriptID'] as int?,
      appID: json['appID'] as String?,
      website: json['website'] as String?,
      exclusionRules: json['exclusionRules'] as String?,
      dbType: json['dbType'] as String?,
      dbName: json['dbName'] as String?,
      url: json['url'] as String?,
      isDir: json['isDir'] as bool?,
      sourceDir: json['sourceDir'] as String?,
      sourceAccountIDs: json['sourceAccountIDs'] as String?,
      downloadAccountID: json['downloadAccountID'] as int?,
      sourceAccounts: (json['sourceAccounts'] as List?)
          ?.whereType<String>()
          .toList(),
      downloadAccount: json['downloadAccount'] as String?,
      args: json['args'] as String?,
      scopes: (json['scopes'] as List?)?.whereType<String>().toList(),
      snapshotRule: json['snapshotRule'] is Map<String, dynamic>
          ? SnapshotRuleDto.fromJson(
              json['snapshotRule'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class CronjobCreateReq {
  const CronjobCreateReq({
    required this.name,
    required this.type,
    required this.spec,
    this.id,
    this.specCustom = false,
    this.groupID,
    this.executor,
    this.scriptMode,
    this.script,
    this.command,
    this.containerName,
    this.user,
    this.scriptID,
    this.appID,
    this.website,
    this.exclusionRules,
    this.dbType,
    this.dbName,
    this.url,
    this.isDir,
    this.sourceDir,
    this.sourceAccountIDs,
    this.downloadAccountID,
    this.retainCopies,
    this.retryTimes,
    this.timeout,
    this.ignoreErr,
    this.secret,
    this.args,
    this.scopes,
    this.snapshotRule,
  });

  final int? id;
  final String name;
  final String type;
  final String spec;
  final bool specCustom;
  final int? groupID;
  final String? executor;
  final String? scriptMode;
  final String? script;
  final String? command;
  final String? containerName;
  final String? user;
  final int? scriptID;
  final String? appID;
  final String? website;
  final String? exclusionRules;
  final String? dbType;
  final String? dbName;
  final String? url;
  final bool? isDir;
  final String? sourceDir;
  final String? sourceAccountIDs;
  final int? downloadAccountID;
  final int? retainCopies;
  final int? retryTimes;
  final int? timeout;
  final bool? ignoreErr;
  final String? secret;
  final String? args;
  final List<String>? scopes;
  final SnapshotRuleDto? snapshotRule;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'type': type,
    'spec': spec,
    'specCustom': specCustom,
    if (groupID != null) 'groupID': groupID,
    if (executor != null) 'executor': executor,
    if (scriptMode != null) 'scriptMode': scriptMode,
    if (script != null) 'script': script,
    if (command != null) 'command': command,
    if (containerName != null) 'containerName': containerName,
    if (user != null) 'user': user,
    if (scriptID != null) 'scriptID': scriptID,
    if (appID != null) 'appID': appID,
    if (website != null) 'website': website,
    if (exclusionRules != null) 'exclusionRules': exclusionRules,
    if (dbType != null) 'dbType': dbType,
    if (dbName != null) 'dbName': dbName,
    if (url != null) 'url': url,
    if (isDir != null) 'isDir': isDir,
    if (sourceDir != null) 'sourceDir': sourceDir,
    if (sourceAccountIDs != null) 'sourceAccountIDs': sourceAccountIDs,
    if (downloadAccountID != null) 'downloadAccountID': downloadAccountID,
    if (retainCopies != null) 'retainCopies': retainCopies,
    if (retryTimes != null) 'retryTimes': retryTimes,
    if (timeout != null) 'timeout': timeout,
    if (ignoreErr != null) 'ignoreErr': ignoreErr,
    if (secret != null) 'secret': secret,
    if (args != null) 'args': args,
    if (snapshotRule != null) 'snapshotRule': snapshotRule!.toJson(),
    if (scopes != null) 'scopes': scopes,
  };
}

class CronjobRecordDto {
  const CronjobRecordDto({
    required this.id,
    required this.taskID,
    required this.startTime,
    required this.records,
    required this.status,
    required this.message,
    required this.targetPath,
    required this.interval,
    required this.file,
  });

  final int id;
  final String taskID;
  final String startTime;
  final String records;
  final String status;
  final String message;
  final String targetPath;
  final int interval;
  final String file;

  factory CronjobRecordDto.fromJson(Map<String, dynamic> json) {
    return CronjobRecordDto(
      id: json['id'] as int? ?? 0,
      taskID: json['taskID'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      records: json['records'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      targetPath: json['targetPath'] as String? ?? '',
      interval: json['interval'] as int? ?? 0,
      file: json['file'] as String? ?? '',
    );
  }
}

class SpecObj {
  const SpecObj({
    required this.specType,
    this.week = 0,
    this.day = 0,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
  });

  final String specType;
  final int week;
  final int day;
  final int hour;
  final int minute;
  final int second;

  Map<String, dynamic> toJson() => {
    'specType': specType,
    'week': week,
    'day': day,
    'hour': hour,
    'minute': minute,
    'second': second,
  };
}
