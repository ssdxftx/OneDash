// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnapshotInfo _$SnapshotInfoFromJson(Map<String, dynamic> json) => SnapshotInfo(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  sourceAccounts:
      (json['sourceAccounts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  downloadAccount: json['downloadAccount'] as String? ?? '',
  status: json['status'] as String? ?? '',
  message: json['message'] as String? ?? '',
  createdAt: json['createdAt'] as String? ?? '',
  version: json['version'] as String? ?? '',
  size: (json['size'] as num?)?.toInt() ?? 0,
  taskID: json['taskID'] as String? ?? '',
  interruptStep: json['interruptStep'] as String? ?? '',
  recoverStatus: json['recoverStatus'] as String? ?? '',
  recoverMessage: json['recoverMessage'] as String? ?? '',
  lastRecoveredAt: json['lastRecoveredAt'] as String? ?? '',
  rollbackStatus: json['rollbackStatus'] as String? ?? '',
  rollbackMessage: json['rollbackMessage'] as String? ?? '',
  lastRollbackedAt: json['lastRollbackedAt'] as String? ?? '',
);

Map<String, dynamic> _$SnapshotInfoToJson(SnapshotInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sourceAccounts': instance.sourceAccounts,
      'downloadAccount': instance.downloadAccount,
      'status': instance.status,
      'message': instance.message,
      'createdAt': instance.createdAt,
      'version': instance.version,
      'size': instance.size,
      'taskID': instance.taskID,
      'interruptStep': instance.interruptStep,
      'recoverStatus': instance.recoverStatus,
      'recoverMessage': instance.recoverMessage,
      'lastRecoveredAt': instance.lastRecoveredAt,
      'rollbackStatus': instance.rollbackStatus,
      'rollbackMessage': instance.rollbackMessage,
      'lastRollbackedAt': instance.lastRollbackedAt,
    };

SnapshotSearchReq _$SnapshotSearchReqFromJson(Map<String, dynamic> json) =>
    SnapshotSearchReq(
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      info: json['info'] as String? ?? '',
      orderBy: json['orderBy'] as String? ?? 'createdAt',
      order: json['order'] as String? ?? 'null',
    );

Map<String, dynamic> _$SnapshotSearchReqToJson(SnapshotSearchReq instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'info': instance.info,
      'orderBy': instance.orderBy,
      'order': instance.order,
    };

SnapshotDeleteReq _$SnapshotDeleteReqFromJson(Map<String, dynamic> json) =>
    SnapshotDeleteReq(
      ids: (json['ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      deleteWithFile: json['deleteWithFile'] as bool? ?? false,
    );

Map<String, dynamic> _$SnapshotDeleteReqToJson(SnapshotDeleteReq instance) =>
    <String, dynamic>{
      'ids': instance.ids,
      'deleteWithFile': instance.deleteWithFile,
    };

SnapshotRecoverReq _$SnapshotRecoverReqFromJson(Map<String, dynamic> json) =>
    SnapshotRecoverReq(
      id: (json['id'] as num).toInt(),
      isNew: json['isNew'] as bool? ?? false,
      reDownload: json['reDownload'] as bool? ?? false,
      taskID: json['taskID'] as String? ?? '',
      secret: json['secret'] as String? ?? '',
    );

Map<String, dynamic> _$SnapshotRecoverReqToJson(SnapshotRecoverReq instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isNew': instance.isNew,
      'reDownload': instance.reDownload,
      'taskID': instance.taskID,
      'secret': instance.secret,
    };

SnapshotImportReq _$SnapshotImportReqFromJson(Map<String, dynamic> json) =>
    SnapshotImportReq(
      backupAccountID: (json['backupAccountID'] as num).toInt(),
      names: (json['names'] as List<dynamic>).map((e) => e as String).toList(),
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$SnapshotImportReqToJson(SnapshotImportReq instance) =>
    <String, dynamic>{
      'backupAccountID': instance.backupAccountID,
      'names': instance.names,
      'description': instance.description,
    };

DataTree _$DataTreeFromJson(Map<String, dynamic> json) => DataTree(
  id: json['id'] as String? ?? '',
  label: json['label'] as String? ?? '',
  key: json['key'] as String? ?? '',
  name: json['name'] as String? ?? '',
  isLocal: json['isLocal'] as bool? ?? false,
  size: (json['size'] as num?)?.toInt() ?? 0,
  isCheck: json['isCheck'] as bool? ?? false,
  isDisable: json['isDisable'] as bool? ?? false,
  path: json['path'] as String? ?? '',
  children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => DataTree.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DataTreeToJson(DataTree instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'key': instance.key,
  'name': instance.name,
  'isLocal': instance.isLocal,
  'size': instance.size,
  'isCheck': instance.isCheck,
  'isDisable': instance.isDisable,
  'path': instance.path,
  'children': instance.children,
};

SnapshotData _$SnapshotDataFromJson(Map<String, dynamic> json) => SnapshotData(
  appData:
      (json['appData'] as List<dynamic>?)
          ?.map((e) => DataTree.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  backupData:
      (json['backupData'] as List<dynamic>?)
          ?.map((e) => DataTree.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  panelData:
      (json['panelData'] as List<dynamic>?)
          ?.map((e) => DataTree.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  withDockerConf: json['withDockerConf'] as bool? ?? false,
  withMonitorData: json['withMonitorData'] as bool? ?? false,
  withLoginLog: json['withLoginLog'] as bool? ?? false,
  withOperationLog: json['withOperationLog'] as bool? ?? false,
  withSystemLog: json['withSystemLog'] as bool? ?? false,
  withTaskLog: json['withTaskLog'] as bool? ?? false,
  ignoreFiles:
      (json['ignoreFiles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$SnapshotDataToJson(SnapshotData instance) =>
    <String, dynamic>{
      'appData': instance.appData,
      'backupData': instance.backupData,
      'panelData': instance.panelData,
      'withDockerConf': instance.withDockerConf,
      'withMonitorData': instance.withMonitorData,
      'withLoginLog': instance.withLoginLog,
      'withOperationLog': instance.withOperationLog,
      'withSystemLog': instance.withSystemLog,
      'withTaskLog': instance.withTaskLog,
      'ignoreFiles': instance.ignoreFiles,
    };
