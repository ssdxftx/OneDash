import 'package:json_annotation/json_annotation.dart';

part 'alert_dto.g.dart';

@JsonSerializable()
class AlertInfo {
  const AlertInfo({
    required this.id,
    this.type = '',
    this.cycle = 0,
    this.count = 0,
    this.method = '',
    this.title = '',
    this.project = '',
    this.status = '',
    this.sendCount = 0,
    this.advancedParams = '',
    this.createdAt,
  });

  final int id;
  final String type;
  final int cycle;
  final int count;
  final String method;
  final String title;
  final String project;
  final String status;
  final int sendCount;
  final String advancedParams;
  final String? createdAt;

  factory AlertInfo.fromJson(Map<String, dynamic> json) =>
      _$AlertInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AlertInfoToJson(this);
}

@JsonSerializable()
class AlertCreateReq {
  const AlertCreateReq({
    required this.type,
    required this.method,
    this.cycle = 0,
    this.count = 0,
    this.title = '',
    this.project = '',
    this.status = 'Enable',
    this.sendCount = 0,
    this.advancedParams = '',
  });

  final String type;
  final int cycle;
  final int count;
  final String method;
  final String title;
  final String project;
  final String status;
  final int sendCount;
  final String advancedParams;

  factory AlertCreateReq.fromJson(Map<String, dynamic> json) =>
      _$AlertCreateReqFromJson(json);
  Map<String, dynamic> toJson() => _$AlertCreateReqToJson(this);
}

@JsonSerializable()
class AlertSearchReq {
  const AlertSearchReq({
    required this.page,
    required this.pageSize,
    this.type = '',
    this.status = '',
    this.method = '',
    this.orderBy = 'created_at',
    this.order = 'null',
  });

  final int page;
  final int pageSize;
  final String type;
  final String status;
  final String method;
  final String orderBy;
  final String order;

  factory AlertSearchReq.fromJson(Map<String, dynamic> json) =>
      _$AlertSearchReqFromJson(json);
  Map<String, dynamic> toJson() => _$AlertSearchReqToJson(this);
}

@JsonSerializable()
class AlertLogInfo {
  const AlertLogInfo({
    required this.id,
    this.alertId = 0,
    this.message = '',
    this.status = '',
    this.method = '',
    this.sendCount = 0,
    this.createdAt,
  });

  final int id;
  final int alertId;
  final String message;
  final String status;
  final String method;
  final int sendCount;
  final String? createdAt;

  factory AlertLogInfo.fromJson(Map<String, dynamic> json) =>
      _$AlertLogInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AlertLogInfoToJson(this);
}

@JsonSerializable()
class AlertLogSearchReq {
  const AlertLogSearchReq({
    required this.page,
    required this.pageSize,
    this.status = '',
  });

  final int page;
  final int pageSize;
  final String status;

  factory AlertLogSearchReq.fromJson(Map<String, dynamic> json) =>
      _$AlertLogSearchReqFromJson(json);
  Map<String, dynamic> toJson() => _$AlertLogSearchReqToJson(this);
}

@JsonSerializable()
class AlertConfigInfo {
  const AlertConfigInfo({
    this.id = 0,
    this.type = '',
    this.title = '',
    this.config = '',
    this.status = '',
    this.displayName = '',
    this.revision,
    this.createdAt,
  });

  final int id;
  final String type;
  final String title;
  final String config;
  final String status;
  final String displayName;
  final String? revision;
  final String? createdAt;

  factory AlertConfigInfo.fromJson(Map<String, dynamic> json) =>
      _$AlertConfigInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AlertConfigInfoToJson(this);
}

@JsonSerializable()
class AlertConfigUpdateReq {
  const AlertConfigUpdateReq({
    this.id = 0,
    required this.type,
    this.title = '',
    this.config = '',
    this.status = '',
    this.displayName = '',
    this.revision,
  });

  final int id;
  final String type;
  final String title;
  final String config;
  final String status;
  final String displayName;
  final String? revision;

  factory AlertConfigUpdateReq.fromJson(Map<String, dynamic> json) =>
      _$AlertConfigUpdateReqFromJson(json);
  Map<String, dynamic> toJson() => _$AlertConfigUpdateReqToJson(this);
}

@JsonSerializable()
class AlertConfigTestReq {
  const AlertConfigTestReq({
    this.id = 0,
    this.type = '',
    this.config = '',
    this.host = '',
    this.port = 0,
    this.sender = '',
    this.userName = '',
    this.password = '',
    this.displayName = '',
    this.encryption = '',
    this.recipient = '',
  });

  final int id;
  final String type;
  final String config;
  final String host;
  final int port;
  final String sender;
  final String userName;
  final String password;
  final String displayName;
  final String encryption;
  final String recipient;

  factory AlertConfigTestReq.fromJson(Map<String, dynamic> json) =>
      _$AlertConfigTestReqFromJson(json);
  Map<String, dynamic> toJson() => _$AlertConfigTestReqToJson(this);
}

@JsonSerializable()
class AlertConfigSearchReq {
  const AlertConfigSearchReq({
    required this.page,
    required this.pageSize,
    this.excludeTypes = const [],
  });

  final int page;
  final int pageSize;
  final List<String> excludeTypes;

  factory AlertConfigSearchReq.fromJson(Map<String, dynamic> json) =>
      _$AlertConfigSearchReqFromJson(json);
  Map<String, dynamic> toJson() => _$AlertConfigSearchReqToJson(this);
}

@JsonSerializable()
class ClamAlertInfo {
  const ClamAlertInfo({
    required this.id,
    this.name = '',
    this.status = '',
    this.path = '',
    this.createdAt,
  });

  final int id;
  final String name;
  final String status;
  final String path;
  final String? createdAt;

  factory ClamAlertInfo.fromJson(Map<String, dynamic> json) =>
      _$ClamAlertInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ClamAlertInfoToJson(this);
}

@JsonSerializable()
class CronJobAlertInfo {
  const CronJobAlertInfo({
    required this.id,
    this.name = '',
    this.status = '',
    this.type = '',
    this.createdAt,
  });

  final int id;
  final String name;
  final String status;
  final String type;
  final String? createdAt;

  factory CronJobAlertInfo.fromJson(Map<String, dynamic> json) =>
      _$CronJobAlertInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CronJobAlertInfoToJson(this);
}
