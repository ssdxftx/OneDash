/// 网站 DTO
class WebsiteDto {
  const WebsiteDto({
    required this.id,
    required this.primaryDomain,
    required this.status,
    required this.type,
    required this.protocol,
    required this.expireDate,
    required this.sslExpireDate,
    required this.remark,
    required this.createdAt,
    required this.updatedAt,
    required this.siteDir,
    required this.sitePath,
    required this.runtimeName,
    required this.websiteRuntimeType,
    required this.dbID,
    required this.dbType,
  });

  final int id;
  final String primaryDomain;
  final String status;
  final String type;
  final String protocol;
  final String expireDate;
  final String sslExpireDate;
  final String remark;
  final String createdAt;
  final String updatedAt;
  final String siteDir;
  final String sitePath;
  final String runtimeName;
  final String websiteRuntimeType;
  final int dbID;
  final String dbType;

  factory WebsiteDto.fromJson(Map<String, dynamic> json) {
    return WebsiteDto(
      id: json['id'] as int? ?? 0,
      primaryDomain: json['primaryDomain'] as String? ?? '',
      status: json['status'] as String? ?? '',
      type: json['type'] as String? ?? '',
      protocol: json['protocol'] as String? ?? '',
      expireDate: json['expireDate'] as String? ?? '',
      sslExpireDate: json['sslExpireDate'] as String? ?? '',
      remark: json['remark'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      siteDir: json['siteDir'] as String? ?? '',
      sitePath: json['sitePath'] as String? ?? '',
      runtimeName: json['runtimeName'] as String? ?? '',
      websiteRuntimeType: json['runtimeType'] as String? ?? '',
      dbID: json['dbID'] as int? ?? 0,
      dbType: json['dbType'] as String? ?? '',
    );
  }
}
