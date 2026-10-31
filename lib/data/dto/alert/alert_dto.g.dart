// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertInfo _$AlertInfoFromJson(Map<String, dynamic> json) => AlertInfo(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String? ?? '',
  cycle: (json['cycle'] as num?)?.toInt() ?? 0,
  count: (json['count'] as num?)?.toInt() ?? 0,
  method: json['method'] as String? ?? '',
  title: json['title'] as String? ?? '',
  project: json['project'] as String? ?? '',
  status: json['status'] as String? ?? '',
  sendCount: (json['sendCount'] as num?)?.toInt() ?? 0,
  advancedParams: json['advancedParams'] as String? ?? '',
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$AlertInfoToJson(AlertInfo instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'cycle': instance.cycle,
  'count': instance.count,
  'method': instance.method,
  'title': instance.title,
  'project': instance.project,
  'status': instance.status,
  'sendCount': instance.sendCount,
  'advancedParams': instance.advancedParams,
  'createdAt': instance.createdAt,
};

AlertCreateReq _$AlertCreateReqFromJson(Map<String, dynamic> json) =>
    AlertCreateReq(
      type: json['type'] as String,
      method: json['method'] as String,
      cycle: (json['cycle'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      project: json['project'] as String? ?? '',
      status: json['status'] as String? ?? 'Enable',
      sendCount: (json['sendCount'] as num?)?.toInt() ?? 0,
      advancedParams: json['advancedParams'] as String? ?? '',
    );

Map<String, dynamic> _$AlertCreateReqToJson(AlertCreateReq instance) =>
    <String, dynamic>{
      'type': instance.type,
      'cycle': instance.cycle,
      'count': instance.count,
      'method': instance.method,
      'title': instance.title,
      'project': instance.project,
      'status': instance.status,
      'sendCount': instance.sendCount,
      'advancedParams': instance.advancedParams,
    };

AlertSearchReq _$AlertSearchReqFromJson(Map<String, dynamic> json) =>
    AlertSearchReq(
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      method: json['method'] as String? ?? '',
      orderBy: json['orderBy'] as String? ?? 'created_at',
      order: json['order'] as String?,
    );

Map<String, dynamic> _$AlertSearchReqToJson(AlertSearchReq instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'type': instance.type,
      'status': instance.status,
      'method': instance.method,
      'orderBy': instance.orderBy,
      'order': instance.order,
    };

AlertLogInfo _$AlertLogInfoFromJson(Map<String, dynamic> json) => AlertLogInfo(
  id: (json['id'] as num).toInt(),
  alertId: (json['alertId'] as num?)?.toInt() ?? 0,
  message: json['message'] as String? ?? '',
  status: json['status'] as String? ?? '',
  method: json['method'] as String? ?? '',
  sendCount: (json['sendCount'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$AlertLogInfoToJson(AlertLogInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alertId': instance.alertId,
      'message': instance.message,
      'status': instance.status,
      'method': instance.method,
      'sendCount': instance.sendCount,
      'createdAt': instance.createdAt,
    };

AlertLogSearchReq _$AlertLogSearchReqFromJson(Map<String, dynamic> json) =>
    AlertLogSearchReq(
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      status: json['status'] as String? ?? '',
    );

Map<String, dynamic> _$AlertLogSearchReqToJson(AlertLogSearchReq instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'status': instance.status,
    };

AlertConfigInfo _$AlertConfigInfoFromJson(Map<String, dynamic> json) =>
    AlertConfigInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      config: json['config'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$AlertConfigInfoToJson(AlertConfigInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'config': instance.config,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };

AlertConfigUpdateReq _$AlertConfigUpdateReqFromJson(
  Map<String, dynamic> json,
) => AlertConfigUpdateReq(
  id: (json['id'] as num?)?.toInt() ?? 0,
  type: json['type'] as String,
  title: json['title'] as String? ?? '',
  config: json['config'] as String? ?? '',
  status: json['status'] as String? ?? '',
);

Map<String, dynamic> _$AlertConfigUpdateReqToJson(
  AlertConfigUpdateReq instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'title': instance.title,
  'config': instance.config,
  'status': instance.status,
};

AlertConfigTestReq _$AlertConfigTestReqFromJson(Map<String, dynamic> json) =>
    AlertConfigTestReq(
      host: json['host'] as String? ?? '',
      port: (json['port'] as num?)?.toInt() ?? 0,
      sender: json['sender'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      password: json['password'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      encryption: json['encryption'] as String? ?? '',
      recipient: json['recipient'] as String? ?? '',
    );

Map<String, dynamic> _$AlertConfigTestReqToJson(AlertConfigTestReq instance) =>
    <String, dynamic>{
      'host': instance.host,
      'port': instance.port,
      'sender': instance.sender,
      'userName': instance.userName,
      'password': instance.password,
      'displayName': instance.displayName,
      'encryption': instance.encryption,
      'recipient': instance.recipient,
    };
