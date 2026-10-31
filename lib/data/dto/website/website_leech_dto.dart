class WebsiteLeechDto {
  const WebsiteLeechDto({
    this.enable = false,
    this.extensions = '',
    this.extendsName = '',
    this.returnCode = '',
    this.returnCodeAlt = '',
    this.serverNames = const [],
    this.cache = false,
    this.cacheTime = 0,
    this.cacheUint = '',
    this.noneRef = false,
    this.logEnable = true,
    this.blocked = false,
  });

  final bool enable;
  final String extensions;
  final String extendsName;
  final String returnCode;
  final String returnCodeAlt;
  final List<String> serverNames;
  final bool cache;
  final int cacheTime;
  final String cacheUint;
  final bool noneRef;
  final bool logEnable;
  final bool blocked;

  factory WebsiteLeechDto.fromJson(Map<String, dynamic> json) {
    return WebsiteLeechDto(
      enable: json['enable'] as bool? ?? false,
      extensions: json['extends'] as String? ?? '',
      extendsName: json['extendsName'] as String? ?? '',
      returnCode: json['return'] as String? ?? '',
      returnCodeAlt: json['returnCodeAlt'] as String? ?? '',
      serverNames: (json['serverNames'] as List?)?.cast<String>() ?? const [],
      cache: json['cache'] as bool? ?? false,
      cacheTime: (json['cacheTime'] as num?)?.toInt() ?? 0,
      cacheUint: json['cacheUint'] as String? ?? '',
      noneRef: json['noneRef'] as bool? ?? false,
      logEnable: json['logEnable'] as bool? ?? true,
      blocked: json['blocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable': enable,
      'extends': extensions,
      'extendsName': extendsName,
      'return': returnCode,
      'returnCodeAlt': returnCodeAlt,
      'serverNames': serverNames,
      'cache': cache,
      'cacheTime': cacheTime,
      'cacheUint': cacheUint,
      'noneRef': noneRef,
      'logEnable': logEnable,
      'blocked': blocked,
    };
  }
}

class WebsiteLeechUpdateReq {
  const WebsiteLeechUpdateReq({
    required this.websiteID,
    required this.enable,
    required this.cache,
    required this.cacheTime,
    required this.cacheUint,
    required this.extensions,
    required this.returnCode,
    required this.domains,
    required this.noneRef,
    required this.logEnable,
    required this.blocked,
    required this.serverNames,
  });

  final int websiteID;
  final bool enable;
  final bool cache;
  final int cacheTime;
  final String cacheUint;
  final String extensions;
  final String returnCode;
  final String domains;
  final bool noneRef;
  final bool logEnable;
  final bool blocked;
  final List<String> serverNames;

  Map<String, dynamic> toJson() {
    return {
      'websiteID': websiteID,
      'enable': enable,
      'cache': cache,
      'cacheTime': cacheTime,
      'cacheUint': cacheUint,
      'extends': extensions,
      'return': returnCode,
      'domains': domains,
      'noneRef': noneRef,
      'logEnable': logEnable,
      'blocked': blocked,
      'serverNames': serverNames,
    };
  }
}
