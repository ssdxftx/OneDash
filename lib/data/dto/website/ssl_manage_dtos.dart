import 'website_acme_account_dto.dart';
import 'website_dto.dart';

// ---------------------------------------------------------------------------
// SSL 证书
// ---------------------------------------------------------------------------

class SslManageDto {
  const SslManageDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.primaryDomain,
    required this.otherDomains,
    required this.provider,
    required this.type,
    required this.status,
    required this.message,
    required this.expireDate,
    required this.startDate,
    required this.organization,
    required this.acmeAccountId,
    required this.dnsAccountId,
    required this.caId,
    required this.description,
    required this.dir,
    required this.shell,
    required this.keyType,
    required this.domains,
    required this.autoRenew,
    required this.pushDir,
    required this.execShell,
    required this.pushNode,
    required this.isIp,
    required this.disableCNAME,
    required this.skipDNS,
    required this.nameserver1,
    required this.nameserver2,
    required this.nodes,
    required this.masterSslId,
    required this.privateKeyPath,
    required this.certPath,
    required this.certURL,
    required this.privateKey,
    required this.pem,
    required this.logPath,
    required this.websites,
    this.acmeAccount,
    this.dnsAccount,
  });

  final int id;
  final String createdAt;
  final String updatedAt;
  final int acmeAccountId;
  final int dnsAccountId;
  final int caId;
  final String primaryDomain;
  final String otherDomains;
  final String provider;
  final String type;
  final String status;
  final String message;
  final String expireDate;
  final String startDate;
  final String organization;
  final String description;
  final String dir;
  final String shell;
  final String keyType;
  final String domains;
  final bool autoRenew;
  final bool pushDir;
  final bool execShell;
  final bool pushNode;
  final bool isIp;
  final bool disableCNAME;
  final bool skipDNS;
  final String nameserver1;
  final String nameserver2;
  final String nodes;
  final int masterSslId;
  final String privateKeyPath;
  final String certPath;
  final String certURL;
  final String privateKey;
  final String pem;
  final String logPath;
  final List<WebsiteDto> websites;
  final WebsiteAcmeAccountDto? acmeAccount;
  final DnsAccountDto? dnsAccount;

  factory SslManageDto.fromJson(Map<String, dynamic> json) {
    final acmeAccountJson = json['acmeAccount'];
    final dnsAccountJson = json['dnsAccount'];
    final domains = json['domains'] as String? ?? '';
    final websitesJson = json['websites'] as List?;

    return SslManageDto(
      id: json['id'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      acmeAccountId: json['acmeAccountId'] as int? ?? 0,
      dnsAccountId: json['dnsAccountId'] as int? ?? 0,
      caId: json['caId'] as int? ?? 0,
      primaryDomain: json['primaryDomain'] as String? ?? '',
      otherDomains: json['otherDomains'] as String? ?? domains,
      provider: json['provider'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      expireDate: json['expireDate'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dir: json['dir'] as String? ?? '',
      shell: json['shell'] as String? ?? '',
      keyType: json['keyType'] as String? ?? '',
      domains: domains,
      autoRenew: json['autoRenew'] as bool? ?? false,
      pushDir: json['pushDir'] as bool? ?? false,
      execShell: json['execShell'] as bool? ?? false,
      pushNode: json['pushNode'] as bool? ?? false,
      isIp: json['isIP'] as bool? ?? json['isIp'] as bool? ?? false,
      disableCNAME: json['disableCNAME'] as bool? ?? false,
      skipDNS: json['skipDNS'] as bool? ?? false,
      nameserver1: json['nameserver1'] as String? ?? '',
      nameserver2: json['nameserver2'] as String? ?? '',
      nodes: json['nodes'] as String? ?? '',
      masterSslId: json['masterSslId'] as int? ?? 0,
      privateKeyPath: json['privateKeyPath'] as String? ?? '',
      certPath: json['certPath'] as String? ?? '',
      certURL: json['certURL'] as String? ?? '',
      privateKey: json['privateKey'] as String? ?? '',
      pem: json['pem'] as String? ?? '',
      logPath: json['logPath'] as String? ?? '',
      websites:
          websitesJson
              ?.whereType<Map<String, dynamic>>()
              .map(WebsiteDto.fromJson)
              .toList() ??
          const <WebsiteDto>[],
      acmeAccount: acmeAccountJson is Map<String, dynamic>
          ? WebsiteAcmeAccountDto.fromJson(acmeAccountJson)
          : null,
      dnsAccount: dnsAccountJson is Map<String, dynamic>
          ? DnsAccountDto.fromJson(dnsAccountJson)
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// SSL 创建 / 更新请求
// ---------------------------------------------------------------------------

class SslCreateReq {
  const SslCreateReq({
    required this.primaryDomain,
    required this.otherDomains,
    required this.provider,
    required this.keyType,
    required this.description,
    required this.dir,
    required this.shell,
    required this.nodes,
    required this.acmeAccountId,
    required this.dnsAccountId,
    required this.autoRenew,
    required this.pushDir,
    required this.execShell,
    required this.pushNode,
    required this.isIp,
    required this.disableCNAME,
    required this.skipDNS,
    required this.nameserver1,
    required this.nameserver2,
  });

  final String primaryDomain;
  final String otherDomains;
  final String provider;
  final String keyType;
  final String description;
  final String dir;
  final String shell;
  final String nodes;
  final int acmeAccountId;
  final int dnsAccountId;
  final bool autoRenew;
  final bool pushDir;
  final bool execShell;
  final bool pushNode;
  final bool isIp;
  final bool disableCNAME;
  final bool skipDNS;
  final String nameserver1;
  final String nameserver2;

  Map<String, dynamic> toJson() => {
    'primaryDomain': primaryDomain,
    'otherDomains': otherDomains,
    'provider': provider,
    'keyType': keyType,
    'description': description,
    'dir': dir,
    'shell': shell,
    'nodes': nodes,
    'acmeAccountId': acmeAccountId,
    'dnsAccountId': dnsAccountId,
    'autoRenew': autoRenew,
    'pushDir': pushDir,
    'execShell': execShell,
    'pushNode': pushNode,
    'isIP': isIp,
    'disableCNAME': disableCNAME,
    'skipDNS': skipDNS,
    'nameserver1': nameserver1,
    'nameserver2': nameserver2,
  };
}

class SslUpdateReq extends SslCreateReq {
  const SslUpdateReq({
    required this.id,
    required super.primaryDomain,
    required super.otherDomains,
    required super.provider,
    required super.keyType,
    required super.description,
    required super.dir,
    required super.shell,
    required super.nodes,
    required super.acmeAccountId,
    required super.dnsAccountId,
    required super.autoRenew,
    required super.pushDir,
    required super.execShell,
    required super.pushNode,
    required super.isIp,
    required super.disableCNAME,
    required super.skipDNS,
    required super.nameserver1,
    required super.nameserver2,
  });

  final int id;

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'id': id};
}

// ---------------------------------------------------------------------------
// SSL DNS 解析验证
// ---------------------------------------------------------------------------

class SslResolveDto {
  const SslResolveDto({
    required this.domain,
    required this.resolve,
    required this.value,
    required this.err,
  });

  final String domain;
  final String resolve;
  final String value;
  final String err;

  factory SslResolveDto.fromJson(Map<String, dynamic> json) {
    return SslResolveDto(
      domain: json['domain'] as String? ?? '',
      resolve: json['resolve'] as String? ?? '',
      value: json['value'] as String? ?? '',
      err: json['err'] as String? ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// ACME 账号创建请求
// ---------------------------------------------------------------------------

class AcmeAccountCreateReq {
  const AcmeAccountCreateReq({
    required this.email,
    required this.type,
    required this.keyType,
    required this.caDirURL,
    required this.eabKid,
    required this.eabHmacKey,
    required this.useProxy,
    required this.useEAB,
  });

  final String email;
  final String type;
  final String keyType;
  final String caDirURL;
  final String eabKid;
  final String eabHmacKey;
  final bool useProxy;
  final bool useEAB;

  Map<String, dynamic> toJson() => {
    'email': email,
    'type': type,
    'keyType': keyType,
    'caDirURL': caDirURL,
    'eabKid': eabKid,
    'eabHmacKey': eabHmacKey,
    'useProxy': useProxy,
    'useEAB': useEAB,
  };
}

// ---------------------------------------------------------------------------
// DNS 账号
// ---------------------------------------------------------------------------

class DnsAccountDto {
  const DnsAccountDto({
    required this.id,
    required this.name,
    required this.type,
    required this.authorization,
  });

  final int id;
  final String name;
  final String type;
  final Map<String, dynamic> authorization;

  factory DnsAccountDto.fromJson(Map<String, dynamic> json) {
    return DnsAccountDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      authorization: json['authorization'] as Map<String, dynamic>? ?? const {},
    );
  }
}

class DnsAccountCreateReq {
  const DnsAccountCreateReq({
    required this.name,
    required this.type,
    required this.authorization,
  });

  final String name;
  final String type;
  final Map<String, dynamic> authorization;

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'authorization': authorization,
  };
}

// ---------------------------------------------------------------------------
// 自签 CA
// ---------------------------------------------------------------------------

class CaDto {
  const CaDto({
    required this.id,
    required this.name,
    required this.commonName,
    required this.country,
    required this.organization,
    required this.organizationUnit,
    required this.province,
    required this.city,
    required this.keyType,
    required this.sslId,
    this.certificate,
    this.privateKey,
  });

  final int id;
  final String name;
  final String commonName;
  final String country;
  final String organization;
  final String organizationUnit;
  final String province;
  final String city;
  final String keyType;
  final String sslId;
  final String? certificate;
  final String? privateKey;

  factory CaDto.fromJson(Map<String, dynamic> json) {
    return CaDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      commonName: json['commonName'] as String? ?? '',
      country: json['country'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      organizationUnit: json['organizationUnit'] as String? ?? '',
      province: json['province'] as String? ?? '',
      city: json['city'] as String? ?? '',
      keyType: json['keyType'] as String? ?? '',
      sslId: json['sslId'] as String? ?? '',
      certificate: json['certificate'] as String?,
      privateKey: json['privateKey'] as String?,
    );
  }
}

class CaCreateReq {
  const CaCreateReq({
    required this.name,
    required this.commonName,
    required this.country,
    required this.organization,
    required this.organizationUnit,
    required this.province,
    required this.city,
    required this.keyType,
  });

  final String name;
  final String commonName;
  final String country;
  final String organization;
  final String organizationUnit;
  final String province;
  final String city;
  final String keyType;

  Map<String, dynamic> toJson() => {
    'name': name,
    'commonName': commonName,
    'country': country,
    'organization': organization,
    'organizationUnit': organizationUnit,
    'province': province,
    'city': city,
    'keyType': keyType,
  };
}

class CaObtainReq {
  const CaObtainReq({
    required this.id,
    required this.domains,
    required this.keyType,
    required this.time,
    required this.unit,
    required this.description,
    required this.dir,
    required this.shell,
    required this.autoRenew,
    required this.pushDir,
    required this.execShell,
  });

  final int id;
  final String domains;
  final String keyType;
  final int time;
  final String unit;
  final String description;
  final String dir;
  final String shell;
  final bool autoRenew;
  final bool pushDir;
  final bool execShell;

  Map<String, dynamic> toJson() => {
    'id': id,
    'domains': domains,
    'keyType': keyType,
    'time': time,
    'unit': unit,
    'description': description,
    'dir': dir,
    'shell': shell,
    'autoRenew': autoRenew,
    'pushDir': pushDir,
    'execShell': execShell,
  };
}
