import 'package:json_annotation/json_annotation.dart';

part 'snapshot_dto.g.dart';

@JsonSerializable()
class SnapshotInfo {
  const SnapshotInfo({
    required this.id,
    this.name = '',
    this.description = '',
    this.sourceAccounts = const [],
    this.downloadAccount = '',
    this.status = '',
    this.message = '',
    this.createdAt = '',
    this.version = '',
    this.size = 0,
    this.taskID = '',
    this.interruptStep = '',
    this.recoverStatus = '',
    this.recoverMessage = '',
    this.lastRecoveredAt = '',
    this.rollbackStatus = '',
    this.rollbackMessage = '',
    this.lastRollbackedAt = '',
  });

  final int id;
  final String name;
  final String description;
  final List<String> sourceAccounts;
  final String downloadAccount;
  final String status;
  final String message;
  final String createdAt;
  final String version;
  final int size;
  final String taskID;
  final String interruptStep;
  final String recoverStatus;
  final String recoverMessage;
  final String lastRecoveredAt;
  final String rollbackStatus;
  final String rollbackMessage;
  final String lastRollbackedAt;

  factory SnapshotInfo.fromJson(Map<String, dynamic> json) =>
      _$SnapshotInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SnapshotInfoToJson(this);
}

@JsonSerializable()
class SnapshotSearchReq {
  const SnapshotSearchReq({
    required this.page,
    required this.pageSize,
    this.info = '',
    this.orderBy = 'createdAt',
    this.order = 'null',
  });

  final int page;
  final int pageSize;
  final String info;
  final String orderBy;
  final String order;

  factory SnapshotSearchReq.fromJson(Map<String, dynamic> json) =>
      _$SnapshotSearchReqFromJson(json);
  Map<String, dynamic> toJson() => _$SnapshotSearchReqToJson(this);
}

@JsonSerializable()
class SnapshotDeleteReq {
  const SnapshotDeleteReq({required this.ids, this.deleteWithFile = false});

  final List<int> ids;
  final bool deleteWithFile;

  factory SnapshotDeleteReq.fromJson(Map<String, dynamic> json) =>
      _$SnapshotDeleteReqFromJson(json);
  Map<String, dynamic> toJson() => _$SnapshotDeleteReqToJson(this);
}

@JsonSerializable()
class SnapshotRecoverReq {
  const SnapshotRecoverReq({
    required this.id,
    this.isNew = false,
    this.reDownload = false,
    this.taskID = '',
    this.secret = '',
  });

  final int id;
  final bool isNew;
  final bool reDownload;
  final String taskID;
  final String secret;

  factory SnapshotRecoverReq.fromJson(Map<String, dynamic> json) =>
      _$SnapshotRecoverReqFromJson(json);
  Map<String, dynamic> toJson() => _$SnapshotRecoverReqToJson(this);
}

@JsonSerializable()
class SnapshotImportReq {
  const SnapshotImportReq({
    required this.backupAccountID,
    required this.names,
    this.description = '',
  });

  final int backupAccountID;
  final List<String> names;
  final String description;

  factory SnapshotImportReq.fromJson(Map<String, dynamic> json) =>
      _$SnapshotImportReqFromJson(json);
  Map<String, dynamic> toJson() => _$SnapshotImportReqToJson(this);
}

@JsonSerializable()
class DataTree {
  const DataTree({
    this.id = '',
    this.label = '',
    this.key = '',
    this.name = '',
    this.isLocal = false,
    this.size = 0,
    this.isCheck = false,
    this.isDisable = false,
    this.path = '',
    this.children = const [],
  });

  final String id;
  final String label;
  final String key;
  final String name;
  final bool isLocal;
  final int size;
  final bool isCheck;
  final bool isDisable;
  final String path;
  final List<DataTree> children;

  factory DataTree.fromJson(Map<String, dynamic> json) =>
      _$DataTreeFromJson(json);
  Map<String, dynamic> toJson() => _$DataTreeToJson(this);
}

@JsonSerializable()
class SnapshotData {
  const SnapshotData({
    this.appData = const [],
    this.backupData = const [],
    this.panelData = const [],
    this.withDockerConf = false,
    this.withMonitorData = false,
    this.withLoginLog = false,
    this.withOperationLog = false,
    this.withSystemLog = false,
    this.withTaskLog = false,
    this.ignoreFiles = const [],
  });

  final List<DataTree> appData;
  final List<DataTree> backupData;
  final List<DataTree> panelData;
  final bool withDockerConf;
  final bool withMonitorData;
  final bool withLoginLog;
  final bool withOperationLog;
  final bool withSystemLog;
  final bool withTaskLog;
  final List<String> ignoreFiles;

  factory SnapshotData.fromJson(Map<String, dynamic> json) =>
      _$SnapshotDataFromJson(json);
  Map<String, dynamic> toJson() => _$SnapshotDataToJson(this);
}
