/// 网站关联资源项（来自 GET /api/v2/websites/resource/{id}）。
class WebsiteResourceDto {
  const WebsiteResourceDto({
    required this.name,
    required this.type,
    required this.resourceID,
    this.detail,
  });

  final String name;
  final String type;
  final int resourceID;
  final String? detail;

  factory WebsiteResourceDto.fromJson(Map<String, dynamic> json) {
    // detail 可能是 String 或 Map，统一转为 String
    final rawDetail = json['detail'];
    String? detailStr;
    if (rawDetail is String) {
      detailStr = rawDetail;
    } else if (rawDetail != null) {
      detailStr = rawDetail.toString();
    }

    return WebsiteResourceDto(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      resourceID: json['resourceID'] as int? ?? 0,
      detail: detailStr,
    );
  }
}

/// 可关联的数据库项（来自 GET /api/v2/websites/databases）。
class WebsiteDatabaseDto {
  const WebsiteDatabaseDto({
    required this.id,
    required this.name,
    required this.type,
    required this.from,
    required this.databaseName,
  });

  final int id;
  final String name;
  final String type;
  final String from;
  final String databaseName;

  factory WebsiteDatabaseDto.fromJson(Map<String, dynamic> json) {
    return WebsiteDatabaseDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      from: json['from'] as String? ?? '',
      databaseName: json['databaseName'] as String? ?? '',
    );
  }
}

/// 更换关联数据库请求体（POST /api/v2/websites/databases）。
class WebsiteChangeDatabaseReq {
  const WebsiteChangeDatabaseReq({
    required this.websiteID,
    this.databaseID,
    this.databaseType,
  });

  final int websiteID;
  final int? databaseID;
  final String? databaseType;

  Map<String, dynamic> toJson() {
    return {
      'websiteID': websiteID,
      'databaseID': databaseID ?? 0,
      'databaseType': databaseType ?? '',
    };
  }
}
