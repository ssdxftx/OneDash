import 'website_domain_req.dart';

class WebsiteCreateReq {
  const WebsiteCreateReq({
    required this.alias,
    required this.type,
    required this.domains,
    this.webSiteGroupID = 1,
    this.remark = '',
    this.proxy = '',
    this.proxyType = 'tcp',
    this.port = 9000,
    this.appType = 'installed',
    this.runtimeID = 0,
    this.siteDir = '',
    this.taskID = '',
    this.enableSSL = false,
    this.websiteSSLID = 0,
    this.acmeAccountID = 0,
    this.ipv6 = false,
    this.enableFtp = false,
    this.ftpUser = '',
    this.ftpPassword = '',
    this.createDb = false,
    this.dbName = '',
    this.dbUser = '',
    this.dbPassword = '',
    this.dbHost = '',
    this.dbFormat = 'utf8mb4',
    this.dbType = 'mysql',
    this.streamPorts = '',
    this.udp = false,
    this.name = '',
    this.algorithm = '',
    this.servers = const [],
  });

  final String alias;
  final String type;
  final List<WebsiteDomainReq> domains;
  final int webSiteGroupID;
  final String remark;
  final String proxy;
  final String proxyType;
  final int port;
  final String appType;
  final int runtimeID;
  final String siteDir;
  final String taskID;
  final bool enableSSL;
  final int websiteSSLID;
  final int acmeAccountID;
  final bool ipv6;
  final bool enableFtp;
  final String ftpUser;
  final String ftpPassword;
  final bool createDb;
  final String dbName;
  final String dbUser;
  final String dbPassword;
  final String dbHost;
  final String dbFormat;
  final String dbType;
  final String streamPorts;
  final bool udp;
  final String name;
  final String algorithm;
  final List<Map<String, dynamic>> servers;

  Map<String, dynamic> toJson() {
    return {
      'alias': alias,
      'type': type,
      'primaryDomain': '',
      'otherDomains': '',
      'webSiteGroupID': webSiteGroupID,
      'webSiteGroupId': webSiteGroupID,
      'domains': domains.map((e) => e.toJson()).toList(),
      'port': port,
      'appType': appType,
      'appinstall': const {
        'appId': 0,
        'name': '',
        'appDetailId': 0,
        'params': <String, dynamic>{},
        'version': '',
        'appkey': '',
        'advanced': false,
        'cpuQuota': 0,
        'memoryLimit': 0,
        'memoryUnit': 'MB',
        'containerName': '',
        'allowPort': false,
        'format': 'utf8mb4',
        'collation': '',
      },
      'proxyType': proxyType,
      'proxyProtocol': 'http://',
      'proxyAddress': '',
      'runtimeType': 'php',
      'runtimeID': runtimeID,
      'taskID': taskID,
      'createDb': createDb,
      'dbName': dbName,
      'dbPassword': dbPassword,
      'dbFormat': dbFormat,
      'dbUser': dbUser,
      'dbType': dbType,
      'dbHost': dbHost,
      'enableSSL': enableSSL,
      'websiteSSLID': websiteSSLID,
      'acmeAccountID': acmeAccountID,
      'IPV6': ipv6,
      'enableFtp': enableFtp,
      'streamPorts': streamPorts,
      'udp': udp,
      'name': name,
      'algorithm': algorithm,
      'servers': servers,
      if (remark.isNotEmpty) 'remark': remark,
      if (proxy.isNotEmpty) 'proxy': proxy,
      'siteDir': siteDir,
      if (enableFtp) 'ftpUser': ftpUser,
      if (enableFtp) 'ftpPassword': ftpPassword,
    };
  }
}
